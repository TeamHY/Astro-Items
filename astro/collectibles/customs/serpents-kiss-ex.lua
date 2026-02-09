Astro.Collectible.SERPENTS_KISS_EX = Isaac.GetItemIdByName("Serpent's Kiss EX")

---

local FIRE_CHANCE = 0.15    -- 발사 확률

local CONTACT_DEAL = 12    -- 접촉 피해량

local DROP_CHANCE = 0.2    -- 블랙하트 확률

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_SERPENTS_KISS].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible393}}{{ColorYellow}}독뱀의 키스{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible393}} {{ColorYellow}}Serpent's Kiss{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.SERPENTS_KISS_EX, CRAFT_HINT)

            Astro.EID:AddCollectible(
                Astro.Collectible.SERPENTS_KISS_EX,
                "초 독뱀의 키스",
                "벗어날 생각은 마라",
                string.format("%.f", FIRE_CHANCE * 100) .. "%의 확률로 적을 중독시키는 공격이 나갑니다." ..
                "#적에게 접촉시 " .. string.format("%.f", CONTACT_DEAL) .. "의 피해를 주고 적을 중독시킵니다." ..
                "#{{BlackHeart}} 중독된 적이 죽을때 " .. string.format("%.f", DROP_CHANCE * 100) .. "% 확률로 블랙하트가 드랍됩니다.",
                -- 중첩 시
                "중첩 시 독 눈물 발사 확률 및 접촉 피해량 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.SERPENTS_KISS_EX,
                "Serpent's Kiss EX", "",
                string.format("%.f", FIRE_CHANCE * 100) .. "% chance to shoot poison tears" ..
                "#{{Poison}} Poison enemies on contact" ..
                "#{{BlackHeart}} Poisoned enemies have a " .. string.format("%.f", DROP_CHANCE * 100) .. "% chance to drop a Black Heart on death",
                -- Stacks
                "Stacks increase poison tear shoot chance and contact damage",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        local tearData = tear:GetData()

        if player ~= nil and player:HasCollectible(Astro.Collectible.SERPENTS_KISS_EX) then
            local rng = player:GetCollectibleRNG(Astro.Collectible.SERPENTS_KISS_EX)
            local collectibleNum = player:GetCollectibleNum(Astro.Collectible.SERPENTS_KISS_EX)

            if rng:RandomFloat() <= (FIRE_CHANCE * collectibleNum) then
                tear.Color = Color(0.4, 0.97, 0.5, 1)
                tear:AddTearFlags(TearFlags.TEAR_POISON)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = player:GetData()

            pData._ASTRO_serpentExFrameCooldown = 0
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local pData = player:GetData()
        
        if pData._ASTRO_serpentExFrameCooldown then
            pData._ASTRO_serpentExFrameCooldown = math.max(0, pData._ASTRO_serpentExFrameCooldown - 1)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_PLAYER_COLLISION,
    ---@param player EntityPlayer
    ---@param collider Entity
    ---@param low boolean
    function(_, player, collider, low)
        if not player:HasCollectible(Astro.Collectible.SERPENTS_KISS_EX) then return end
        if not collider:IsVulnerableEnemy() or collider.Type == EntityType.ENTITY_FIREPLACE then return end

        local cData = collider:GetData()
        local pData = player:GetData()
        local collectibleNum = player:GetCollectibleNum(Astro.Collectible.SERPENTS_KISS_EX)

        if pData._ASTRO_serpentExFrameCooldown > 0 then return end
        pData._ASTRO_serpentExFrameCooldown = 20

        collider:TakeDamage(CONTACT_DEAL * collectibleNum, DamageFlag.DAMAGE_POISON_BURN, EntityRef(player), 0)
        collider:AddPoison(EntityRef(player), 300, player.Damage, true)
        cData._ASTRO_stringrayPoison = true
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        local cData = entityNPC:GetData()

        if Astro:HasCollectible(Astro.Collectible.SERPENTS_KISS_EX) and cData._ASTRO_stringrayPoison then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.SERPENTS_KISS_EX)

            if rng:RandomFloat() < DROP_CHANCE then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 6, entityNPC.Position, Vector(0, 0), entityNPC)
            end
        end
    end
)
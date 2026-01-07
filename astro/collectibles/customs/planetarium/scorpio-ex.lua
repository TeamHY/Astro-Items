Astro.Collectible.SCORPIO_EX = Isaac.GetItemIdByName("Scorpio EX")

---

local POISON_FLY_CHANCE = 0.3
local POISON_FLY_COOL = 5 -- n프레임 당 하나

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.SCORPIO_EX,
                "초 전갈자리",
                "순도 100% 독",
                "{{Poison}} 항상 적을 중독시키는 공격이 나갑니다." ..
                "#적 명중 시 " .. string.format("%.f", POISON_FLY_CHANCE * 100) .. "%의 확률로 독성 파리를 소환합니다." ..
                "#{{LuckSmall}} 행운 14 이상일 때 100% 확률 (행운 1당 +5%p)",
                -- 중첩 시
                "중첩 시 중첩된 수만큼 소환 시도, 소환 쿨타임 감소"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.SCORPIO_EX,
                "Scorpio EX",
                "",
                "{{Poison}} Poison tears" ..
                "#" .. string.format("%.f", POISON_FLY_CHANCE * 100) .. "% chance to spawn a poison fly on hit" ..
                "#{{LuckSmall}} 100% chance at 14 Luck (+5%p per Luck)",
                -- Stacks
                "On stacking, attempts additional spawns per stack and reduces cooldown",
                "en_us"
            )
        end
    end
)


------ 독 파리 ------
Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil then
            local data = player:GetData()

            if (data["scorpioExCooldown"] == nil or data["scorpioExCooldown"] < Game():GetFrameCount()) and player:HasCollectible(Astro.Collectible.SCORPIO_EX) and entity:IsVulnerableEnemy() then
                if source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE then
                    local rng = player:GetCollectibleRNG(Astro.Collectible.SCORPIO_EX)

                    for _ = 1, player:GetCollectibleNum(Astro.Collectible.SCORPIO_EX) do
                        if rng:RandomFloat() < POISON_FLY_CHANCE + player.Luck / 20 then
                            local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 2, player.Position, Vector(0, 0), player)
                            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            
                            data["scorpioExCooldown"] = Game():GetFrameCount() + POISON_FLY_COOL / player:GetCollectibleNum(Astro.Collectible.SCORPIO_EX)
                        end
                    end
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        
        if player ~= nil and player:HasCollectible(Astro.Collectible.SCORPIO_EX) then
            tear.Color = Color(0.2, 1, 0.2, 1)
        end
    end
)


------ 독 공격 ------
Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.SCORPIO_EX) then
            if cacheFlag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_POISON
            end
        end
    end
)

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.AQUARIUS_EX = Isaac.GetItemIdByName("Aquarius EX")

---

local PENALTY_TIME = 10 * 30

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.AQUARIUS_EX,
                "초 물병자리",
                "눈물 분수",
                "{{Collectible308}} 캐릭터가 지나간 자리에 파란 장판이 생깁니다." ..
                "#{{ArrowGrayRight}} 파란 장판에 닿은 적은 공격력 x0.66의 피해를 받습니다." ..
                "#적 명중 시 그 적에게서 눈물이 뿜어져 나옵니다." ..
                "#!!! 페널티 피격 시 " .. string.format("%.f", PENALTY_TIME / 30) .. "초 동안 무효과"
            )
            
            Astro:AddEIDCollectible(
                Astro.Collectible.AQUARIUS_EX,
                "Aquarius EX",
                "",
                "{{Collectible308}} Isaac leaves a trail of creep" ..
                "#{{Damage}} The creep deals 66% of Isaac's damage per second and inherits his tear effects" ..
                "#Tears burst from hit enemies" ..
                "#!!!  Ineffective for " .. string.format("%.f", PENALTY_TIME / 30) .. " seconds on taking penalty damage",
                nil, "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(Astro.Collectible.AQUARIUS_EX) and entity:IsVulnerableEnemy() then
            if
                source.Type == EntityType.ENTITY_TEAR or
                    damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or
                    source.Type == EntityType.ENTITY_KNIFE
             then
                entity:GetData().Aquarius = {
                    Source = player,
                    Delay = math.floor(7 / player:GetCollectibleNum(Astro.Collectible.AQUARIUS_EX)) --몬스터에게 나오는 눈물 설정하는 곳
                }
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function()
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            local data = entity:GetData().Aquarius

            if data ~= nil then
                ---@type EntityPlayer
                local player = data.Source

                if player ~= nil and entity:IsVulnerableEnemy() and Game().TimeCounter % data.Delay == 0 and Astro:GetLastPenaltyFrame(player) + PENALTY_TIME < Game():GetFrameCount() then
                    local splashTear =
                        player:FireTear(
                        entity.Position,
                        Vector(player.ShotSpeed * 10, 0):Rotated(math.random(360)),
                        true,
                        true,
                        false
                    )
                    splashTear.FallingSpeed = player.TearHeight * .5 * (math.random() * .75 + .5)
                    splashTear.FallingAcceleration = 1.3
                    splashTear.TearFlags = splashTear.TearFlags | TearFlags.TEAR_PIERCING
                end
            end
        end
    end
)


------ 히든 아이템 ------
Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_AQUARIUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_AQUARIUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_AQUARIUS)
        end
    end,
    Astro.Collectible.AQUARIUS_EX
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_AQUARIUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_AQUARIUS)
        end
    end,
    Astro.Collectible.AQUARIUS_EX
)
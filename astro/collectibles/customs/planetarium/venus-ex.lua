---

local EXTRA_DAMAGE_MULTIPLIER = 0.5

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.VENUS_EX = Isaac.GetItemIdByName("VENUS EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.VENUS_EX,
                "초 금성",
                "미인이시네요",
             -- "!!! 획득 이후 {{Collectible591}}Venus 미등장#" ..
                "↑ {{Heart}}최대 체력 +1" ..
                "#↑ {{HealingRed}}빨간하트 +1" ..
                "#{{Charm}} 캐릭터와 가까이 있는 적을 매혹시키며;" ..
                "#{{ArrowGrayRight}} 매혹된 적에게 " .. string.format("%.f", EXTRA_DAMAGE_MULTIPLIER * 100) .. "%의 추가 피해를 줍니다.",
                -- 중첩 시
                "중첩 시 추가 피해량이 중첩된 수만큼 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.VENUS_EX,
                "Venus EX",
                "",
             -- "!!! {{Collectible591}} Venus doesn't appear after pickup#" ..
                "↑ {{Heart}} +1 Health" ..
                "#{{HealingRed}} Heals 1 heart" ..
                "#{{Charm}} Charms and nearby enemies;" ..
                "#{{ArrowGrayRight}} Deals " .. string.format("%.f", EXTRA_DAMAGE_MULTIPLIER * 100) .. "% extra damage to charmed enemies",
                -- Stacks
                "Stacks increase extra damage",
                "en_us"
            )

            EID.HealthUpData["5.100." .. tostring(Astro.Collectible.VENUS_EX)] = 1
            EID.BloodUpData[Astro.Collectible.VENUS_EX] = 4
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

        if player ~= nil and player:HasCollectible(Astro.Collectible.VENUS_EX) then
            if entity:IsVulnerableEnemy() and entity:HasEntityFlags(EntityFlag.FLAG_CHARM) and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                entity:TakeDamage(amount * EXTRA_DAMAGE_MULTIPLIER * player:GetCollectibleNum(Astro.Collectible.VENUS_EX), 0, EntityRef(player), 0)
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_VENUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_VENUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_VENUS)
        end

        if Astro:IsLeah(player) then
            player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_VENUS))
        end
    end,
    Astro.Collectible.VENUS_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_VENUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_VENUS)
        end
    end,
    Astro.Collectible.VENUS_EX
)

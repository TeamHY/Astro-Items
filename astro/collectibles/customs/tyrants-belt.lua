local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.TYRANTS_BELT = Isaac.GetItemIdByName("Tyrant’s Belt")

---

local CHAMPION_BONUS_DMG = 0.5    -- 챔피언 몬스터가 받는 피해량 n배

local CHAMPION_BONUS_DMG_STACK = 0.5    -- ↑ 중첩 시 증가량

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_CHAMPION_BELT].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible208}}{{ColorYellow}}챔피언 벨트{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible459}} {{ColorYellow}}Champion Belt{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.TYRANTS_BELT, CRAFT_HINT)

            Astro.EID:AddCollectible(
                Astro.Collectible.TYRANTS_BELT,
                "폭군의 허리띠",
                "죽여야 한다는 충동",
                "{{Collectible208}} Champion Belt 효과 적용:" ..
                "#{{IND}}↑ {{DamageSmall}}공격력 +1" ..
                "#{{IND}}!!! 일반적인 적이 챔피언으로 바뀔 확률 +5~20%p" ..
                "#{{IND}} 챔피언 몬스터는 체력이 평소의 2배, 캐릭터에게 최소 체력 1칸의 피해를 주며 색상별로 특수 효과가 적용됩니다." ..
                "#{{DamageSmall}} 챔피언 몬스터가 받는 피해량 +"  .. string.format("%.f", CHAMPION_BONUS_DMG * 100) .. "%p",
                -- 중첩 시
                "챔피언 몬스터가 받는 피해량이 +" .. string.format("%.f", CHAMPION_BONUS_DMG_STACK * 100) .. "%p씩 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.TYRANTS_BELT,
                "Tyrant's Belt", "",
                "{{Collectible208}} Champion Belt effect applied:" ..
                "#{{IND}}↑ {{Damage}} +1 Damage" ..
                "#{{IND}} Champion enemy chance goes from 5% to 20%" ..
                "#{{IND}} Doesn't increase chance of champion bosses" ..
                "#{{Damage}} Champion enemies damage taken +" .. string.format("%.f", CHAMPION_BONUS_DMG * 100) .. "%p",
                -- Stacks
                "Stacks increase extra damage",
                "en_us"
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
        local npc = entity:ToNPC()

        if
            player ~= nil
            and player:HasCollectible(Astro.Collectible.TYRANTS_BELT)
            and npc ~= nil
            and npc:IsChampion()
            and not npc:IsBoss()
            and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE)
        then
            local collectibleNum = player:GetCollectibleNum(Astro.Collectible.TYRANTS_BELT)
            local stackBonus = (collectibleNum - 1) * CHAMPION_BONUS_DMG_STACK
            local extraDamageMulti = CHAMPION_BONUS_DMG + stackBonus
            
            entity:TakeDamage(amount * extraDamageMulti, 0, EntityRef(player), 0)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.TYRANTS_BELT) then
            return
        end

        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_CHAMPION_BELT, 1, "ASTRO_TYRANTS_BELT")
    end
)
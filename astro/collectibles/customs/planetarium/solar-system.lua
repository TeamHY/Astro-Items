---

local STAGE_USAGE_LIMIT = 1

---

Astro.Collectible.SOLAR_SYSTEM = Isaac.GetItemIdByName("Solar System")

local ITEM_ID = Astro.Collectible.SOLAR_SYSTEM

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "태양계",
                "고향별",
                "!!! 스테이지 당 1회만 사용 가능" ..
                "#소지중일 때:" ..
                "#{{IND}}↑ 파리 배리어 +3" ..
                "#{{IND}} 비행 능력을 얻습니다." ..
                "#사용 시 그 스테이지에서 초 천체관 아이템을 하나 선택하고 그 효과를 적용합니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Solar System", "",
                "While held:" ..
                "#{{IND}}↑ +3 Fly orbitals" ..
                "#{{IND}} Flight" ..
                "#Upon Use:" ..
                "#{{IND}} Selects one EX Planetarium item from the current floor and applies its effect" ..
                "#{{IND}} Can only be used once per floor",
                nil, "en_us"
            )
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local targetStack = player:HasCollectible(ITEM_ID) and 1 or 0

        Astro.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_HALO_OF_FLIES, targetStack, "ASTRO_SOLAR_SYSTEM")
        Astro.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_TRANSCENDENCE, targetStack, "ASTRO_SOLAR_SYSTEM")
        Astro.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_DISTANT_ADMIRATION, targetStack, "ASTRO_SOLAR_SYSTEM")
        Astro.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_FOREVER_ALONE, targetStack, "ASTRO_SOLAR_SYSTEM")
    end
)

Astro.MegaUI:CreateInstance(
    {
        anm2Path = "gfx/ui/solar-system-ui.anm2",
        choiceCount = 9,
        itemId = ITEM_ID,
        offset = Vector(0, 40),
        onCheckCondition = function (player)
            local data = Astro.SaveManager.GetFloorSave(player)

            if not data["solarSystemUsageCount"] then
                return true
            end

            return data["solarSystemUsageCount"] < STAGE_USAGE_LIMIT
        end,
        onChoiceSelected = function(player, choice)
            local originalItems = {
                CollectibleType.COLLECTIBLE_SOL,
                CollectibleType.COLLECTIBLE_LUNA,
                CollectibleType.COLLECTIBLE_MERCURIUS,
                CollectibleType.COLLECTIBLE_VENUS,
                CollectibleType.COLLECTIBLE_MARS,
                CollectibleType.COLLECTIBLE_JUPITER,
                CollectibleType.COLLECTIBLE_SATURNUS,
                CollectibleType.COLLECTIBLE_URANUS,
                CollectibleType.COLLECTIBLE_NEPTUNUS
            }

            local exItems = {
                Astro.Collectible.SOL_EX,
                Astro.Collectible.LUNA_EX,
                Astro.Collectible.MERCURIUS_EX,
                Astro.Collectible.VENUS_EX,
                Astro.Collectible.MARS_EX,
                Astro.Collectible.JUPITER_EX,
                Astro.Collectible.SATURNUS_EX,
                Astro.Collectible.URANUS_EX,
                Astro.Collectible.NEPTUNUS_EX
            }

            Astro.HiddenItemManager:AddForFloor(player, originalItems[choice])
            Astro.HiddenItemManager:AddForFloor(player, exItems[choice])
            SFXManager():Play(910)

            local data = Astro.SaveManager.GetFloorSave(player)
            data["solarSystemUsageCount"] = (data["solarSystemUsageCount"] or 0) + 1
        end
    }
)

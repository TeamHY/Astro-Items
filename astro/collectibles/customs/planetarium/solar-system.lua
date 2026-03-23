---

local STAGE_USAGE_LIMIT = 1

---

Astro.Collectible.SOLAR_SYSTEM = Isaac.GetItemIdByName("Solar System")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.SOLAR_SYSTEM,
        "태양계",
        "고향별",
        "사용 시 초 행성 아이템을 하나 선택합니다. 선택한 아이템 효과를 해당 스테이지에 머무를 동안 적용합니다." ..
        "#소지 시 {{Collectible10}} {{Collectible20}} {{Collectible57}} {{Collectible128}} Halo of Flies, Transcendence, Distant Admiration, Forever Alone 효과가 적용됩니다." ..
        "#스테이지 당 한번 사용할 수 있습니다."
    )
end

local ITEM_ID = Astro.Collectible.SOLAR_SYSTEM

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

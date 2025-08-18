local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.BIRTHRIGHT_EDEN_B = Isaac.GetItemIdByName("Birthright - Eden B")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_EDEN_B,
                "더럽혀진 에덴의 생득권",
                "??!",
                "{{Collectible619}} 사용 시 Birthright를 획득합니다." ..
                "#{{Collectible258}} 획득 시 및 소지중에 스테이지를 넘어갈 때마다 소지중인 아이템과 능력치를 모두 바꿉니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        playerWhoUsedItem:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.BIRTHRIGHT_EDEN_B
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.BIRTHRIGHT_EDEN_B) then
            return
        end

        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_MISSING_NO, 1, "ASTRO_BIRTHRIGHT_EDEN_B")
    end
)

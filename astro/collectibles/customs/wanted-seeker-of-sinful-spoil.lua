Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL = Isaac.GetItemIdByName("WANTED: Seeker of Sinful Spoil")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL,
                "죄보사냥의 악마",
                "\"죄보\"를 둘러싼 이야기를 쫓는 당신에게",
                "!!! 일회용 !!!" ..
                "#{{Player" .. Astro.Players.DIABELLSTAR .. "}} 사용 시 캐릭터를 Diabellstar로 변경합니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL,
                "WANTED: Seeker of Sinful Spoil",
                "",
                "!!! SINGLE USE !!!" ..
                "#{{Player" .. Astro.Players.DIABELLSTAR .. "}} Changes character to Diabellstar",
                nil, "en_us"
            )

            Astro.EID:RegisterAlternativeText(
                { itemType = ItemType.ITEM_ACTIVE, subType = Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL },
                "WANTED: Seeker of S.S."
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
        playerWhoUsedItem:ChangePlayerType(Astro.Players.DIABELLSTAR)

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL
)

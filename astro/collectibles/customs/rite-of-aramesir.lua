Astro.Collectible.RITE_OF_ARAMESIR = Isaac.GetItemIdByName("Rite of Aramesir")

local useSound = Isaac.GetSoundIdByName('RiteofAramesir')
local useSoundVoulme = 1 -- 0 ~ 1

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.RITE_OF_ARAMESIR,
                "아라메시아의 의",
                "당신은 오랜 맹약의 의식에 의해 이 세계에 내려왔습니다",
                "사용 시:" ..
                "#{{IND}}↓ {{LuckSmall}}행운 -2" ..
                "#{{IND}} {{Trinket" .. Astro.Trinket.BLACK_MIRROR .. "}}Black Mirror(패시브 획득 시 한 번 더 획득)를 1개 드랍합니다." ..
                "#스테이지 진입 시 충전량이 모두 채워집니다."
            )

            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.RITE_OF_ARAMESIR),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                "행운 감소 패널티 무효화",
                nil, "ko_kr", nil
            )

            ----
            
            Astro.EID:AddCollectible(
                Astro.Collectible.RITE_OF_ARAMESIR,
                "Rite of Aramesir", "",
                "Upon use:" ..
                "#{{IND}}↓ {{Luck}} -2 Luck" ..
                "#{{IND}} Spawns 1{{Trinket" .. Astro.Trinket.BLACK_MIRROR .. "}} Black Mirror (Gain passive item twice)" ..
                "#Fully charges when entering a new floor",
                nil, "en_us"
            )

            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.RITE_OF_ARAMESIR),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                "Luck penalty nullification",
                nil, "en_us", nil
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.RiteOfAramesir = {
                luck = 0
            }
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for j = 0, ActiveSlot.SLOT_POCKET2 do
                if player:GetActiveItem(j) == Astro.Collectible.RITE_OF_ARAMESIR then
                    if player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                        player:AddCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                        player:SetActiveCharge(100, j)
                        player:RemoveCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    else
                        player:SetActiveCharge(50, j)
                    end
                end
            end
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
        Astro:SpawnTrinket(Astro.Trinket.BLACK_MIRROR, playerWhoUsedItem.Position)

        SFXManager():Play(useSound, useSoundVoulme)

        if not Astro:IsWaterEnchantress(playerWhoUsedItem) then
            Astro.Data.RiteOfAramesir.luck = Astro.Data.RiteOfAramesir.luck - 2

            playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_LUCK)
            playerWhoUsedItem:EvaluateItems()
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.RITE_OF_ARAMESIR
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if not Astro:IsWaterEnchantress(player) and Astro.Data.RiteOfAramesir ~= nil then
            player.Luck = player.Luck + Astro.Data.RiteOfAramesir.luck
        end
    end,
    CacheFlag.CACHE_LUCK
)


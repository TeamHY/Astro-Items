Astro.Collectible.LUXURY_ROSARY = Isaac.GetItemIdByName("Luxury Rosary")

---

local REROLL_CHANCE_BASE = 0.05

local TEARS_INCREMENT = 1

local HAS_ANGEL_TAG = {}

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.LUXURY_ROSARY,
                "명품 묵주",
                "그 빛 가운데 거한다면",
                "↑ {{SoulHeart}}소울하트 +3" ..
                "#↑ {{TearsSmall}}연사(+상한) +1" ..
                "#{{Quality0}}/{{Quality1}}등급 아이템 등장 시 " .. string.format("%.f", REROLL_CHANCE_BASE * 100) .. "%의 확률로 Seraphim 세트 아이템으로 바꿉니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.LUXURY_ROSARY,
                "Luxury Rosary", "",
                "↑ {{SoulHeart}} +3 Soul Hearts" ..
                "#↑ {{Tears}} +1 Fire Rate" ..
                "#" .. string.format("%.f", REROLL_CHANCE_BASE * 100) .. "% chance to reroll {{Quality0}}/{{Quality1}} items into Seraphim transformation items",
                nil, "en_us"
            )
        end

        local itemConfig = Isaac.GetItemConfig()
        local maxItemId = Astro:GetMaxCollectibleID()

        for i = 1, maxItemId do
            local itemConfigItem = itemConfig:GetCollectible(i)
            
            if itemConfigItem and not itemConfigItem.Hidden and itemConfigItem:HasTags(ItemConfig.TAG_ANGEL) then
                table.insert(HAS_ANGEL_TAG, i)
            end
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                
                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)

                    if Astro:HasCollectible(Astro.Collectible.LUXURY_ROSARY) then
                        local rng = player:GetCollectibleRNG(Astro.Collectible.LUXURY_ROSARY)

                        if rng:RandomFloat() <= REROLL_CHANCE_BASE then
                            local itemConfigSelect = itemConfig:GetCollectible(selectedCollectible)
                            local selectItem = rng:RandomInt(#HAS_ANGEL_TAG)

                            return {
                                newItem = HAS_ANGEL_TAG[selectItem],
                                reroll = itemConfigSelect.Quality <= 1,
                                modifierName = "Luxury Rosary"
                            }
                        end
                    end
                end
        
                return false
            end
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlags CacheFlag
    function(_, player, cacheFlags)
        if player:HasCollectible(Astro.Collectible.LUXURY_ROSARY) and cacheFlags == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, TEARS_INCREMENT * player:GetCollectibleNum(Astro.Collectible.LUXURY_ROSARY))
        end
    end
)
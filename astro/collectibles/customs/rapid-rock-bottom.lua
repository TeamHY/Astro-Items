Astro.Collectible.RAPID_ROCK_BOTTOM = Isaac.GetItemIdByName("Rapid Rock Bottom")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.RAPID_ROCK_BOTTOM,
                "재빠른 밑바닥",
                "빨라질 일만 남았어",
                "{{TearsSmall}} 연사를 항상 가장 높았던 값으로 고정합니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.RAPID_ROCK_BOTTOM,
                "Rapid Rock Bottom", "",
                "↑ Prevents {{Tears}} tears from being lowered for the rest of the run",
                nil, "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if isContinued then
            for i = 1, Game():GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
			
				local data = Astro:GetPersistentPlayerData(player)

				if data.peakFireDelay then
					player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:EvaluateItems()
				end
			end
        end
    end
)


Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.ROCK_BOTTOM,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.RAPID_ROCK_BOTTOM) and not player:HasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM) then
            if cacheFlag == CacheFlag.CACHE_FIREDELAY then
                local data = Astro:GetPersistentPlayerData(player)

                if data then
                    if player.MaxFireDelay < (data.peakFireDelay or 10000) then
                        data.peakFireDelay = player.MaxFireDelay
                    end

                    player.MaxFireDelay = data.peakFireDelay
                end
            end
        end
    end
)

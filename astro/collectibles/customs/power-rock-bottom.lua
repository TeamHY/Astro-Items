Astro.Collectible.POWER_ROCK_BOTTOM = Isaac.GetItemIdByName("Power Rock Bottom")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.RAPID_ROCK_BOTTOM,
                "강력한 밑바닥",
                "더 강해질 일만 남았어",
                "{{DamageSmall}} 공격력을 항상 가장 높았던 값으로 고정합니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.RAPID_ROCK_BOTTOM,
                "Rapid Rock Bottom", "",
                "↑ Prevents {{Damage}} damage from being lowered for the rest of the run",
                nil, "en_us"
            )
        end
    end
)


if EID then
    Astro.EID:AddCollectible(Astro.Collectible.POWER_ROCK_BOTTOM, " 밑바닥", "", "")
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if isContinued then
            for i = 1, Game():GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
			
				local data = Astro:GetPersistentPlayerData(player)

				if data.peakDamage then
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
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
        if player:HasCollectible(Astro.Collectible.POWER_ROCK_BOTTOM) and not player:HasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                local data = Astro:GetPersistentPlayerData(player)

                if data then
                    if player.Damage > (data.peakDamage or -10000) then
                        data.peakDamage = player.Damage
                    end

                    player.Damage = data.peakDamage
                end
            end
        end
    end
)

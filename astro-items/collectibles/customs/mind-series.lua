AstroItems.Collectible.CALM_MIND = Isaac.GetItemIdByName("Calm Mind")
AstroItems.Collectible.SWIFT_MIND = Isaac.GetItemIdByName("Swift Mind")
AstroItems.Collectible.BLUE_MIND = Isaac.GetItemIdByName("Blue Mind")
AstroItems.Collectible.LUCKY_MIND = Isaac.GetItemIdByName("Lucky Mind")
AstroItems.Collectible.QUANTUM_MIND = Isaac.GetItemIdByName("Quantum Mind")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.CALM_MIND,
        "침착한 정신",
        "...",
        ""
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.SWIFT_MIND,
        "신속한 정신",
        "...",
        ""
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.BLUE_MIND,
        "우울한 정신",
        "...",
        ""
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.LUCKY_MIND,
        "행운의 정신",
        "...",
        ""
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.QUANTUM_MIND,
        "퀀텀 마인드",
        "...",
        ""
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local data = AstroItems:GetPersistentPlayerData(player)

        if not data["mindSeries"] then
            data["mindSeries"] = {
                damage = 0,
                speed = 0,
                tears = 0,
                luck = 0
            }
        end

        if Game():GetFrameCount() % 30 == 0 then
            if player:HasCollectible(AstroItems.Collectible.CALM_MIND) then
                data["mindSeries"].damage = data["mindSeries"].damage + 0.005 * player:HasCollectible(AstroItems.Collectible.CALM_MIND) + player:HasCollectible(A)
    
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            end
        end

        player:EvaluateItems()
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local data = AstroItems:GetPersistentPlayerData(player)

		if data then
			local damage = data.AmplifyingMindDamage or 0

			player.Damage = player.Damage + damage
		end
    end,
    CacheFlag.CACHE_DAMAGE
)

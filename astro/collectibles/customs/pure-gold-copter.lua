Astro.Collectible.PURE_GOLD_COPTER = Isaac.GetItemIdByName("24K Copter")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.PURE_GOLD_COPTER,
                "순금 헬리콥터",
                "대신 초소형입니다",
                "비행 능력을 얻습니다."
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.PURE_GOLD_COPTER,
                "24K Copter",
                "",
                "Flight",
                nil, "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.PURE_GOLD_COPTER) then
            player.CanFly = true
        end
    end,
    CacheFlag.CACHE_FLYING
)
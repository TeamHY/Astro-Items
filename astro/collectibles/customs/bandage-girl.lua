---

local MAX_GIVE_COUNT = 2

---

Astro.Collectible.BANDAGE_GIRL = Isaac.GetItemIdByName("Bandage Girl")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BANDAGE_GIRL,
                "밴디지 걸",
                "여자친구",
                "최초 획득 시 {{Collectible207}}Ball of Bandages를 2개 얻습니다." ..
                "#스테이지를 넘어갈 때마다 {{Collectible207}}Ball of Bandages를 획득합니다." ..
                "중첩이 가능하며 {{Collectible" .. Astro.Collectible.BLOOD_TRAIL .. "}}Blood Trail의 중첩에도 영향을 줍니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.BANDAGE_GIRL) then
                for _ = 1 , player:GetCollectibleNum(Astro.Collectible.BLOOD_TRAIL) + player:GetCollectibleNum(Astro.Collectible.BANDAGE_GIRL) do
                    player:AddCollectible(CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES)
                end
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.BANDAGE_GIRL) then
            for _ = 1 , MAX_GIVE_COUNT - player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES) do
                player:AddCollectible(CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES)
            end
        end
    end,
    Astro.Collectible.BANDAGE_GIRL
)

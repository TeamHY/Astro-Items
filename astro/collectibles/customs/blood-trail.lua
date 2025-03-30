---

local MAX_GIVE_COUNT = 2

---

Astro.Collectible.BLOOD_TRAIL = Isaac.GetItemIdByName("Blood Trail")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BLOOD_TRAIL,
        "블러드 트레일",
        "...",
        "최초 획득 시 {{Collectible73}}Cube of Meat를 2개까지 지급합니다." ..
        "#스테이지 입장 시 {{Collectible73}}Cube of Meat를 획득합니다. 중첩이 가능합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.BLOOD_TRAIL) then
                for _ = 1 , player:GetCollectibleNum(Astro.Collectible.BLOOD_TRAIL) do
                    player:AddCollectible(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT)
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
        if Astro:IsFirstAdded(CollectibleType.BLOOD_TRAIL) then
            for _ = 1 , MAX_GIVE_COUNT - player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT) do
                player:AddCollectible(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT)
            end
        end
    end,
    Astro.Collectible.BLOOD_TRAIL
)

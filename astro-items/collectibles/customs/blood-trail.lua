AstroItems.Collectible.BLOOD_TRAIL = Isaac.GetItemIdByName("Blood Trail")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.BLOOD_TRAIL,
        "블러드 트레일",
        "...",
        "스테이지 입장 시 {{Collectible73}}Cube of Meat를 획득합니다.#중첩이 가능합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.BLOOD_TRAIL) then
                for _ = 1 , player:GetCollectibleNum(AstroItems.Collectible.BLOOD_TRAIL) do
                    player:AddCollectible(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT)
                end
            end
        end
    end
)

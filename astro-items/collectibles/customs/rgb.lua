AstroItems.Collectible.RGB = Isaac.GetItemIdByName("RGB")

local function Init()
    if EID then
        AstroItems:AddEIDCollectible(
            AstroItems.Collectible.RGB,
            "삼원색",
            "...",
            ""
        )
    end
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if AstroItems:HasCollectible(AstroItems.Collectible.RGB) then
            local level = Game():GetLevel()
            local room = level:GetCurrentRoom()
            local player = Isaac.GetPlayer()
            local rng = player:GetCollectibleRNG(AstroItems.Collectible.RGB)

            local noise = AstroItems.Noise:GetWhiteNoise(rng:GetSeed(), room:GetSpawnSeed(), 1)
            
            if noise < 1 / 3 then
                room:SetWallColor(Color(1, 1, 1, 1, 255, 0, 0))
                room:SetFloorColor(Color(1, 1, 1, 1, 255, 0, 0))
            elseif noise < 2 / 3 then
                room:SetWallColor(Color(1, 1, 1, 1, 0, 255, 0))
                room:SetFloorColor(Color(1, 1, 1, 1, 0, 255, 0))
            else
                room:SetWallColor(Color(1, 1, 1, 1, 0, 0, 255))
                room:SetFloorColor(Color(1, 1, 1, 1, 0, 0, 255))
            end
        end
    end
)

return {
    Init = Init
}

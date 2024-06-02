local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.DENEB = Isaac.GetItemIdByName("Deneb")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.DENEB,
        "데네브",
        "...",
        "다음 게임에서 애프터버스 변종 스테이지 (Burning Basement, Flooded Caves, Dank Depths, Scarred Womb) 등장하지 않습니다."
    )
end

local function TryChangeStage()
    if AstroItems.Data.BanAfterbirthStage then
        local level = Game():GetLevel()
        local stage = level:GetStage()
        local rng = Isaac.GetPlayer():GetCollectibleRNG(AstroItems.Collectible.DENEB)

        if level:GetStageType() == StageType.STAGETYPE_AFTERBIRTH and stage <= LevelStage.STAGE4_2 then
            Isaac.ExecuteCommand("stage " .. stage .. (rng:RandomFloat() < 0.5 and "" or "a"))
            print("Deneb Effect: Ban Afterbirth Stage")
        end
    end
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            if AstroItems.Data.RunDeneb then
                AstroItems.Data.BanAfterbirthStage = true
                TryChangeStage()
            else
                AstroItems.Data.BanAfterbirthStage = false
            end

            AstroItems.Data.RunDeneb = false
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Game():GetFrameCount() > 1 then
            TryChangeStage()
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        AstroItems.Data.RunDeneb = true
    end,
    AstroItems.Collectible.DENEB
)

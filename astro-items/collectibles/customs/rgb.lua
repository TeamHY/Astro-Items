---

local COLOR_VALUE = 0.3 -- 방 색상 강도 (0.0 ~ 1.0)

local DAMAGE_MULTIPLIER = 1.5

local LUCK_MULTIPLIER = 1.5

local FIRE_DELAY_MULTIPLIER = 1.5

---

local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.RGB = Isaac.GetItemIdByName("RGB")

local function Init()
    if EID then
        AstroItems:AddEIDCollectible(
            AstroItems.Collectible.RGB,
            "삼원색",
            "...",
            "방의 색상이 변경됩니다. 방 색상에 따라 효과가 달라집니다." ..
            "#{{ArrowUp}} {{ColorRed}}{{DamageSmall}} 공격력 x1.5" ..
            "#{{ArrowUp}} {{ColorGreen}}{{LuckSmall}} 행운 x1.5" ..
            "#{{ArrowUp}} {{ColorBlue}}{{TearsSmall}} 연사 x1.5" ..
            "#중첩 시 곱 연산으로 적용됩니다."
        )
    end
end

local colors = {
    RED = 0,
    GREEN = 1,
    BLUE = 2
}

local function GetColor()
    local level = Game():GetLevel()
    local player = Isaac.GetPlayer()
    local rng = player:GetCollectibleRNG(AstroItems.Collectible.RGB)

    return math.floor(AstroItems.Noise:GetWhiteNoise(rng:GetSeed(), level:GetCurrentRoomIndex()) * 3)
end

local function UpdateColor()
    local room = Game():GetLevel():GetCurrentRoom()
    local color = GetColor()

    if color == colors.RED then
        room:SetWallColor(Color(1, 1, 1, 1, COLOR_VALUE, 0, 0))
        room:SetFloorColor(Color(1, 1, 1, 1, COLOR_VALUE, 0, 0))
    elseif color == colors.GREEN then
        room:SetWallColor(Color(1, 1, 1, 1, 0, COLOR_VALUE, 0))
        room:SetFloorColor(Color(1, 1, 1, 1, 0, COLOR_VALUE, 0))
    else
        room:SetWallColor(Color(1, 1, 1, 1, 0, 0, COLOR_VALUE))
        room:SetFloorColor(Color(1, 1, 1, 1, 0, 0, COLOR_VALUE))
    end

    for i = 1, Game():GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)
    
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        UpdateColor()
    end,
    AstroItems.Collectible.RGB
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if AstroItems:HasCollectible(AstroItems.Collectible.RGB) then
            UpdateColor()
        end
    end
)

AstroItems:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@diagnostic disable-next-line: param-type-mismatch
    CallbackPriority.LATE + 2000,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function (_, player, cacheFlag)
        if not player:HasCollectible(AstroItems.Collectible.RGB) then return end

        local color = GetColor()
        local rgbNum = player:GetCollectibleNum(AstroItems.Collectible.RGB)

        if color == colors.RED then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage * (DAMAGE_MULTIPLIER ^ rgbNum)
            end
        elseif color == colors.GREEN then
            if cacheFlag == CacheFlag.CACHE_LUCK and player.Luck > 0 then
                player.Luck = player.Luck * (LUCK_MULTIPLIER ^ rgbNum)
            end
        else
            if cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = ((player.MaxFireDelay + 1) / (FIRE_DELAY_MULTIPLIER ^ rgbNum)) - 1
            end
        end
    end
)

return {
    Init = Init
}

---

local COLOR_VALUE = 0.1 -- 방 색상 강도 (0.0 ~ 1.0)

local DAMAGE_MULTIPLIER = 1.4

local LUCK_MULTIPLIER = 1.5

local FIRE_DELAY_MULTIPLIER = 1.2

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.RGB = Isaac.GetItemIdByName("RGB")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.RGB,
                "삼원색",
                "불 좀 꺼줄래?",
                "방의 색상을 변경하며, 색상에 따라 효과가 달라집니다;" ..
                "#{{ArrowGrayRight}} {{ColorRed}}(빨강){{CR}} {{DamageSmall}}공격력 배율 x1.4" ..
                "#{{ArrowGrayRight}} {{ColorGreen}}(초록){{CR}} {{LuckSmall}}행운 배율 x1.5" ..
                "#{{ArrowGrayRight}} {{ColorBlue}}(파랑){{CR}} {{TearsSmall}}연사 배율 x1.2" ..
                "#중첩 시 곱 연산으로 적용됩니다."
            )
        end
    end
)

local colors = {
    RED = 0,
    GREEN = 1,
    BLUE = 2
}

local function GetColor()
    local level = Game():GetLevel()
    local player = Isaac.GetPlayer()
    local rng = player:GetCollectibleRNG(Astro.Collectible.RGB)

    return math.floor(Astro.Noise:GetWhiteNoise(rng:GetSeed(), level:GetCurrentRoomIndex()) * 3)
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

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        UpdateColor()
    end,
    Astro.Collectible.RGB
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.RGB) then
            UpdateColor()
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@diagnostic disable-next-line: param-type-mismatch
    Astro.CallbackPriority.MULTIPLY,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function (_, player, cacheFlag)
        if not player:HasCollectible(Astro.Collectible.RGB) then return end

        local color = GetColor()
        local rgbNum = player:GetCollectibleNum(Astro.Collectible.RGB)

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

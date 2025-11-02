Astro.Collectible.LOVE_LETTER = Isaac.GetItemIdByName("Love Letter")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.LOVE_LETTER,
        "고백 편지",
        "전해지지 않은 러브레터",
        "사용 시 {{Heart}}빨강하트 1칸 또는 {{SoulHeart}}소울하트 2칸을 소모해 공격방향으로 편지를 발사합니다." ..
        "#편지에 맞은 적은 해당 게임에서 영원히 아군이 됩니다."
    )
end

local A = false

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
        local hasRedHearts = player:GetHearts() >= 2
        local hasSoulHearts = player:GetSoulHearts() >= 4
        
        if not hasRedHearts and not hasSoulHearts then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        A = not A

        player:AnimateCollectible(Astro.Collectible.LOVE_LETTER)

        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false,
        }
        
        -- if hasRedHearts then
        --     player:AddHearts(-2)
        -- else
        --     player:AddSoulHearts(-4)
        -- end
        
        -- local direction = player:GetShootingInput()
        -- if direction:Length() == 0 then
        --     local headDirection = player:GetHeadDirection()
        --     if headDirection == Direction.LEFT then
        --         direction = Vector(-1, 0)
        --     elseif headDirection == Direction.UP then
        --         direction = Vector(0, -1)
        --     elseif headDirection == Direction.RIGHT then
        --         direction = Vector(1, 0)
        --     else
        --         direction = Vector(0, 1)
        --     end
        -- end
        
        -- local tear = player:FireTear(
        --     player.Position,
        --     direction:Normalized() * 10,
        --     false,
        --     true,
        --     false,
        --     player,
        --     1
        -- ):ToTear()
        
        -- return {
        --     Discharge = true,
        --     Remove = false,
        --     ShowAnim = true,
        -- }
    end,
    Astro.Collectible.LOVE_LETTER
)

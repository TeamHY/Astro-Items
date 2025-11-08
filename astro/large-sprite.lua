local LARGE_SPRITE_ANM2 = "gfx/large_collectible.anm2"

local QUESTIONMARK_SUFFIX = "questionmark.png"

local largeSpriteItems = {
    [Astro.Collectible.MEGA_D4] = {
        renderOffset = Vector(0, 32)
    },
    [Astro.Collectible.MEGA_D6] = {
        renderOffset = Vector(0, 24)
    },
    [Astro.Collectible.MEGA_D8] = {
        renderOffset = Vector(0, 24)
    }
}

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_RENDER,
    ---@param entity EntityPickup
    ---@param _offset Vector
    function(_, entity, _offset)
        local largeSprite = largeSpriteItems[entity.SubType]

        if not largeSprite then
            return
        end

        local sprite = entity:GetSprite()
        local itemLayer = sprite:GetLayer(1) ---@cast itemLayer -nil
        local spritePath = itemLayer:GetSpritesheetPath()
        
        if spritePath:sub(-16, -1) == QUESTIONMARK_SUFFIX then
            return
        end

        local offset = largeSprite.renderOffset + sprite.Offset

        local data = entity:GetData()

        if not data["largeSprite"] then
            local newSprite = Sprite()
            newSprite:Load(LARGE_SPRITE_ANM2)
            newSprite:ReplaceSpritesheet(1, "gfx/items/collectibles/larges/" .. spritePath:sub(24, -1))
            newSprite:LoadGraphics()
            newSprite:Play("Idle")
            newSprite.PlaybackSpeed = sprite.PlaybackSpeed

            data["largeSprite"] = newSprite
        end

        local currentFrame = sprite:GetCurrentAnimationData():GetLayer(1):GetFrame(sprite:GetFrame() - 1)

        if currentFrame then
           if sprite:GetFrame() ~= data["lastFrame"] then
                data["largeSprite"]:GetLayer(1):SetSize(currentFrame:GetScale())
            end

            data["lastFrame"] = sprite:GetFrame()
            data["largeSprite"]:Render(Astro:ToScreen(entity.Position + currentFrame:GetPos() + entity:GetNullOffset("ItemOffset") + offset))
        end
    end,
    PickupVariant.PICKUP_COLLECTIBLE
)

-- if REPENTOGON then
--     Astro:AddCallback(
--         ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM,
--         ---@param player EntityPlayer
--         ---@param slot ActiveSlot
--         ---@param offset Vector
--         ---@param alpha number
--         ---@param scale number
--         ---@param chargeBarOffset Vector
--         function(_, player, slot, offset, alpha, scale, chargeBarOffset)
--             local activeItem = player:GetActiveItem(slot)
--             local largeSprite = largeSpriteItems[activeItem]
            
--             if not largeSprite then
--                 return
--             end
            
--             return true
--         end
--     )
-- end

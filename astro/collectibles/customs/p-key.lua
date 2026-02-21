---

Astro.Collectible.P_KEY = Isaac.GetItemIdByName("P Key")

local ITEM_ID = Astro.Collectible.P_KEY

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
         -- local CRAFT_HINT = {
         --     ["ko_kr"] = "#{{DiceRoom}} {{ColorYellow}}주사위방{{CR}}에서 사용하여 변환",
         --     ["en_us"] = "#{{DiceRoom}} Can be transformed {{ColorYellow}}using it in the Dice Room{{CR}}"
         -- }
         -- Astro.EID:AddCraftHint(CollectibleType.COLLECTIBLE_R_KEY, CRAFT_HINT)

            Astro.EID:AddCollectible(
                ITEM_ID,
                "P키",
                "멈춰!",
                "#패널티 피격 시 해당 피격을 무력화하고 10초간 무적 상태가 됩니다." ..
                "#패널티 피격 시마다 쿨타임이 충전되며, 쿨타임이 완충되었을 경우 해당 아이템이 제거됩니다." ..
                "#!!! 일반적인 방식으로 쿨타임이 증가하지 않습니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "P Key",
                "Hold it!",
                "#On penalty damage, negates the hit and grants 10 seconds of invincibility" ..
                "#Each penalty hit charges the cooldown; removes itself when fully charged" ..
                "#!!! Cooldown does not increase by normal means",
                nil, "en_us"
            )
        end
    end
)

---@param player EntityPlayer
local function FreezeEntities(player)
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        if
            not ent:ToBomb()
            or not ent:ToFamiliar()
            or not ent:ToPickup()
            or not ent:ToLaser()
            or not ent:ToKnife()
            or not ent:ToPlayer()
            or not ent:ToTear()
        then
            ent:AddFreeze(EntityRef(player), 300, true)
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Game():GetPlayer(i)

            if Input.IsButtonTriggered(Keyboard.KEY_P, player.ControllerIndex) then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_R_KEY) then
                    Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID, player.Position)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, player.Position, player.Velocity, nil)

                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_R_KEY, true)
                    player:AnimateCollectible(CollectibleType.COLLECTIBLE_R_KEY)

                    break
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player ~= nil and player:HasCollectible(ITEM_ID) then
            if damageFlags & (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS) == 0 then
                local data = Astro.SaveManager.GetRunSave(player)
                local itemConfigItem = Isaac.GetItemConfig():GetCollectible(ITEM_ID)

                if data.pKeyCount == nil then
                    data.pKeyCount = 0
                end

                data.pKeyCount = data.pKeyCount + 1
                player:SetActiveCharge(data.pKeyCount, Astro:GetPlayerActiveItemSlot(player, ITEM_ID))
                player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, UseFlag.USE_NOANIM)
                FreezeEntities(player)

                if data.pKeyCount >= itemConfigItem.MaxCharges then
                    player:RemoveCollectible(ITEM_ID)
                    data.pKeyCount = nil
                end

                return false
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            
            if player:HasCollectible(ITEM_ID) then
                local data = Astro.SaveManager.GetRunSave(player)
                
                if data.pKeyCount == nil then
                    data.pKeyCount = 0
                end

                player:SetActiveCharge(data.pKeyCount, Astro:GetPlayerActiveItemSlot(player, ITEM_ID))
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function()
        -- 1초에 한 번씩만 체크
        if not (Game():GetFrameCount() % 30 == 0) then
            return
        end

        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Game():GetPlayer(i)
            
            if player:HasCollectible(ITEM_ID) then
                local data = Astro.SaveManager.GetRunSave(player)
                
                if data.pKeyCount == nil then
                    data.pKeyCount = 0
                end

                player:SetActiveCharge(data.pKeyCount, Astro:GetPlayerActiveItemSlot(player, ITEM_ID))
            end
        end
    end
)

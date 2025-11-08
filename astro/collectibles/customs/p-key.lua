---

Astro.Collectible.P_KEY = Isaac.GetItemIdByName("P Key")

local ITEM_ID = Astro.Collectible.P_KEY

---

if EID then
    local CRAFT_HINT = {
        ["ko_kr"] = "#{{DiceRoom}} {{ColorYellow}}주사위방{{CR}}에서 사용하여 변환",
        ["en_us"] = "#{{DiceRoom}} Can be transformed {{ColorYellow}}using it in the Dice Room{{CR}}"
    }
    Astro:AddCraftHint(CollectibleType.COLLECTIBLE_R_KEY, CRAFT_HINT)

    Astro:AddEIDCollectible(
        ITEM_ID,
        "패널티 피격 시 해당 피격을 무력화 이후 퍼즈 키 클릭" ..
        "#패널티 피격 시마다 쿨타임이 충전되며, 쿨타임이 완충되었을 경우 해당 아이템 자동 제거" ..
        "#에덴 소울처럼 최초 획득 시 기본 쿨 제거시켜놓고 테스트",
        "P Key", "...",
        "ko_kr"
    )

    Astro:AddEIDCollectible(
        ITEM_ID,
        "When taking penalty damage, nullifies the damage and forces pause key input" ..
        "#Each penalty hit charges cooldown, removes item when cooldown is full" ..
        "#Initially starts with no cooldown like Eden's Soul",
        "P Key", "...",
        "en_us"
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        if Input.IsButtonTriggered(Keyboard.KEY_P, 0) then
            for i = 0, Game():GetNumPlayers() - 1 do
                local player = Game():GetPlayer(i)

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
                player:SetActiveCharge(data.pKeyCount, player:GetActiveItemSlot(ITEM_ID))

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

                player:SetActiveCharge(data.pKeyCount, player:GetActiveItemSlot(ITEM_ID))
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

                player:SetActiveCharge(data.pKeyCount, player:GetActiveItemSlot(ITEM_ID))
            end
        end
    end
)

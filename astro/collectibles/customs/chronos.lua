Astro.Collectible.CHRONOS = Isaac.GetItemIdByName("Chronos")

---

local returnItems = {
    [CollectibleType.COLLECTIBLE_SERAPHIM] = CollectibleType.COLLECTIBLE_SACRED_HEART,    -- 세라핌-불심
}

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.CHRONOS,
                "사투르누스",
                "자식을 먹어치운 자",
                "{{FamiliarIcon}} 사용 시 그 방의 모든 패밀리어 아이템마다 각자 정해진 아이템으로 바꿉니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.CHRONOS,
                "Chronos",
                "",
                "{{FamiliarIcon}} Rerolls every familiar items in the room with its own assigned items",
                nil, "en_us"
            )

            ------

            ---@param id CollectibleType
            local function GetMorphString(id)
                local eidKor = EID:getLanguage() == "ko_kr"
                local newItemName = "{{Collectible" .. id .. "}} " .. EID:getObjectName(5, 100, id)
                return eidKor and ("{{ColorYellow}}" .. newItemName .. "{{CR}}(으)로 변환") or ("Rerolls to {{ColorYellow}}" .. newItemName .. "{{CR}}")
            end

            local function ChronosModifierCondition(descObj)
                if descObj.ObjType == 5 and descObj.ObjVariant == 100 then
                    local numPlayers = Game():GetNumPlayers()
                    for i = 0, numPlayers - 1 do
                        local player = Isaac.GetPlayer(i)
                        if player:HasCollectible(Astro.Collectible.CHRONOS) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(Astro.Collectible.CHRONOS)]) then
                            return true
                        end
                    end
                end
            end

            local function ChronosModifierCallback(descObj)
                for targetItemId, newItemId in pairs(returnItems) do
                    if descObj.ObjSubType == targetItemId then
                        local iconStr = "#{{Collectible" .. Astro.Collectible.CHRONOS .. "}} "
                        local text = GetMorphString(newItemId)
                        EID:appendToDescription(descObj, iconStr .. text)
                    end
                end
                return descObj
            end

            EID:addDescriptionModifier("Chronos Modifier", ChronosModifierCondition, ChronosModifierCallback)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local success = false
        local game = Game()
        local sfx = SFXManager()
        if SoundEffect.SOUND_ITEM_RAISE and sfx:IsPlaying(SoundEffect.SOUND_ITEM_RAISE) then
            sfx:Stop(SoundEffect.SOUND_ITEM_RAISE)
        end

        local collectibles = Isaac.FindByType(5, 100)
        if #collectibles > 0 then
            for _, collectible in pairs(collectibles) do
                local item = collectible:ToPickup()

                for targetItemId, newItemId in pairs(returnItems) do
                    if item.SubType == targetItemId then
                        item:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItemId, true)
                        game:MakeShockwave(item.Position, 0.1, 0.02, 20)
                        success = true
                    end
                end
            end
        end

        if success then
            local backdropType = game:GetRoom():GetBackdropType()
            game:ShowHallucination(40, backdropType)

            if sfx:IsPlaying(SoundEffect.SOUND_DEATH_CARD) then
                sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
            end
            sfx:Play(Astro.SoundEffect.CHRONOS)
            
            return {
                Discharge = true,
                Remove = false,
                ShowAnim = true,
            }
        else
            playerWhoUsedItem:AnimateSad()
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end
    end,
    Astro.Collectible.CHRONOS
)
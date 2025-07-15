if not REPENTOGON then return end

---@class PlayerEffectInfo
---@field type "collectible"|"null"
---@field id integer

---@param player EntityPlayer
---@param condition fun(): boolean
---@param effectInfo PlayerEffectInfo
function Astro:RegisterPersistentPlayerEffect(player, condition, effectInfo)
    local data = Astro.SaveManager.GetRunSave(player)
    
    if not data["persistentPlayerEffects"] then
        ---@type {condition: fun(): boolean, info: PlayerEffectInfo}[]
        data["persistentPlayerEffects"] = {}
    end

    table.insert(data["persistentPlayerEffects"], {
        condition = condition,
        info = effectInfo
    })
end


Astro:AddPriorityCallback(
    ModCallbacks.MC_PRE_PLAYER_UPDATE,
    CallbackPriority.LATE,
    ---@param player EntityPlayer
    function (_, player)
        local data = Astro.SaveManager.GetRunSave(player)

        if data["playerEffectsQueue"] and #data["playerEffectsQueue"] > 0 then
            local removeList = {}

            for i, info in ipairs(data["playerEffectsQueue"]) do
                if info.type == "collectible" then
                    if not player:GetEffects():HasCollectibleEffect(info.id) then
                        player:GetEffects():AddCollectibleEffect(info.id)
                    end
                elseif info.type == "null" then
                    if not player:GetEffects():HasNullEffect(info.id) then
                        player:GetEffects():AddNullEffect(info.id)
                    end
                end
                
                table.insert(removeList, i)
            end

            for _, index in ipairs(removeList) do
                data["playerEffectsQueue"][index] = nil
            end
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED,
    CallbackPriority.LATE,
    ---@param player EntityPlayer
    ---@param itemConfigItem ItemConfigItem
    function (_, player, itemConfigItem)
        local data = Astro.SaveManager.GetRunSave(player)

        if not data["playerEffectsQueue"] then
            data["playerEffectsQueue"] = {}
        end

        if data["persistentPlayerEffects"] then
            for _, effect in ipairs(data["persistentPlayerEffects"]) do
                local type = effect.info.type
                local id = effect.info.id

                if id == itemConfigItem.ID and effect.condition() then
                    if type == "collectible" and itemConfigItem:IsCollectible() and id == itemConfigItem.ID then
                        table.insert(data["playerEffectsQueue"], effect.info)
                        break
                    elseif type == "null" and itemConfigItem:IsNull() and id == itemConfigItem.ID then
                        table.insert(data["playerEffectsQueue"], effect.info)
                        break
                    end
                end
            end
        end
    end
)

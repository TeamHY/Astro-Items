---

local UPGRADE_CHANCE = 0.2

local MARK_DURATION = 60 * 30

---

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.BLACK_LIST = Isaac.GetItemIdByName("Black List")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BLACK_LIST,
                "블랙 리스트",
                "...",
                "{{Collectible530}}Death's List 효과가 적용됩니다." ..
                "#방 입장 시 1분간 Brimstone Mark가 적용됩니다." ..
                "#!!! 소지중일 때 {{Collectible530}}Death's List가 등장하지 않습니다."
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.BLACK_LIST) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_DEATHS_LIST,
                        modifierName = "Black List"
                    }
                end
        
                return false
            end
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if selectedCollectible == CollectibleType.COLLECTIBLE_DEATHS_LIST then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.BLACK_LIST)

            if rng:RandomFloat() < UPGRADE_CHANCE then
                return Astro.Collectible.BLACK_LIST
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.BLACK_LIST) then
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
                    local data = entity:GetData()
                    data["blackList"] = true

                    entity:AddEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local room = Game():GetRoom()
        
        if room:GetFrameCount() == MARK_DURATION then
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                local data = entity:GetData()
                
                if data["blackList"] then
                    entity:ClearEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
                end
            end
        end

        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_DEATHS_LIST, player:HasCollectible(Astro.Collectible.BLACK_LIST) and 1 or 0, "ASTRO_BLACK_LIST")
    end
)

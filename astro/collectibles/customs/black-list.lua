---

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
                "!!! 소지중일 때 {{Collectible530}}Death's List 미등장" ..
                "{{DeathMark}} 해골마크가 뜬 적을 순차적으로 처치 시 픽업이 드랍되거나 랜덤 능력치가 하나 증가합니다." ..
                "#방 입장 시 그 방의 적에게 1분간 혈사류 공격에 공격력 x2 +3의 피해를 주는 {{BrimstoneCurse}}유황 표식이 걸립니다."
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

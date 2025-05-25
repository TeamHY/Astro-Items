Astro.Trinket.YES = Isaac.GetTrinketIdByName("Yes!")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            EID:addTrinket(
                Astro.Trinket.YES,
                "패시브 아이템 등장 시 리롤됩니다." ..
                "#리롤된 아이템은 콘솔창에서 확인할 수 있습니다",
                "좋아!"
            )
        
            Astro:AddGoldenTrinketDescription(Astro.Trinket.YES, "", 10)
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)
        
                if Astro:HasTrinket(Astro.Trinket.YES) then
                    return {
                        reroll = itemConfigitem.Type ~= ItemType.ITEM_ACTIVE,
                        modifierName = "Yes!"
                    }
                end
        
                return false
            end
        )
    end
)

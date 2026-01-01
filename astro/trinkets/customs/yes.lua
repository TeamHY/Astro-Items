Astro.Trinket.YES = Isaac.GetTrinketIdByName("Yes!")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddTrinket(
                Astro.Trinket.YES,
                "좋아!",
                "필요해!",
                "모든 액티브 아이템이 등장하기 전까지 패시브 아이템이 등장하지 않습니다." ..
                "#리롤된 패시브 아이템은 콘솔창에서 확인할 수 있습니다."
            )

            Astro.EID:AddTrinket(
                Astro.Trinket.YES,
                "Yes!",
                "",
                "Prevents passive items from spawning",
                nil, "en_us"
            )
            
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

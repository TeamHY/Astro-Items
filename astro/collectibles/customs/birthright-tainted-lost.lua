local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_TAINTED_LOST = Isaac.GetItemIdByName("Birthright - Tainted Lost")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_TAINTED_LOST,
                "더럽혀진 로스트의 생득권",
                "...",
                "offensive 태그 아이템 등장 시 다른 아이템으로 바꿉니다." ..
                "#리롤된 아이템은 콘솔에서 확인할 수 있습니다."
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)
        
                if Astro:HasCollectible(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST) then
                    return {
                        reroll = not itemConfigitem:HasTags(ItemConfig.TAG_OFFENSIVE),
                        modifierName = "Birthright - Tainted Lost"
                    }
                end
        
                return false
            end
        )
    end
)

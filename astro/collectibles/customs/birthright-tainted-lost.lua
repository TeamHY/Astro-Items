local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_TAINTED_LOST = Isaac.GetItemIdByName("Birthright - Tainted Lost")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_TAINTED_LOST,
                "알트 로스트의 생득권",
                "...",
                "offensive 태그가 없는 아이템 등장 시 리롤됩니다."
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)
        
                if Astro:HasCollectible(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST) then
                    return not itemConfigitem:HasTags(ItemConfig.TAG_OFFENSIVE)
                end
        
                return false
            end
        )
    end
)

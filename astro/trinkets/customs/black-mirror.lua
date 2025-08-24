local isc = require("astro.lib.isaacscript-common")

Astro.Trinket.BLACK_MIRROR = Isaac.GetTrinketIdByName("Black Mirror")

if EID then
    Astro:AddEIDTrinket(
        Astro.Trinket.BLACK_MIRROR,
        "검은 거울",
        "모든 벽, 모든 책상, 모든 손바닥에 있는",
        "{{Collectible347}} 패시브 아이템 획득 시 그 아이템을 한번 더 획득하며;" ..
        "#{{ArrowGrayRight}} 획득 이후 이 장신구는 사라집니다."
    )

    -- Astro:AddGoldenTrinketDescription(Astro.Trinket.BLACK_MIRROR, "", 10)
end

-- Astro:AddCallback(
--     ModCallbacks.MC_POST_PEFFECT_UPDATE,
--     ---@param player EntityPlayer
--     function(_, player)
--         local trinket0 = player:GetTrinket(0)
--         local trinket1 = player:GetTrinket(1)

--         if Astro:CheckTrinket(trinket0, Astro.Trinket.BLACK_MIRROR) then
--             player:TryRemoveTrinket(trinket0)
--             isc:smeltTrinket(player, Astro.Trinket.BLACK_MIRROR)
--         elseif Astro:CheckTrinket(trinket1, Astro.Trinket.BLACK_MIRROR) then
--             player:TryRemoveTrinket(trinket1)
--             isc:smeltTrinket(player, Astro.Trinket.BLACK_MIRROR)
--         end
--     end
-- )

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:HasTrinket(Astro.Trinket.BLACK_MIRROR) then
            local itemConfigItem = Isaac.GetItemConfig():GetCollectible(collectibleType)

            if itemConfigItem.Type ~= ItemType.ITEM_ACTIVE then
                player:AddCollectible(collectibleType)
                player:TryRemoveTrinket(Astro.Trinket.BLACK_MIRROR)
            end
        end
    end
)

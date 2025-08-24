---

local COOLDOWN = 300

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SATURNUS_EX = Isaac.GetItemIdByName("SATURNUS EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SATURNUS_EX,
                "초 토성",
                "눈물 방어막",
                "!!! 획득 이후 {{Collectible595}}Saturnus 미등장" ..
                "#{{Collectible595}} Saturnus 효과가 적용됩니다." ..
                "#{{Collectible522}} 10초마다 3초간 캐릭터에게 날아오는 적의 탄환을 붙잡습니다." ..
                "#{{ArrowGrayRight}} 3초가 끝나면 붙잠은 탄환을 다시 되돌려 발사합니다.",
                -- 중첩 시
                "중첩된 수만큼 Telekinesis 발동"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if Game():GetFrameCount() % COOLDOWN == 0 then
            if player:HasCollectible(Astro.Collectible.SATURNUS_EX) then
                for _ = 1, player:GetCollectibleNum(Astro.Collectible.SATURNUS_EX) do
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEKINESIS, false, true, false, false)
                end
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SATURNUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SATURNUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SATURNUS)
        end
    end,
    Astro.Collectible.SATURNUS_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SATURNUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SATURNUS)
        end
    end,
    Astro.Collectible.SATURNUS_EX
)

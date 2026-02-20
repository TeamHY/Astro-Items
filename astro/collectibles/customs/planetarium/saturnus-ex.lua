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
            local cooldown = string.format("%.f", COOLDOWN / 30)

            Astro.EID:AddCollectible(
                Astro.Collectible.SATURNUS_EX,
                "초 토성",
                "눈물 방어막",
                "{{Collectible595}} Saturnus 효과 발동:" ..
                "#{{IND}} 캐릭터 주변에 하얀 고리가 생기며 방 입장 시 고리를 따라 움직이는 눈물이 7개 생성됩니다." ..
                "#{{IND}} 하얀 고리의 눈물은 캐릭터의 공격력 x1.5 +5의 피해를 줍니다." ..
                "#{{IND}} 고리에 적의 탄환이 닿을 시 확률적으로 13초동안 고리를 따라 회전합니다." ..
                "#{{Collectible522}} " .. cooldown .. "초마다 Telekinesis 효과 발동:" ..
                "#{{IND}} 3초간 캐릭터에게 날아오는 적의 탄환을 붙잡습니다." ..
                "#{{IND}} 3초가 끝나면 붙잡은 탄환을 다시 되돌려 발사합니다.",
                -- 중첩 시
                "중첩 시 중첩된 수만큼 Telekinesis 발동"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.SATURNUS_EX,
                "Saturnus EX", "",
                "{{Collectible595}} Saturnus effect applied:" ..
                "#{{IND}} Entering a room causes 7 tears to orbit Isaac" ..
                "#{{IND}} Those tears last for 13 seconds and deal 1.5x Isaac's damage +5" ..
                "#{{IND}} Enemy projectiles have a chance to orbit Isaac" ..
                "#{{Collectible522}} Telekinesis activates every " .. cooldown .. " seconds:" ..
                "#{{IND}} Stops all enemy projectiles that come close to Isaac for 3 seconds and throws them away from him afterwards" ..
                "#{{IND}} Pushes close enemies away during the effect",
                -- Stacks
                "Stacks increase the number of times Telekinesis can be activated",
                "en_us"
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

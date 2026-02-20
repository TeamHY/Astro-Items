---

-- 중첩 시 0.5 -> 0.75 -> 0.875
local SOUL_CAIN_CHANCE = 0.5

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.MERCURIUS_EX = Isaac.GetItemIdByName("MERCURIUS EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local chance = string.format("%.f", SOUL_CAIN_CHANCE * 100)

            Astro.EID:AddCollectible(
                Astro.Collectible.MERCURIUS_EX,
                "초 수성",
                "열려라 참깨",
                "{{Collectible590}} Mercurius 효과 발동:" ..
                "#{{IND}}↑ {{SpeedSmall}}이동속도 +0.4" ..
                "#{{IND}} 클리어하지 않은 방의 문이 닫히지 않습니다." ..
                "#{{IND}}{{ArrowGrayRight}} 특수방의 문은 열리지 않습니다." ..
                "#{{Card83}} 방 클리어 시 " .. chance .. "% 확률로 그 방의 닫혀있는 문을 열며 가능한 경우 방의 각 면의 빨간방으로 가는 문을 모두 엽니다.",
                -- 중첩 시
                "중첩 시 열릴 확률 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.MERCURIUS_EX,
                "Mercurius EX", "",
                "{{Collectible590}} Mercurius effect applied:" ..
                "#{{IND}}↑ {{Speed}} +0.4 Speed" ..
                "#{{IND}} Most doors stay permanently open" ..
                "#{{Card83}} " .. chance .. "% chance to open all doors in the room and create red rooms on every wall possible",
                -- Stacks
                "Stacks increase chance",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.MERCURIUS_EX) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.MERCURIUS_EX)

                if rng:RandomFloat() < 1 - ((1 - SOUL_CAIN_CHANCE) ^ player:GetCollectibleNum(Astro.Collectible.MERCURIUS_EX)) then
                    player:UseCard(Card.CARD_SOUL_CAIN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
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
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_MERCURIUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MERCURIUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_MERCURIUS)
        end
    end,
    Astro.Collectible.MERCURIUS_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MERCURIUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_MERCURIUS)
        end
    end,
    Astro.Collectible.MERCURIUS_EX
)

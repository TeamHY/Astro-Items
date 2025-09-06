---

local COOLDOWN = 150

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.JUPITER_EX = Isaac.GetItemIdByName("JUPITER EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.JUPITER_EX,
                "초 목성",
                "가스 초거성이다!",
                "!!! 획득 이후 {{Collectible594}}Jupiter 미등장" ..
                "#{{Card71}} 최초 획득 시 {{Collectible33}}The Bible을 사용하며 30초간 비행 상태가 되고 {{Collectible390}}Seraphim 패밀리어를 소환합니다." ..
                "#{{Collectible594}} Jupiter, {{Collectible180}}Black Bean 효과가 적용됩니다." ..
                "#{{Collectible486}} 5초마다 피해를 입지 않고 피격 시 발동 효과를 발동합니다.",
                -- 중첩 시
                "피격 시 발동 효과가 중첩된 수만큼 발동"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if Game():GetFrameCount() % COOLDOWN == 0 then
            if player:HasCollectible(Astro.Collectible.JUPITER_EX) then
                for _ = 1, player:GetCollectibleNum(Astro.Collectible.JUPITER_EX) do
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, false, true, false, false)
                    SFXManager():Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
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
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_JUPITER)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_JUPITER) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_JUPITER)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_BLACK_BEAN)

            player:UseCard(Card.CARD_REVERSE_DEVIL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end
    end,
    Astro.Collectible.JUPITER_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_JUPITER) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_JUPITER)
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_BLACK_BEAN)
        end
    end,
    Astro.Collectible.JUPITER_EX
)

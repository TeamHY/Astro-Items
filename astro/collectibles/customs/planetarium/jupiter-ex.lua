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
            Astro.EID:AddCollectible(
                Astro.Collectible.JUPITER_EX,
                "초 목성",
                "방독면도 소용없다",
                "{{Timer}} 획득 시 30초 동안:" ..
                "#{{IND}}{{Collectible33}} The Bible을 사용하며 비행 능력을 얻습니다." ..
                "#{{IND}}{{Collectible390}} Seraphim 패밀리어를 소환합니다." ..
                "#{{Collectible594}} Jupiter 효과 발동:" ..
                "#{{IND}}↓ {{SpeedSmall}}이동속도 -0.3" ..
                "#{{IND}}{{Poison}} 이동하지 않으면 이동속도가 0.5 증가하며, 증가한 상태에서 이동 시 공격력 x0.5의 독가스를 발사하고 이동속도가 다시 감소합니다." ..
                "#{{IND}}캐릭터가 독구름에 면역이 됩니다." ..
                "#{{Collectible180}} Black Bean + {{Collectible486}} Dull Razor 효과 발동:" ..
                "#{{IND}} " .. string.format("%.f", COOLDOWN / 30) .. "초마다 탄환을 튕겨내는 독방귀와 독가스를 여러번 뀝니다.",
                -- 중첩 시
                "중첩 시 피격 효과가 중첩된 수만큼 발동"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.JUPITER_EX,
                "Jupiter EX", "",
                "{{Timer}} Receive for 30 seconds on pickup:" ..
                "#{{IND}}{{Collectible33}} Activates The Bible (flight)" ..
                "#{{IND}}{{Collectible390}} Seraphim familiar" ..
                "#{{Collectible594}} Jupiter effect applied:" ..
                "#{{IND}}↓ {{Speed}} -0.3 Speed" ..
                "#{{IND}}{{Speed}} Speed builds up to +0.5 while standing still; moving releases poison clouds" ..
                "#{{IND}}{{Poison}} Poison immunity" ..
                "#{{Collectible180}} Black Bean + {{Collectible486}} Dull Razor effect applied:" ..
                "#{{IND}} Isaac farts multiple times every " .. string.format("%.f", COOLDOWN / 30) .. " seconds",
                -- Stacks
                "Stacks enhance on-hit item effects",
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
            if player:HasCollectible(Astro.Collectible.JUPITER_EX) then
                for _ = 1, player:GetCollectibleNum(Astro.Collectible.JUPITER_EX) do
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, false, true, false, false)

                    local sfx = SFXManager()
                    if SoundEffect.SOUND_DULL_RAZOR and sfx:IsPlaying(SoundEffect.SOUND_DULL_RAZOR) then
                        sfx:Stop(SoundEffect.SOUND_DULL_RAZOR)
                    end
                    sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
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

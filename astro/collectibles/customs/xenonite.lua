---

local INVINCIBLE_INTERVAL = 60 * 30
local INVINCIBLE_DURATION = 10 * 30

---

Astro.Collectible.XENONITE = Isaac.GetItemIdByName("Xenonite")

local ITEM_ID = Astro.Collectible.XENONITE

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "제노나이트",
                "에리디언이 사용하는 초고성능 소재",
                "!!! {{Collectible" .. Astro.Collectible.ROCKY .. "}}Rocky를 소지하고 있지 않으면 다른 아이템으로 바뀝니다." ..
                "#{{Collectible58}} 게임 시간 " .. (INVINCIBLE_INTERVAL / 30) .. "초마다 " .. (INVINCIBLE_DURATION / 30) .. "초간 무적 상태가 됩니다.",
                -- 중첩 시
                "중첩 시 발동 주기가 중첩된 수만큼 나눠지며, 무적 시간이 중첩된 수만큼 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Xenonite", "",
                "!!! Rerolled into another item unless {{Collectible" .. Astro.Collectible.ROCKY .. "}}Rocky is held" ..
                "#{{Collectible58}} Invincibility for " .. (INVINCIBLE_DURATION / 30) .. " seconds every " .. (INVINCIBLE_INTERVAL / 30) .. " seconds of game time",
                -- Stacks
                "Stacks divide the interval and increase the invincibility duration",
                "en_us"
            )
        end

        Astro:AddRerollCondition(
            ---@param selectedCollectible CollectibleType
            function(selectedCollectible)
                if selectedCollectible ~= ITEM_ID then
                    return false
                end

                return {
                    reroll = not Astro:HasCollectible(Astro.Collectible.ROCKY),
                    modifierName = "Xenonite"
                }
            end
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local itemNum = player:GetCollectibleNum(ITEM_ID)

        if itemNum <= 0 then
            return
        end

        local data = Astro:GetPersistentPlayerData(player)

        if not data then
            return
        end

        local frameCount = Game():GetFrameCount()
        local interval = math.max(1, math.floor(INVINCIBLE_INTERVAL / itemNum))

        if frameCount % interval == 0 then
            data["xenoniteInvincibleEndFrame"] = frameCount + INVINCIBLE_DURATION * itemNum
        end

        if (data["xenoniteInvincibleEndFrame"] or 0) > frameCount then
            if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS) then
                player:UseActiveItem(
                    CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS,
                    UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER
                )
            end
        end
    end
)

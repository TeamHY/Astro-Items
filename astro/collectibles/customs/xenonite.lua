---

local INVINCIBLE_INTERVAL = 60 * 30

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
                "#{{Collectible58}} 게임 시간 " .. (INVINCIBLE_INTERVAL / 30) .. "초마다 " .. "10초간 무적 상태가 됩니다.",
                -- 중첩 시
                "중첩 시 발동 주기가 짧아지며 무적 지속 시간이 길어집니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Xenonite", "",
                "#{{Collectible58}} Invincibility for 10 seconds every " .. (INVINCIBLE_INTERVAL / 30) .. " seconds of game time",
                -- Stacks
                "Stacks shorten the interval and increase the invincibility duration",
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
            for _ = 1, itemNum do
                player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)
            end
        end
    end
)

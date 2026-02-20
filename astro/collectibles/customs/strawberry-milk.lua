---

local DELAY_TIME = 60

local TEARS_INCREMENT = 0.25

---

Astro.Collectible.STRAWBERRY_MILK = Isaac.GetItemIdByName("Strawberry Milk")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.STRAWBERRY_MILK,
                "딸기 우유",
                "공격 속도 증가 + 추가 눈물",
                "↑ {{TearsSmall}}연사(+상한) +" .. TEARS_INCREMENT ..
                "#" .. string.format("%.f", DELAY_TIME / 30) .. "초마다 대각선 4방향으로 공격력 x0.5의 유도 눈물을 발사합니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.STRAWBERRY_MILK,
                "Strawberry Milk", "",
                "↑ {{Tears}} +" .. TEARS_INCREMENT .. " Fire rate" ..
                "#Fires homing tears dealing x0.5 Isaac's damage in 4 diagonal directions every " .. string.format("%.f", DELAY_TIME / 30) .. " seconds",
                nil, "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.STRAWBERRY_MILK) then
            local data = player:GetData()

            if (data["StrawberryMilkDelay"] == nil or data["StrawberryMilkDelay"] <= Game():GetFrameCount()) and not Game():GetRoom():IsClear() then
                if player.FireDelay ~= -1 then
                    for i = 1, 4 do
                        local tear = player:FireTear(player.Position, Vector(2, 2):Rotated(i * 90), true, true, false):ToTear()
                        tear.CollisionDamage = player.Damage / 2
                        tear.Scale = 0.8
                        tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING
                    end

                    data["StrawberryMilkDelay"] = Game():GetFrameCount() + DELAY_TIME
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.STRAWBERRY_MILK) then
            if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
                player.TearColor = Color(0.933, 0.6, 0.6, 1, 0, 0, 0)
            end
            if cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, TEARS_INCREMENT)
            end
        end
    end
)

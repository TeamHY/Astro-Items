---

local DELAY_TIME = 60

local TEARS_INCREMENT = 1

---

Astro.Collectible.STRAWBERRY_MILK = Isaac.GetItemIdByName("Strawberry Milk")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.STRAWBERRY_MILK,
                "딸기 우유",
                "...",
                "↑ {{TearsSmall}}연사(고정) +1" ..
                "공격 시 대각선 4방향으로 유도 눈물을 발사합니다."
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

Astro.Collectible.ACUTE_SINUSITIS = Isaac.GetItemIdByName("Acute Sinusitis")

---

local SPAWN_CHANCE = 0.1

local LUCK_MULTIPLY = 1 / 50

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.ACUTE_SINUSITIS,
                "급성 부비동염",
                "맛있는 코딱지",
                string.format("%.f", SPAWN_CHANCE * 100) .. "%의 확률로 접착 눈물이 나갑니다." ..
                "#{{LuckSmall}} 행운 45 이상일 때 100% 확률 (행운 1당 +2%p)",
                -- 중첩 시
                "중첩 시 발사 확률이 합연산으로 증가"
            )
            
            Astro.EID:AddCollectible(
                Astro.Collectible.ACUTE_SINUSITIS,
                "Acute Sinusitis", "",
                string.format("%.f", SPAWN_CHANCE * 100) .. "% chance for sticky tears (+2%p per Luck)",
                -- Stacks
                "Stacks increase chance",
                "en_us"
            )
            
            Astro.EID.LuckFormulas["5.100." .. tostring(Astro.Collectible.ACUTE_SINUSITIS)] = function(luck, num)
                return ((SPAWN_CHANCE * num * 100) + (luck * LUCK_MULTIPLY * 100))
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)

        if player ~= nil then
            if player:HasCollectible(Astro.Collectible.ACUTE_SINUSITIS) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.ACUTE_SINUSITIS)
                local baseChance = SPAWN_CHANCE * player:GetCollectibleNum(Astro.Collectible.ACUTE_SINUSITIS);

                if rng:RandomFloat() < baseChance + player.Luck * LUCK_MULTIPLY then
                    tear:ChangeVariant(TearVariant.BOOGER)
                    tear.TearFlags = tear.TearFlags | TearFlags.TEAR_BOOGER
                    tear.Color = Color(0.4, 0.97, 0.5, 1, 0, 0, 0)
                end
            end
        end
    end
)

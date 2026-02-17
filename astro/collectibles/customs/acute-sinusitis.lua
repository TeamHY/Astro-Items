local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.ACUTE_SINUSITIS = Isaac.GetItemIdByName("Acute Sinusitis")

---

local SPAWN_CHANCE = 0.1

local LUCK_MULTIPLY = 1 / 50

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_SINUS_INFECTION].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible459}}{{ColorYellow}}축농증{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible459}} {{ColorYellow}}Sinus Infection{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.ACUTE_SINUSITIS, CRAFT_HINT)
            
            Astro.EID:AddCollectible(
                Astro.Collectible.ACUTE_SINUSITIS,
                "급성 부비동염",
                "맛있는 코딱지",
                "{{Collectible459}} 20%의 확률로 공격에 접착 속성이 생깁니다." ..
                "#" .. string.format("%.f", SPAWN_CHANCE * 100) .. "%의 확률로 접착 눈물이 나갑니다." ..
                "#접착 눈물이 적에게 붙을 시 10초동안 초당 캐릭터의 공격력 x1.0의 피해를 줍니다." ..
                "#{{LuckSmall}} 행운 45 이상일 때 100% 확률 (행운 1당 +2%p)",
                -- 중첩 시
                "중첩 시 접착 눈물 발사 확률이 합연산으로 증가"
            )
            
            Astro.EID:AddCollectible(
                Astro.Collectible.ACUTE_SINUSITIS,
                "Acute Sinusitis", "",
                "{{Collectible459}} 20% chance to grant the sticky property to attacks (Not affected by luck)" ..
                "#" .. string.format("%.f", SPAWN_CHANCE * 100) .. "% chance shoot a for sticky booger (+2%p per Luck)" ..
                "#{{Damage}} Boogers deal Isaac's damage once a second and stick for 10 seconds",
                -- Stacks
                "Stacks increase the chance of shooting a booger",
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

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.ACUTE_SINUSITIS) then
            return
        end

        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_SINUS_INFECTION, 1, "ASTRO_ACUTE_SINUSITIS")
    end
)
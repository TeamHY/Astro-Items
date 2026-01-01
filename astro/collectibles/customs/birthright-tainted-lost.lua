Astro.Collectible.BIRTHRIGHT_TAINTED_LOST = Isaac.GetItemIdByName("Tainted Lost's Frame")

---

local REROLL_CHANCE_BASE = 0.2

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local rgon = REPENTOGON and "↑ 목숨 +1#" or ""
            local rgonEng = REPENTOGON and "↑ +1 Life#" or ""

            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_TAINTED_LOST,
                "더 로스트의 액자?",
                "더 나은 운명?",
                rgon ..
                "{{Quality0}}~{{Quality2}}등급 아이템 등장 시 " .. string.format("%.f", REROLL_CHANCE_BASE * 10) .."%의 확률로 다른 아이템으로 바꿉니다." ..
                "#{{Blank}} {{ColorGray}}(바뀐 아이템은 콘솔에서 확인 가능){{CR}}",
                -- 중첩 시
                "중첩할 때마다 바뀔 확률이 +20%p씩 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_TAINTED_LOST,
                "Tainted Lost's Frame",
                "",
                rgonEng ..
                string.format("%.f", REROLL_CHANCE_BASE * 10) .. "% chance to rerolls {{Quality0}}/{{Quality1}}/{{Quality2}} items into other items." ..
                "#{{Blank}} {{ColorGray}}(Rerolled items viewable in console){{CR}}",
                -- 중첩 시
                "Each time it stacks, the chance increases by 20%p",
                "en_us"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)
                
                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)
                    if Astro:HasCollectible(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST) then
                        local num = player:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST)
                        local rng = player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST)

                        if rng:RandomFloat() < (REROLL_CHANCE_BASE * num) then
                            return {
                                reroll = itemConfigitem.Quality <= 2,
                                modifierName = "Tainted Lost's Frame"
                            }
                        end
                    end
                end
        
                return false
            end
        )
    end
)

if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH,
        function(_, player)
            if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST, true) then
                player:RemoveCollectible(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST)
                player:SetMinDamageCooldown(120)
                return false
            end
        end
    )
end

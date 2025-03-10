---

Astro.BIRTHRIGHT_CAIN_CHANCE = 0.25

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_CAIN = Isaac.GetItemIdByName("Birthright - Cain")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_CAIN,
                "생득권 - 케인",
                "...",
                "슬롯머신에 동전을 소비할 때 25% 확률로 동전이 소비되지 않습니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        Astro.Data.BirthrightCain = {
            prevCoin = Isaac.GetPlayer():GetNumCoins()
        }
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_COLLISION,
    ---@param slot Entity
    ---@param entity Entity
    function(_, slot, entity)
        local player = entity:ToPlayer()

        if player and player:HasCollectible(Astro.Collectible.BIRTHRIGHT_CAIN) then
            Astro.Data.BirthrightCain.prevCoin = player:GetNumCoins()

            Astro:ScheduleForUpdate(
                function()
                    local rng = player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_CAIN)

                    if Astro.Data.BirthrightCain.prevCoin > player:GetNumCoins() and rng:RandomFloat() < Astro.BIRTHRIGHT_CAIN_CHANCE then
                        player:AddCoins(Astro.Data.BirthrightCain.prevCoin - player:GetNumCoins())
                    end

                    Astro.Data.BirthrightCain.prevCoin = player:GetNumCoins()
                end,
                1
            )
        end
    end
)

-- astro/entities/astro-crane-game.lua에 추가 구현 있음.

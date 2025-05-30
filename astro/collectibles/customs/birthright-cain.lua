---

Astro.BIRTHRIGHT_CAIN_CHANCE = 0.25

local CRANE_GAME_CHANGE_CHANCE = 1.0

---

local isc = require("astro.lib.isaacscript-common")

local INIT_CHECK_SUBTYPE = 1000

Astro.Collectible.BIRTHRIGHT_CAIN = Isaac.GetItemIdByName("Birthright - Cain")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_CAIN,
                "카인의 생득권",
                "...",
                "{{Slotmachine}} 슬롯머신에 동전을 소비할 때 25% 확률로 동전이 소비되지 않습니다." ..
                "#{{ArcadeRoom}} 야바위를 {{CraneGame}}크레인 게임으로 변경합니다."
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

-- 야바위 게임
Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_CAIN) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_CAIN)

                if slot.SubType ~= INIT_CHECK_SUBTYPE and rng:RandomFloat() < CRANE_GAME_CHANGE_CHANCE then
                    slot:Remove()
                    Isaac.Spawn(EntityType.ENTITY_SLOT, 16, 0, slot.Position, Vector(0, 0), nil)
                elseif slot.SubType ~= INIT_CHECK_SUBTYPE then
                    slot.SubType = INIT_CHECK_SUBTYPE
                end
            end

            break
        end
    end,
    6
)

-- 악마 야바위 게임
Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_CAIN) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_CAIN)

                if slot.SubType ~= INIT_CHECK_SUBTYPE and rng:RandomFloat() < CRANE_GAME_CHANGE_CHANCE then
                    slot:Remove()
                    Isaac.Spawn(EntityType.ENTITY_SLOT, 16, 0, slot.Position, Vector(0, 0), nil)
                elseif slot.SubType ~= INIT_CHECK_SUBTYPE then
                    slot.SubType = INIT_CHECK_SUBTYPE
                end
            end

            break
        end
    end,
    15
)

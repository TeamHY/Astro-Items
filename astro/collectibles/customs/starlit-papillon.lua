---

-- 스택당 배수 증가량
local DAMAGE_PER_SOUL = 0.01

-- 최대 스택
local MAXIMUM = 50

-- 용사 관련 캐릭터일 경우 최대 스택
local MAXIMUM_FOR_ADVENTURER = 100

-- 스택 감소량
local SOUL_DECREASE = 5

-- 용사 관련 캐릭터일 경우 스택 감소량
local SOUL_DECREASE_FOR_ADVENTURER = 10

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.STARLIT_PAPILLON = Isaac.GetItemIdByName("Starlit Papillon")

-- local useSound = Isaac.GetSoundIdByName('Specialsummon')
-- local useSoundVoulme = 1 -- 0 ~ 1
Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.STARLIT_PAPILLON,
                "스타리트 파피용",
                "용사 파티의 길라잡이",
                "적 처치 시 영혼을 흡수하며;" ..
                "#{{ArrowGrayRight}} 적 명중 시 영혼 1개당 1%p의 추가 피해를 입힙니다." ..
                "#{{ArrowGrayRight}} 영혼은 최대 " .. MAXIMUM .. "개까지 저장할 수 있습니다." ..
                "#{{ArrowGrayRight}} 방 클리어 시 영혼이 " .. SOUL_DECREASE .. "개 감소합니다." ..
                "#소지중일 때 {{Collectible492}}YO LISTEN! 효과가 적용됩니다."
            )

            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.STARLIT_PAPILLON),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                {
                    "최대 " .. MAXIMUM .. "개까지 저장할 수 있습니다.#{{ArrowGrayRight}} 방 클리어 시 영혼이 " .. SOUL_DECREASE .. "개 감소",
                    "최대 {{ColorIsaac}}" .. MAXIMUM_FOR_ADVENTURER .. "{{CR}}개까지 저장할 수 있습니다.#{{ArrowGrayRight}} 방 클리어 시 영혼이 {{ColorIsaac}}" .. SOUL_DECREASE_FOR_ADVENTURER .. "{{CR}}개 감소"
                },
                nil, "ko_kr", nil
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
             Astro.Data.StarlitPapillon = {
                Souls = 0
             }
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.STARLIT_PAPILLON) then
                if Astro:IsWaterEnchantress(player) then
                    Astro.Data.StarlitPapillon.Souls = Astro.Data.StarlitPapillon.Souls - SOUL_DECREASE_FOR_ADVENTURER
                else
                    Astro.Data.StarlitPapillon.Souls = Astro.Data.StarlitPapillon.Souls - SOUL_DECREASE
                end

                if Astro.Data.StarlitPapillon.Souls < 0 then
                    Astro.Data.StarlitPapillon.Souls = 0
                end
            end
        end
    end
)

-- Astro:AddCallback(
--     ModCallbacks.MC_USE_ITEM,
--     ---@param collectibleID CollectibleType
--     ---@param rngObj RNG
--     ---@param playerWhoUsedItem EntityPlayer
--     ---@param useFlags UseFlag
--     ---@param activeSlot ActiveSlot
--     ---@param varData integer
--     function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
--         if Astro.Data.StarlitPapillon.Souls > 0 then
--             local data = Astro:GetPersistentPlayerData(playerWhoUsedItem)

--             data.StarlitPapillonDamageMultiplier = Astro.Data.StarlitPapillon.Souls * DAMAGE_PER_SOUL

--             Astro.Data.StarlitPapillon.Souls = 0

--             SFXManager():Play(useSound, useSoundVoulme)

--             return true
--         end
--     end,
--     Astro.Collectible.STARLIT_PAPILLON
-- )

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(Astro.Collectible.STARLIT_PAPILLON) then
            if Astro.Data.StarlitPapillon and Astro.Data.StarlitPapillon.Souls > 0 then
                if source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE then
                    entity:TakeDamage(amount * Astro.Data.StarlitPapillon.Souls * DAMAGE_PER_SOUL, 0, EntityRef(player), 0)
                end
            end
        end
    end
)


-- TODO: 소울 하나로 통합하기
Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.STARLIT_PAPILLON) then
                local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_SOUL, 0, npc.Position, Vector.Zero, player)

                local data = soul:GetData()
                data.StarlitPapillon = {
                    player = player,
                }

                -- local rng = player:GetCollectibleRNG(Astro.Collectible.STARLIT_PAPILLON)
                -- soul:AddVelocity(Vector.FromAngle(rng:RandomInt(360)):Resized(200))

                break
            end
        end
    end
)

Astro:AddCallback(
	ModCallbacks.MC_POST_EFFECT_UPDATE,
	---@param effect EntityEffect
	function(_, effect)
        local data = effect:GetData()

        if data.StarlitPapillon then
            local player = data.StarlitPapillon.player

            effect:AddVelocity((player.Position - effect.Position):Resized(20))

            if effect.Position:Distance(player.Position) < 10 then
                Astro.Data.StarlitPapillon.Souls = Astro.Data.StarlitPapillon.Souls + 1

                if Astro:IsWaterEnchantress(player) then
                    if Astro.Data.StarlitPapillon.Souls > MAXIMUM_FOR_ADVENTURER then
                        Astro.Data.StarlitPapillon.Souls = MAXIMUM_FOR_ADVENTURER
                    end
                elseif Astro.Data.StarlitPapillon.Souls > MAXIMUM then
                    Astro.Data.StarlitPapillon.Souls = MAXIMUM
                end

                effect:Remove()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.STARLIT_PAPILLON) then
                local souls = Astro.Data.StarlitPapillon.Souls

                Isaac.RenderText(
                    "x" .. souls,
                    Isaac.WorldToScreen(player.Position).X,
                    Isaac.WorldToScreen(player.Position).Y - 40,
                    1,
                    1,
                    1,
                    1
                )

                break
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_YO_LISTEN) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_YO_LISTEN)
        end
    end,
    Astro.Collectible.STARLIT_PAPILLON
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_YO_LISTEN) and not player:HasCollectible(Astro.Collectible.STARLIT_PAPILLON) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_YO_LISTEN)
        end
    end,
    Astro.Collectible.STARLIT_PAPILLON
)

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

Astro.Collectible.STARLIT_PAPILLON = Isaac.GetItemIdByName("Starlit Papillon")

-- local useSound = Isaac.GetSoundIdByName('Specialsummon')
-- local useSoundVoulme = 1 -- 0 ~ 1
Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.STARLIT_PAPILLON,
                "스타리트 파피용",
                "용사 파티의 길라잡이",
                "소지중일 때:" ..
                "#{{IND}}{{Collectible492}} 방 안에 {{SecretRoom}}{{SuperSecretRoom}}비밀방, 색돌, {{LadderRoom}}사다리방이 있는 위치로 날아가는 YO LISTEN 패밀리어를 얻습니다." ..
                "#적 처치 시 최대 " .. MAXIMUM .. "개까지 영혼을 흡수해 저장하며;" ..
                "#{{ArrowGrayRight}} 적 명중 시 영혼 1개당 1%p의 추가 피해를 줍니다." ..
                "#{{ArrowGrayRight}} 방 클리어 시 영혼이 " .. SOUL_DECREASE .. "개 감소합니다."
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.STARLIT_PAPILLON),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                {
                    "최대 " .. MAXIMUM .. "개까지",
                    "최대 {{ColorIsaac}}" .. MAXIMUM_FOR_ADVENTURER .. "{{CR}}개까지"
                },
                nil, "ko_kr", nil
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.STARLIT_PAPILLON),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                {
                    "영혼이 " .. SOUL_DECREASE .. "개 감소",
                    "영혼이 {{ColorIsaac}}" .. SOUL_DECREASE_FOR_ADVENTURER .. "{{CR}}개 감소"
                },
                nil, "ko_kr", nil
            )

            ----
            
            Astro.EID:AddCollectible(
                Astro.Collectible.STARLIT_PAPILLON,
                "Starlit Papillon", "",
                "While Held:" ..
                "#{{IND}}{{Collectible492}} Grants a YO LISTEN! familiar that highlights the location of {{SecretRoom}} secret rooms, tinted rocks and {{LadderRoom}} crawlspaces" ..
                "#Absorbs up to " .. MAXIMUM .. " souls on enemy kill" ..
                "#+1% extra damage per soul on hit" ..
                "#-" .. SOUL_DECREASE .. " souls on room clear",
                nil, "en_us"
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.STARLIT_PAPILLON),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                {
                    "up to " .. MAXIMUM .. " souls",
                    "up to {{ColorIsaac}}" .. MAXIMUM_FOR_ADVENTURER .. "{{CR}} souls"
                },
                nil, "en_us", nil
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.STARLIT_PAPILLON),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                {
                    "-" .. SOUL_DECREASE .. " souls on room clear",
                    "{{ColorIsaac}}-" .. SOUL_DECREASE_FOR_ADVENTURER .. "{{CR}} souls on room clear"
                },
                nil, "en_us", nil
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
            local itemId = Astro.Collectible.STARLIT_PAPILLON
        
            if player:HasCollectible(itemId) then
                local souls = Astro.Data.StarlitPapillon.Souls

                if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == itemId then
                    Astro.VarDataText:RenderActiceVarDataText(player, ActiveSlot.SLOT_PRIMARY, "x" .. souls, Vector(11, -4))
                end
                if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == itemId then
                    Astro.VarDataText:RenderActiceVarDataText(player, ActiveSlot.SLOT_POCKET, "x" .. souls, Vector(11, -4))
                end

                break
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.STARLIT_PAPILLON) then
            local temporacyEffect = player:GetEffects()

            if not temporacyEffect:HasCollectibleEffect(CollectibleType.COLLECTIBLE_YO_LISTEN) then
                temporacyEffect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_YO_LISTEN, false, 1)
            end
        end
    end
)
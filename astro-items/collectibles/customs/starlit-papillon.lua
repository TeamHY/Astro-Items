AstroItems.Collectible.STARLIT_PAPILLON = Isaac.GetItemIdByName("Starlit Papillon")

local useSound = Isaac.GetSoundIdByName('Specialsummon')
local useSoundVoulme = 1 -- 0 ~ 1

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.STARLIT_PAPILLON,
        "스타리트 파피용",
        "...",
        "적 처치 시 영혼을 흡수합니다. 사용 시 영혼을 소모해 현재 방에서만 몬스터 공격 시 스택 당 1%p 추가 피해를 입힙니다.#최대 50개까지 저장할 수 있습니다. 성전의 수견사, 일리걸 나이트일 경우 영혼이 2씩 증가하고 최대 100개까지 저장할 수 있습니다."
    )
end

-- 스택당 배수 증가량
local increase = 0.01

-- 최대 스택
local maximum = 50

-- 용사 관련 캐릭터일 경우 최대 스택
local maximumForAdventurer = 100

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
             AstroItems.Data.StarlitPapillon = {
                Souls = 0
             }
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.STARLIT_PAPILLON) then
                local data = AstroItems:GetPersistentPlayerData(player)

                if data then
                    data.StarlitPapillonDamageMultiplier = 0
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        if AstroItems.Data.StarlitPapillon.Souls > 0 then
            local data = AstroItems:GetPersistentPlayerData(playerWhoUsedItem)

            data.StarlitPapillonDamageMultiplier = AstroItems.Data.StarlitPapillon.Souls * increase

            AstroItems.Data.StarlitPapillon.Souls = 0

            SFXManager():Play(useSound, useSoundVoulme)

            return true
        end
    end,
    AstroItems.Collectible.STARLIT_PAPILLON
)

AstroItems:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = AstroItems:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(AstroItems.Collectible.STARLIT_PAPILLON) then
            local data = AstroItems:GetPersistentPlayerData(player)

            if data then
                if source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE then
                    entity:TakeDamage(amount * data.StarlitPapillonDamageMultiplier, 0, EntityRef(player), 0)
                end
            end
        end
    end
)


-- TODO: 소울 하나로 통합하기
AstroItems:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.STARLIT_PAPILLON) then
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

AstroItems:AddCallback(
	ModCallbacks.MC_POST_EFFECT_UPDATE,
	---@param effect EntityEffect
	function(_, effect)
        local data = effect:GetData()

        if data.StarlitPapillon then
            local player = data.StarlitPapillon.player

            effect:AddVelocity((player.Position - effect.Position):Resized(20))

            if effect.Position:Distance(player.Position) < 10 then
                AstroItems.Data.StarlitPapillon.Souls = AstroItems.Data.StarlitPapillon.Souls + 1

                if AstroItems:IsWaterEnchantress(player) then
                    AstroItems.Data.StarlitPapillon.Souls = AstroItems.Data.StarlitPapillon.Souls + 1

                    if AstroItems.Data.StarlitPapillon.Souls > maximumForAdventurer then
                        AstroItems.Data.StarlitPapillon.Souls = maximumForAdventurer
                    end
                elseif AstroItems.Data.StarlitPapillon.Souls > maximum then
                    AstroItems.Data.StarlitPapillon.Souls = maximum
                end

                effect:Remove()
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.STARLIT_PAPILLON) then
                local souls = AstroItems.Data.StarlitPapillon.Souls

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


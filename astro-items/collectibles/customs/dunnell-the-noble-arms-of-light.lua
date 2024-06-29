AstroItems.Collectible.DUNNELL_THE_NOBLE_ARMS_OF_LIGHT = Isaac.GetItemIdByName("Dunnell, the Noble Arms of Light")

local useSound = Isaac.GetSoundIdByName('Specialsummon')
local useSoundVoulme = 1 -- 0 ~ 1

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.DUNNELL_THE_NOBLE_ARMS_OF_LIGHT,
        "빛의 성검 단넬",
        "...",
        "적 처치 시 영혼을 흡수합니다. 사용 시 영혼을 소모해 현재 방에서만 {{DamageSmall}}공격력이 스택 당 1%p 증가합니다.#최대 50개까지 저장할 수 있습니다. 성전의 수견사, 일리걸 나이트일 경우 최대 100개까지 저장할 수 있습니다."
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
             AstroItems.Data.Dunnell = {
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
        
            if player:HasCollectible(AstroItems.Collectible.DUNNELL_THE_NOBLE_ARMS_OF_LIGHT) then
                local data = AstroItems:GetPersistentPlayerData(player)

                if data then
                    data.DunnellDamageMultiplier = 1
                end

                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
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
        if AstroItems.Data.Dunnell.Souls > 0 then
            local data = AstroItems:GetPersistentPlayerData(playerWhoUsedItem)

            data.DunnellDamageMultiplier = 1 + AstroItems.Data.Dunnell.Souls * increase
            playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            playerWhoUsedItem:EvaluateItems()

            AstroItems.Data.Dunnell.Souls = 0

            SFXManager():Play(useSound, useSoundVoulme)

            return true
        end
    end,
    AstroItems.Collectible.DUNNELL_THE_NOBLE_ARMS_OF_LIGHT
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.DUNNELL_THE_NOBLE_ARMS_OF_LIGHT) then
            local data = AstroItems:GetPersistentPlayerData(player)

            if data then
                local damageMultiplier = data.DunnellDamageMultiplier or 1

                player.Damage = player.Damage * damageMultiplier
            end
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

-- TODO: 소울 하나로 통합하기
AstroItems:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.DUNNELL_THE_NOBLE_ARMS_OF_LIGHT) then
                local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_SOUL, 0, npc.Position, Vector.Zero, player)

                local data = soul:GetData()
                data.Dunnell = {
                    player = player,
                }

                -- local rng = player:GetCollectibleRNG(Astro.Collectible.DUNNELL_THE_NOBLE_ARMS_OF_LIGHT)
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

        if data.Dunnell then
            local player = data.Dunnell.player

            effect:AddVelocity((player.Position - effect.Position):Resized(20))

            if effect.Position:Distance(player.Position) < 10 then
                AstroItems.Data.Dunnell.Souls = AstroItems.Data.Dunnell.Souls + 1

                if AstroItems:IsWaterEnchantress(player) then
                    if AstroItems.Data.Dunnell.Souls > maximumForAdventurer then
                        AstroItems.Data.Dunnell.Souls = maximumForAdventurer
                    end
                elseif AstroItems.Data.Dunnell.Souls > maximum then
                    AstroItems.Data.Dunnell.Souls = maximum
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
        
            if player:HasCollectible(AstroItems.Collectible.DUNNELL_THE_NOBLE_ARMS_OF_LIGHT) then
                local souls = AstroItems.Data.Dunnell.Souls

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


---
local DURATION = 4 * 30
---

AstroItems.Collectible.OVERWHELMING_SINFUL_SPOILS = Isaac.GetItemIdByName("Overwhelming Sinful Spoils")

local useSound = Isaac.GetSoundIdByName('Specialsummon')
local useSoundVoulme = 1 -- 0 ~ 1

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if EID then
            AstroItems:AddEIDCollectible(
            AstroItems.Collectible.OVERWHELMING_SINFUL_SPOILS,
            "폭주하는 죄보",
            "...",
            "적 처치 시 영혼을 흡수합니다. 사용 시 영혼을 소모해 여러 유령을 소환합니다." ..
            "#최대 2개까지 저장할 수 있습니다." ..
            "#디아벨스타, 디아벨제의 경우 5개까지 저장할 수 있습니다." ..
            "#사용 시 {{Collectible" .. AstroItems.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE .. "}}Sinful Spoils of Subversion - Snake Eye, {{Collectible" .. AstroItems.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE .. "}}Original Sinful Spoils - Snake Eye의 소환 쿨타임을 4초간 무시합니다."
        )
        end

        if not isContinued then
             AstroItems.Data.OverwhelmingSinfulSpoils = {
                Souls = 0
             }
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
        if AstroItems.Data.OverwhelmingSinfulSpoils.Souls > 0 then
            for _ = 1, AstroItems.Data.OverwhelmingSinfulSpoils.Souls do
                local rng = playerWhoUsedItem:GetCollectibleRNG(AstroItems.Collectible.OVERWHELMING_SINFUL_SPOILS)
                local random = rng:RandomInt(3)

                if random == 0 then
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, playerWhoUsedItem.Position, Vector.Zero, playerWhoUsedItem)
                    effect:GetSprite():Play("Charge", false)
                elseif random == 1 then
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 0, playerWhoUsedItem.Position, Vector.Zero, playerWhoUsedItem)
                    local data = effect:GetData()

                    if not data.Astro then
                        data.Astro = {}
                    end

                    data.Astro.KillFrame = Game():GetFrameCount() + 7 * 30
                else
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, playerWhoUsedItem.Position, Vector.Zero, playerWhoUsedItem)
                    local data = effect:GetData()

                    if not data.Astro then
                        data.Astro = {}
                    end

                    data.Astro.KillFrame = Game():GetFrameCount() + 10 * 30
                end
            end

            AstroItems.Data.OverwhelmingSinfulSpoils.Souls = 0

            SFXManager():Play(useSound, useSoundVoulme)

            return true
        end

        local playerData = playerWhoUsedItem:GetData()
        playerData["ossDurationTime"] = Game():GetFrameCount() + DURATION
    end,
    AstroItems.Collectible.OVERWHELMING_SINFUL_SPOILS
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.OVERWHELMING_SINFUL_SPOILS) then
                local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_SOUL, 0, npc.Position, Vector.Zero, player)

                local data = soul:GetData()
                data.OverwhelmingSinfulSpoils = {
                    player = player,
                }

                -- local rng = player:GetCollectibleRNG(Astro.Collectible.OVERWHELMING_SINFUL_SPOILS)
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

        if data.OverwhelmingSinfulSpoils then
            local player = data.OverwhelmingSinfulSpoils.player

            effect:AddVelocity((player.Position - effect.Position):Resized(20))

            if effect.Position:Distance(player.Position) < 10 then
                AstroItems.Data.OverwhelmingSinfulSpoils.Souls = AstroItems.Data.OverwhelmingSinfulSpoils.Souls + 1

                if AstroItems:IsDiabellstar(player) then
                    if AstroItems.Data.OverwhelmingSinfulSpoils.Souls > 5 then
                        AstroItems.Data.OverwhelmingSinfulSpoils.Souls = 5
                    end
                else
                    if AstroItems.Data.OverwhelmingSinfulSpoils.Souls > 2 then
                        AstroItems.Data.OverwhelmingSinfulSpoils.Souls = 2
                    end
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
        
            if player:HasCollectible(AstroItems.Collectible.OVERWHELMING_SINFUL_SPOILS) then
                local souls = AstroItems.Data.OverwhelmingSinfulSpoils.Souls

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

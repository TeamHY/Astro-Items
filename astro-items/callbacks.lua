AstroItems.Callbacks = {
    POST_NEW_STAGE = "ASTRO_POST_NEW_STAGE",
    POST_NEW_GREED_WAVE = "ASTRO_POST_NEW_GREED_WAVE",
    PLAYER_TAKE_PENALTY = "ASTRO_PLAYER_TAKE_PENALTY",
    SOUL_COLLECTED = "ASTRO_SOUL_COLLECTED",
    EVALUATE_MY_MOON = "ASTRO_EVALUATE_MY_MOON"
}

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            AstroItems.Data["lastStage"] = LevelStage.STAGE_NULL
            AstroItems.Data["lastGreedWave"] = 0
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        local stage = Game():GetLevel():GetStage()

        if AstroItems.Data["lastStage"] ~= stage then
            AstroItems.Data["lastStage"] = stage
            AstroItems.Data["lastGreedWave"] = 0

            Isaac.RunCallback(AstroItems.Callbacks.POST_NEW_STAGE, stage)
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        local wave = Game():GetLevel().GreedModeWave

        if AstroItems.Data["lastGreedWave"] ~= wave then
            Isaac.RunCallback(AstroItems.Callbacks.POST_NEW_GREED_WAVE, wave)
        end

        AstroItems.Data["lastGreedWave"] = wave
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player ~= nil then
            if damageFlags & (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS) == 0 then
                Isaac.RunCallback(AstroItems.Callbacks.PLAYER_TAKE_PENALTY, player)
            end
        end
    end
)

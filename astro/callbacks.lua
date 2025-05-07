local isc = require("astro.lib.isaacscript-common")

Astro.Callbacks = {
    POST_NEW_STAGE = "ASTRO_POST_NEW_STAGE",
    POST_NEW_GREED_WAVE = "ASTRO_POST_NEW_GREED_WAVE",
    PLAYER_TAKE_PENALTY = "ASTRO_PLAYER_TAKE_PENALTY", -- false를 리턴 시 패널티를 제거합니다.
    POST_PLAYER_TAKE_PENALTY = "ASTRO_POST_PLAYER_TAKE_PENALTY",
    SOUL_COLLECTED = "ASTRO_SOUL_COLLECTED",
    EVALUATE_MY_MOON = "ASTRO_EVALUATE_MY_MOON",
    MOD_INIT = "ASTRO_MOD_INIT",
    POST_ITEM_PICKUP = "ASTRO_POST_ITEM_PICKUP",
    POST_PLAYER_COLLECTIBLE_ADDED = "ASTRO_POST_PLAYER_COLLECTIBLE_ADDED",
    POST_PLAYER_COLLECTIBLE_REMOVED = "ASTRO_POST_PLAYER_COLLECTIBLE_REMOVED",
    POST_TRANSFORMATION = "ASTRO_POST_TRANSFORMATION",
    POST_PICKUP_COLLECT = "ASTRO_POST_PICKUP_COLLECT",
    REMOVED_PERFECTION = "ASTRO_REMOVED_PERFECTION",
}

local isFirst = true

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data["lastStage"] = LevelStage.STAGE_NULL
            Astro.Data["lastGreedWave"] = 0
            Astro.Data["lastPenaltyFrame"] = nil
        end

        if isFirst then
            Isaac.RunCallback(Astro.Callbacks.MOD_INIT)
            isFirst = false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        local stage = Game():GetLevel():GetStage()

        if Astro.Data["lastStage"] ~= stage then
            Astro.Data["lastStage"] = stage
            Astro.Data["lastGreedWave"] = 0

            Isaac.RunCallback(Astro.Callbacks.POST_NEW_STAGE, stage)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        local wave = Game():GetLevel().GreedModeWave

        if Astro.Data["lastGreedWave"] ~= wave then
            Isaac.RunCallback(Astro.Callbacks.POST_NEW_GREED_WAVE, wave)
        end

        Astro.Data["lastGreedWave"] = wave
    end
)

Astro:AddCallback(
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
                local result = Isaac.RunCallback(Astro.Callbacks.PLAYER_TAKE_PENALTY, player)

                if result == false then
                    entity:TakeDamage(amount, damageFlags | DamageFlag.DAMAGE_NO_PENALTIES, source, countdownFrames)
                    return false
                end

                local playerData = Astro:GetPersistentPlayerData(player)

                if playerData then
                    playerData["lastPenaltyFrame"] = Game():GetFrameCount()
                end

                Isaac.RunCallback(Astro.Callbacks.POST_PLAYER_TAKE_PENALTY, player)

                if player:HasTrinket(TrinketType.TRINKET_PERFECTION) and not player:HasCollectible(Astro.Collectible.TAANA_DEFENSE_HELPER) then
                    Isaac.RunCallback(Astro.Callbacks.REMOVED_PERFECTION, player.Position)
                end
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_ITEM_PICKUP,
    ---@param player EntityPlayer
    ---@param pickingUpItem { itemType: ItemType, subType: CollectibleType | TrinketType }
    function(_, player, pickingUpItem)
        Isaac.RunCallback(Astro.Callbacks.POST_ITEM_PICKUP, player, pickingUpItem)
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not Astro.Data.CollectibleCount then
            Astro:ScheduleForUpdate(
                function()
                    Isaac.RunCallbackWithParam(Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED, collectibleType, player, collectibleType)
                end,
                1
            )
        else
            Isaac.RunCallbackWithParam(Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED, collectibleType, player, collectibleType)
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Isaac.RunCallbackWithParam(Astro.Callbacks.POST_PLAYER_COLLECTIBLE_REMOVED, collectibleType, player, collectibleType)
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_TRANSFORMATION,
    ---@param player EntityPlayer
    ---@param playerForm PlayerForm
    ---@param hasForm boolean
    function(_, player, playerForm, hasForm)
        Isaac.RunCallbackWithParam(Astro.Callbacks.POST_TRANSFORMATION, playerForm, player, playerForm, hasForm)
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PICKUP_COLLECT,
    ---@param pickup EntityPickup
    ---@param player EntityPlayer
    function(_, pickup, player)
        Isaac.RunCallbackWithParam(Astro.Callbacks.POST_PICKUP_COLLECT, pickup.Variant, player, pickup)
    end
)

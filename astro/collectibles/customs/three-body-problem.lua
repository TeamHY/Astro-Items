---
local SOUND_VOLUME = 0.7

local BOSS_EXTRA_DAMAGE = 0.25
---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.THREE_BODY_PROBLEM = Isaac.GetItemIdByName("3 Body Problem")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.THREE_BODY_PROBLEM, "삼체", "예측불허", "삼체 문제는 예측할 수 없습니다.")
end

---@type CollectibleType[]
local activeItmes = {}

---@type CollectibleType[]
local banItems = {}

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        -- Astro.Collectible 초기화 순서 문제로 인해 여기서 초기화합니다.
        activeItmes = {
            CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
            CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS,
            CollectibleType.COLLECTIBLE_ERASER,
            CollectibleType.COLLECTIBLE_DADS_KEY,
            CollectibleType.COLLECTIBLE_ANIMA_SOLA,
            CollectibleType.COLLECTIBLE_TELEKINESIS,
            CollectibleType.COLLECTIBLE_FORTUNE_COOKIE,
        }

        banItems = {
            CollectibleType.COLLECTIBLE_SPOON_BENDER,
        }
    end
)

---@param player EntityPlayer
local function RunEffect(player)
    local rng = player:GetCollectibleRNG(Astro.Collectible.THREE_BODY_PROBLEM)
    
    local item = activeItmes[rng:RandomInt(#activeItmes) + 1]

    player:AnimateCollectible(Astro.Collectible.THREE_BODY_PROBLEM, "HideItem")
    player:UseActiveItem(item, false)
    SFXManager():Play(SoundEffect.SOUND_DIVINE_INTERVENTION, SOUND_VOLUME)
end

local isFirstKill = true

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        isFirstKill = true

        if not Game():GetRoom():IsClear() then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) then
                    RunEffect(player)
                    break
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) and isFirstKill and entityNPC.Type ~= EntityType.ENTITY_FIREPLACE then
                RunEffect(player)
                isFirstKill = false
                break
            end
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

            if player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) then
                RunEffect(player)
                break
            end
        end
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
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) then
            if entity:IsBoss() and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                entity:TakeDamage(amount * BOSS_EXTRA_DAMAGE * player:GetCollectibleNum(Astro.Collectible.THREE_BODY_PROBLEM), 0, EntityRef(player), 0)
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.THREE_BODY_PROBLEM) then
            for _, item in ipairs(banItems) do
                Astro:RemoveAllCollectible(player, item)
            end
        end
    end,
    Astro.Collectible.THREE_BODY_PROBLEM
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE, player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) and 3 or 0, "ASTRO_THREE_BODY_PROBLEM")
    end
)

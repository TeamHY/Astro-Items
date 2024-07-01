AstroItems.Collectible.THREE_BODY_PROBLEM = Isaac.GetItemIdByName("3 Body Problem")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.THREE_BODY_PROBLEM, "삼체", "...", "삼체 문제는 예측할 수 없습니다.")
end

---@type CollectibleType[]
local activeItmes = {}

local soundVoulme = 1

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        -- AstroItems.Collectible 초기화 순서 문제로 인해 여기서 초기화합니다.
        activeItmes = {
            CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
            CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS
        }
    end
)

---@param player EntityPlayer
local function RunEffect(player)
    local rng = player:GetCollectibleRNG(AstroItems.Collectible.THREE_BODY_PROBLEM)
    
    local item = activeItmes[rng:RandomInt(#activeItmes) + 1]

    player:AnimateCollectible(AstroItems.Collectible.THREE_BODY_PROBLEM, "HideItem")
    player:UseActiveItem(item, false)
    SFXManager():Play(SoundEffect.SOUND_DIVINE_INTERVENTION, soundVoulme)
end

local isFirstKill = true

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        isFirstKill = true

        if not Game():GetRoom():IsClear() then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(AstroItems.Collectible.THREE_BODY_PROBLEM) then
                    RunEffect(player)
                    break
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.THREE_BODY_PROBLEM) and isFirstKill and entityNPC.Type ~= EntityType.ENTITY_FIREPLACE then
                RunEffect(player)
                isFirstKill = false
                break
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.THREE_BODY_PROBLEM) then
                RunEffect(player)
                break
            end
        end
    end
)

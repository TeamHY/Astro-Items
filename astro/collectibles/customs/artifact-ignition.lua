---

Astro.Collectible.ARTIFACT_IGNITION = Isaac.GetItemIdByName("Artifact Ignition")

local ITEM_ID = Astro.Collectible.ARTIFACT_IGNITION

local SUCCUBUS_GRANT_INTERVAL = 120 * 30

local MAX_SUCCUBUS_COUNT = 10

---

if EID then
    Astro:AddEIDCollectible(
        ITEM_ID,
        "아티팩트 무브먼트",
        "...",
        "120초마다 {{Collectible417}}Succubus를 획득합니다." ..
        "#최대 10개까지 획득할 수 있습니다."
    )

    Astro:AddEIDCollectible(
        ITEM_ID,
        "Artifact Ignition", "",
        "Every 120 seconds, grants a {{Collectible417}}Succubus." ..
        "#Maximum of 10 Succubus can be granted.",
        nil,
        "en_us"
    )
end

Astro:AddUpgradeAction(
    function(player)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
            local room = Game():GetRoom()
            local succubi = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_SUCCUBUS, true, false)
            
            if #succubi > 0 then
                return {
                    succubi = succubi
                }
            end
        end

        return nil
    end,
    function(player, data)
        for _, succubus in ipairs(data.succubi) do
            succubus:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)
            
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, succubus.Position, succubus.Velocity, nil)
        end
    end
)

---@param player EntityPlayer
local function InitializeArtifactIgnitionData(player)
    local data = Astro.SaveManager.GetRunSave(player, true)
    
    if not data["artifactIgnitionTimer"] then
        data["artifactIgnitionTimer"] = 0
    end
    
    if not data["artifactIgnitionSuccubusCount"] then
        data["artifactIgnitionSuccubusCount"] = 0
    end
    
    return data
end

---@param player EntityPlayer
local function UpdateArtifactIgnition(player)
    if not player:HasCollectible(ITEM_ID) then
        return
    end
    
    local data = InitializeArtifactIgnitionData(player)
    
    data["artifactIgnitionTimer"] = data["artifactIgnitionTimer"] + 1
    
    if data["artifactIgnitionTimer"] >= SUCCUBUS_GRANT_INTERVAL and data["artifactIgnitionSuccubusCount"] < MAX_SUCCUBUS_COUNT then
        player:AddCollectible(CollectibleType.COLLECTIBLE_SUCCUBUS, 0, false)
        
        data["artifactIgnitionSuccubusCount"] = data["artifactIgnitionSuccubusCount"] + 1
        data["artifactIgnitionTimer"] = 0
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            UpdateArtifactIgnition(player)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_INIT,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(ITEM_ID) then
            InitializeArtifactIgnitionData(player)
        end
    end
)

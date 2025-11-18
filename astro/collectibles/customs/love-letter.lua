Astro.Collectible.LOVE_LETTER = Isaac.GetItemIdByName("Love Letter")

local LOVE_LETTER_VARIANT = Isaac.GetEntityVariantByName("Love Letter")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.LOVE_LETTER,
        "고백 편지",
        "전해지지 않은 러브레터",
        "사용 시 {{Heart}}/{{BoneHeart}}1칸 또는 {{SoulHeart}}2칸을 {{BrokenHeart}}소지 불가능 체력 1칸으로 바꿔 공격방향으로 편지를 발사합니다." ..
        "#편지에 맞은 적은 해당 게임에서 영원히 아군이 됩니다." ..
        "#{{ArrowGrayRight}} 아군 적은 그 방에서만 유지됩니다." ..
        "#스테이지 당 한번 사용할수 있으며 배터리나 방 클리어로 충전되지 않습니다."
    )
end

--- @param player EntityPlayer
local function hasEnoughHearts(player)
    local hasRedHearts = player:GetHearts() >= 2
    local hasBoneHearts = player:GetBoneHearts() >= 1
    local hasSoulHearts = player:GetSoulHearts() >= 4
    return hasRedHearts or hasBoneHearts or hasSoulHearts
end

---@param player EntityPlayer
local function consumeHearts(player)
    local hasRedHearts = player:GetHearts() >= 2
    local hasBoneHearts = player:GetBoneHearts() >= 1

    if hasRedHearts then
        player:AddHearts(-2)
    elseif hasBoneHearts then
        player:AddBoneHearts(-1)
    else
        player:AddSoulHearts(-4)
    end

    player:AddBrokenHearts(1)
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
        local stageData = Astro.SaveManager.GetFloorSave(player)

        if stageData["loveLetterUsed"] then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        if not hasEnoughHearts(player) then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        player:UseActiveItem(CollectibleType.COLLECTIBLE_ERASER, UseFlag.USE_NOANIM, activeSlot)

        local sprite = player:GetHeldSprite()
        sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/Love Letter.png")
        sprite:LoadGraphics()

        local data = Astro.SaveManager.GetRoomSave(player)
        data["loveLetterUsed"] = not data["loveLetterUsed"]

        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false,
        }
    end,
    Astro.Collectible.LOVE_LETTER
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            local data = Astro.SaveManager.GetRoomSave(player)

            if not data["loveLetterUsed"] then
                goto continue
            end

            local controller = player.ControllerIndex
            if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, controller) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, controller) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, controller) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, controller) then
                data["loveLetterUsed"] = nil

                local function tryFindTear(attempt)
                    Astro:ScheduleForUpdate(
                        function()
                            local tears = Isaac.FindByType(EntityType.ENTITY_TEAR, 45, -1)
                            local closestTear = nil
                            local closestDistance = math.huge

                            for _, tearEntity in ipairs(tears) do
                                local tear = tearEntity:ToTear() ---@cast tear EntityTear
                                local distance = player.Position:Distance(tear.Position)
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestTear = tear
                                end
                            end

                            if closestTear then
                                local position = closestTear.Position
                                local velocity = closestTear.Velocity
                                closestTear:Remove()

                                if hasEnoughHearts(player) then
                                    consumeHearts(player)

                                    local stageData = Astro.SaveManager.GetFloorSave(player)
                                    stageData["loveLetterUsed"] = true
    
                                    Isaac.Spawn(EntityType.ENTITY_TEAR, LOVE_LETTER_VARIANT, 0, position, velocity, player)
                                end
                            elseif attempt < 10 then
                                tryFindTear(attempt + 1)
                            end
                        end,
                        1
                    )
                end

                tryFindTear(1)
            end

            ::continue::
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_TEAR_COLLISION,
    ---@param tear EntityTear
    ---@param collider Entity
    ---@param low boolean
    function(_, tear, collider, low)
        if collider:IsVulnerableEnemy() and collider.Type ~= EntityType.ENTITY_FIREPLACE and not collider:IsBoss() then
            collider:AddCharmed(EntityRef(tear.SpawnerEntity), -1)
            collider:GetData()["astroSpawnedRoomIndex"] = Game():GetLevel():GetCurrentRoomIndex()

            local data = Astro.SaveManager.GetRunSave()
            data["loveLetteredEnemies"] = data["loveLetteredEnemies"] or {}
            table.insert(data["loveLetteredEnemies"], {
                Type = collider.Type,
                Variant = collider.Variant,
                SubType = collider.SubType,
            })
        end
    end,
    LOVE_LETTER_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_INIT,
     ---@param npc EntityNPC
    function(_, npc)
        local data = Astro.SaveManager.GetRunSave()
        local loveLetteredEnemies = data["loveLetteredEnemies"] ---@type{[integer]: Astro.Entity}?

        if loveLetteredEnemies then
            for _, entityInfo in ipairs(loveLetteredEnemies) do
                if npc.Type == entityInfo.Type and npc.Variant == entityInfo.Variant and npc.SubType == entityInfo.SubType then
                    local player = Isaac.GetPlayer()
                    npc:AddCharmed(EntityRef(player), -1)
                    npc:GetData()["astroSpawnedRoomIndex"] = Game():GetLevel():GetCurrentRoomIndex()
                    break
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity:IsEnemy() then
                local data = entity:GetData()
                if data["astroSpawnedRoomIndex"] and data["astroSpawnedRoomIndex"] ~= Game():GetLevel():GetCurrentRoomIndex() then
                    entity:Remove()
                end
            end
        end
    end
)

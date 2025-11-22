Astro.Collectible.LOVE_LETTER = Isaac.GetItemIdByName("Love Letter")

local LOVE_LETTER_VARIANT = Isaac.GetEntityVariantByName("Love Letter")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
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
            EID:addCarBatteryCondition(Astro.Collectible.LOVE_LETTER, "50%의 확률로 체력이 감소하지 않음", nil, nil, "ko_kr")
            ----
            Astro:AddEIDCollectible(
                Astro.Collectible.LOVE_LETTER,
                "Love Letter",
                "",
                "Converts {{Heart}}/{{BoneHeart}} 1 or {{SoulHeart}} 2 to 1 {{BrokenHeart}} Broken Heart and fires letter in attack direction." ..
                "#Hit enemies become permanent allies this run." ..
                "#{{ArrowGrayRight}} Ally enemies last in the room." ..
                "#Can only be used once per floor.",
                nil,
                "en_us"
            )
            EID:addCarBatteryCondition(Astro.Collectible.LOVE_LETTER, "50% chance of not losing health", nil, nil, "en_us")
        end
    end
)

local loveLetterRotation = 0

--- @param player EntityPlayer
local function hasEnoughHearts(player)
    local hasRedHearts = player:GetHearts() >= 2
    local hasBoneHearts = player:GetBoneHearts() >= 1
    local hasSoulHearts = player:GetSoulHearts() >= 4
    return hasRedHearts or hasBoneHearts or hasSoulHearts
end

---@param player EntityPlayer
local function consumeHearts(player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
        local rng = player:GetCollectibleRNG(Astro.Collectible.LOVE_LETTER)
        if rng:RandomFloat() < 0.5 then
            return
        end
    end

    local hasRedHearts = player:GetHearts() >= 2
    local hasBoneHearts = player:GetBoneHearts() >= 1

    if hasRedHearts then
        player:AddMaxHearts(-2)
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
        if not hasEnoughHearts(player) then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        if player:IsHoldingItem() then
            player:AnimateCollectible(Astro.Collectible.LOVE_LETTER, "HideItem")
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local data = Astro.SaveManager.GetRoomSave(player)
        data["loveLetterUsed"] = true
        player:UseActiveItem(CollectibleType.COLLECTIBLE_ERASER, UseFlag.USE_NOANIM, activeSlot)
        player:AnimateCollectible(Astro.Collectible.LOVE_LETTER, "LiftItem")

        if REPENTOGON then
            local sprite = player:GetHeldSprite()
            sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/Love Letter.png")
            sprite:LoadGraphics()
        end

        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false,
        }
    end,
    Astro.Collectible.LOVE_LETTER
)

Astro:AddCallback(
    ModCallbacks.MC_POST_TEAR_INIT,
    ---@param tear EntityTear
    function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if not player then return end

        local data = Astro.SaveManager.GetRoomSave(player)
        if not data["loveLetterUsed"] then return end

        data["loveLetterUsed"] = false

        local position = tear.Position
        local velocity = tear.Velocity
        tear:Remove()

        if hasEnoughHearts(player) then
            consumeHearts(player)
            
            Isaac.Spawn(EntityType.ENTITY_TEAR, LOVE_LETTER_VARIANT, 0, position, velocity, player)
            loveLetterRotation = math.abs(velocity.Y) > math.abs(velocity.X) and 90 or 0
        end
    end,
    TearVariant.ERASER
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_TEAR_COLLISION,
    ---@param tear EntityTear
    ---@param collider Entity
    ---@param low boolean
    function(_, tear, collider, low)
        local game = Game()
        if collider:IsVulnerableEnemy() and collider.Type ~= EntityType.ENTITY_FIREPLACE then
            local currentRoomIndex = game:GetLevel():GetCurrentRoomIndex()

            if collider:IsBoss() then
                collider:TakeDamage(15, 0, EntityRef(tear.SpawnerEntity), 0)
                collider:AddCharmed(EntityRef(tear.SpawnerEntity), 240)
            else
                roomEnt = Isaac.GetRoomEntities()
                for _, e in ipairs(roomEnt) do
                    if e:IsVulnerableEnemy()
                    and e.Type == collider.Type
                    and e.Variant == collider.Variant
                    and e.SubType == collider.SubType
                    and not e:IsBoss()
                    and e.Type ~= EntityType.ENTITY_FIREPLACE then
                        game:SpawnParticles(e.Position, EffectVariant.POOF01, 1, 0, Color(1,1,1,1,0.66,0.5,0.66))
                        e:AddCharmed(EntityRef(tear.SpawnerEntity), -1)
                        e:GetData()["astroSpawnedRoomIndex"] = currentRoomIndex
                    end
                end

                local data = Astro.SaveManager.GetRunSave()
                data["loveLetteredEnemies"] = data["loveLetteredEnemies"] or {}
                table.insert(data["loveLetteredEnemies"], {
                    Type = collider.Type,
                    Variant = collider.Variant,
                    SubType = collider.SubType,
                })
            end
        end

        game:SpawnParticles(tear.Position, EffectVariant.TEAR_POOF_A, 1, 1, Color(1,1,1,1,0.66,0.5,0.66))
        SFXManager():Play(SoundEffect.SOUND_BOX_OF_FRIENDS)
        tear:Remove()
    end,
    LOVE_LETTER_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_TEAR_UPDATE,
    ---@param tear EntityTear
    function(_, tear)
        tear.SpriteRotation = loveLetterRotation

        if tear:IsDead() then
            Game():SpawnParticles(tear.Position, EffectVariant.TEAR_POOF_A, 1, 1, Color(1,1,1,1,0.66,0.5,0.66))
            SFXManager():Play(SoundEffect.SOUND_SPLATTER)
            return
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

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for j = 0, ActiveSlot.SLOT_POCKET2 do
                if player:GetActiveItem(j) == Astro.Collectible.LOVE_LETTER then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
                        player:SetActiveCharge(2, j)
                    else
                        player:SetActiveCharge(1, j)
                    end
                end
            end
        end
    end
)
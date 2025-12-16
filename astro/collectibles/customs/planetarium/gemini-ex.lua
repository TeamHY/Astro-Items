Astro.Collectible.GEMINI_EX = Isaac.GetItemIdByName("Gemini EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(    
                Astro.Collectible.GEMINI_EX,    
                "초 쌍둥이자리",    
                "사이좋게 지내렴",
                "적을 따라다니며 접촉한 적에게 초당 65 + 공격력 x1.0의 피해를 줍니다." .. 
                "#{{Collectible357}} 방 입장 시 소지중인 패밀리어를 복사합니다." ..
                "#{{Trinket" .. Astro.Trinket.BLACK_MIRROR .. "}} 최초 획득 시 Black Mirror(패시브 획득 시 한 번 더 획득)를 드랍합니다."
            )

            Astro:AddEIDCollectible(    
                Astro.Collectible.GEMINI_EX,    
                "Gemini EX",
                "",    
                "Familiar that chases and damages enemies" ..
                "#{{ArrowGrayRight}} Deals (65 + Isaac's damage) contact damage per second" .. 
                "#{{Collectible357}} Duplicates all your familiars for the room" ..
                "#{{Trinket" .. Astro.Trinket.BLACK_MIRROR .. "}} Spawns 1 Black Mirror(Gain passive item twice) on first pickup",
                nil, "en_us"
            )
        end 
    end
)

local game = Game()

---@param player EntityPlayer
---@param num number?
local function SpawnGeminiBaby(player)
    local gemini = Isaac.Spawn(EntityType.ENTITY_GEMINI, 10, 3, player.Position, Vector.Zero, player)
    gemini:AddCharmed(EntityRef(player), -1)
    gemini:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)

    local color = Color(1, 1, 1, 1, 0, 0, 0) color:SetColorize(1, 1, 2, 5)
    color:SetColorize(1, 1, 5, 5)
    gemini:GetSprite().Color = color

    local pData = Astro:GetPersistentPlayerData(player)
    pData["spawnedByGeminiEx"][tostring(gemini.InitSeed)] = true
end

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.GEMINI_EX) then
            --[[ 기존 효과
            local level = game:GetLevel()
            local currentRoom = level:GetCurrentRoom()
            local rng = player:GetCollectibleRNG(Astro.Collectible.GEMINI_EX)
            local inventory = Astro:getPlayerInventory(player, false)

            local listToSpawn = Astro:GetRandomCollectibles(inventory, rng, 5, Astro.Collectible.GEMINI_EX, true)

            for key, value in ipairs(listToSpawn) do
                Astro:SpawnCollectible(value, player.Position + Vector(Astro.GRID_SIZE * (-3 + key), -Astro.GRID_SIZE), Astro.Collectible.GEMINI_EX)
            end
            ]]
            Astro:SpawnTrinket(Astro.Trinket.BLACK_MIRROR, player.Position)
        end
        
        SpawnGeminiBaby(player)
        Astro.Data["geminiExCooldown"] = 60    -- 특정 상황에서 초쌍이 1개여도 2마리 생성될 때 있음
    end,
    Astro.Collectible.GEMINI_EX
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = Astro:GetPersistentPlayerData(player)

            if not isContinued then
                pData["spawnedByGeminiEx"] = {}
                Astro.Data["geminiExCooldown"] = 0
            end
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        if Astro.Data["geminiExCooldown"] > 0 then
            Astro.Data["geminiExCooldown"] = Astro.Data["geminiExCooldown"] - 1
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.GEMINI_EX) then
                local collectibleNum = player:GetCollectibleNum(Astro.Collectible.GEMINI_EX)
                local geminies = Isaac.FindByType(EntityType.ENTITY_GEMINI, 10, 3)

                if #geminies > 0 then
                    for j, gemini in pairs(geminies) do
                        gemini.Position = player.Position
                    end
                else
                    for k = 1, collectibleNum do
                        if Astro.Data["geminiExCooldown"] == 0 then
                            SpawnGeminiBaby(player)
                        end
                    end
                end

                for _ = 1, collectibleNum do
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS, UseFlag.USE_NOANIM)

                    local sfx = SFXManager()
                    if SoundEffect.SOUND_BOX_OF_FRIENDS and sfx:IsPlaying(SoundEffect.SOUND_BOX_OF_FRIENDS) then
                        sfx:Stop(SoundEffect.SOUND_BOX_OF_FRIENDS)
                    end
                end
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
        if entity.Type == EntityType.ENTITY_GEMINI and entity.Variant == 10 and entity.SubType == 3 then
            for i = 1, game:GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
                local pData = Astro:GetPersistentPlayerData(player)
            
                if pData["spawnedByGeminiEx"][tostring(entity.InitSeed)] then
                    return false
                end
            end
        end

        if entity:IsVulnerableEnemy() and source.Entity ~= nil and damageFlags & DamageFlag.DAMAGE_IV_BAG == 0 then
            local sourceEnt = source.Entity
            
            if sourceEnt.Type == EntityType.ENTITY_GEMINI and sourceEnt.Variant == 10 and sourceEnt.SubType == 3 then
                for i = 1, game:GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)
                    
                    if player:HasCollectible(Astro.Collectible.GEMINI_EX) then
                        local collectibleNum = player:GetCollectibleNum(Astro.Collectible.GEMINI_EX)
                        local pData = Astro:GetPersistentPlayerData(player)
                    
                        if pData["spawnedByGeminiEx"][tostring(sourceEnt.InitSeed)] then
                            entity:TakeDamage(player.Damage * collectibleNum, damageFlags | DamageFlag.DAMAGE_IV_BAG, source, countdownFrames)
                        end
                    end
                end
            end
        end
    end
)
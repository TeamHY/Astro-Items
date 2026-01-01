Astro.Collectible.LEO_EX = Isaac.GetItemIdByName("Leo EX")

--

local FREEZE_DURATION = 5 * 30    -- 지속 시간

local FREEZE_CHANCE = 0.5

local ROCK_COUNT = 10    -- 바위 n개당 스택 1

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local freezeChance = string.format("%.f", FREEZE_CHANCE * 100)
            local freezeDuration = string.format("%.f", FREEZE_DURATION / 30)

            Astro.EID:AddCollectible(
                Astro.Collectible.LEO_EX,
                "초 사자자리",
                "왕의 위엄",
                "장애물을 부술 수 있습니다." ..
                "#바위 " .. ROCK_COUNT .. "개를 부술 때마다 스택이 최대 12까지 1씩 증가하며;" ..
                "#{{ArrowGrayRight}} 공격키를 두번 누르면 모든 스택을 소모하고 {{Collectible611}}Larynx 효과와 충격파를 일으킵니다." ..
                "#{{Blank}} (Larynx 효과는 스택에 비례해 강화됨)" ..
                "#{{Trinket188}} 방 입장 시 각각의 적들을 " .. freezeChance .. "%의 확률로 " .. freezeDuration .. "초간 석화시키며;" ..
                "#{{ArrowGrayRight}} 석화 상태의 적 처치시 적이 얼어붙으며 얼어붙은 적은 접촉 시 직선으로 날아가 6방향으로 고드름 눈물을 발사합니다." ..
                "#다음 게임에서 {{Collectible302}}Leo를 들고 시작합니다.",
                -- 중첩 시
                "중첩할수록 부숴야되는 바위의 개수가 최소 " .. math.ceil(ROCK_COUNT / 2) .. "개까지 1개씩 감소"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.LEO_EX,
                "Leo EX",
                "",
                "Isaac can destroy rocks by walking into them" ..
                "#Each time you break a " .. ROCK_COUNT .. " rocks, the stack increases by 1 up to a maximum of 12" ..
                "#{{ArrowGrayRight}} Double-tapping a fire key to consume all stacks and trigger the {{Collectible611}} Larynx effect and shockwave" ..
                "#{{Blank}} (Larynx's effect scales with stacks)" ..
                "#{{Trinket188}} Entering a room has a " .. freezeChance .. "% chance to petrify random enemies for " .. freezeDuration .. " seconds;" ..
                "#{{ArrowGrayRight}} Killing a petrified enemy freezes it" ..
                "#Grants {{Collectible302}}Leo at the start of the next run",
                -- Stacks
                "Each stack reduces the required rocks by 1, down to a minimum of " .. math.ceil(ROCK_COUNT / 2),
                "en_us"
            )
        end
    end
)

---@type Entity[]
local freezeEntities = {}

local freezeDurationTime = 0

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and Astro.Data.RunLeoEx then
            local player = Isaac.GetPlayer()

            player:AddCollectible(CollectibleType.COLLECTIBLE_LEO)

            Astro.Data.RunLeoEx = false
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Astro.Data.RunLeoEx = true
    end,
    Astro.Collectible.LEO_EX
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        ---@type EntityPlayer
        local owner

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.LEO_EX) then
                owner = player
                break
            end
        end

        if owner ~= nil then
            local entities = Isaac.GetRoomEntities()
            local rng = owner:GetCollectibleRNG(Astro.Collectible.LEO_EX)

            freezeEntities = {}
            freezeDurationTime = Game():GetFrameCount() + FREEZE_DURATION

            for _, entity in ipairs(entities) do
                if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and rng:RandomFloat() < FREEZE_CHANCE then
                    entity:AddFreeze(EntityRef(owner), FREEZE_DURATION)
                    entity:AddEntityFlags(EntityFlag.FLAG_ICE)
                    table.insert(freezeEntities, entity)
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function()
        if freezeEntities ~= {} and freezeDurationTime <= Game():GetFrameCount() then
            for _, entity in ipairs(freezeEntities) do
                entity:ClearEntityFlags(EntityFlag.FLAG_ICE)
            end

            freezeEntities = {}
        end
    end
)


------ 리뉴얼 효과 ------
Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.LEO_EX) then
            local temporacyEffect = player:GetEffects()

            if not temporacyEffect:HasCollectibleEffect(CollectibleType.COLLECTIBLE_LEO) then
                temporacyEffect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false, 1)
            end
        end
    end
)

local previousStates = {}

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = Astro:GetPersistentPlayerData(player)

            pData["LeoEXStack"] = 0
            pData["LeoEXDestroyCount"] = 0
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        previousStates = {}
        local room = Game():GetRoom()

        for i = 0, room:GetGridSize() - 1 do
            local grid = room:GetGridEntity(i)

            if grid and grid:ToRock() then
                previousStates[i] = grid.State
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.LEO_EX) then return end

        local room = Game():GetRoom()
        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)

            if grid and grid:ToRock() then
                local currentState = grid.State
                local prevState = previousStates[i] or 0

                if prevState ~= 2 and currentState == 2 then
                    local leoNum = player:GetCollectibleNum(Astro.Collectible.LEO_EX)
                    local pData = Astro:GetPersistentPlayerData(player)
                    pData["LeoEXDestroyCount"] = pData["LeoEXDestroyCount"] + 1
                    
                    if pData["LeoEXDestroyCount"] % math.min(math.ceil(ROCK_COUNT / 2), ROCK_COUNT - leoNum + 1) == 0 then
                        pData["LeoEXStack"] = math.min(12, pData["LeoEXStack"] + 1)
                    end
                end

                previousStates[i] = currentState
            end
        end
    end
)

local lastInput = {
    [ButtonAction.ACTION_SHOOTLEFT] = 0,
    [ButtonAction.ACTION_SHOOTRIGHT] = 0,
    [ButtonAction.ACTION_SHOOTUP] = 0,
    [ButtonAction.ACTION_SHOOTDOWN] = 0
}

local lastTap = {
    [ButtonAction.ACTION_SHOOTLEFT] = 0,
    [ButtonAction.ACTION_SHOOTRIGHT] = 0,
    [ButtonAction.ACTION_SHOOTUP] = 0,
    [ButtonAction.ACTION_SHOOTDOWN] = 0
}

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function()
        local game = Game()
        if game:IsPaused() then return end

        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = Astro:GetPersistentPlayerData(player)

            if player:HasCollectible(Astro.Collectible.LEO_EX) then
                local now = Isaac.GetFrameCount()

                for dir = ButtonAction.ACTION_SHOOTLEFT, ButtonAction.ACTION_SHOOTDOWN do
                    local pressed = Input.IsActionTriggered(dir, player.ControllerIndex)

                    if pressed and pData["LeoEXStack"] and pData["LeoEXStack"] > 0 then
                        if now - lastInput[dir] < 15 then    -- small time window
                            if now - lastTap[dir] > 20 then
                                -- dash
                                local vel = Vector.Zero
                                if dir == ButtonAction.ACTION_SHOOTLEFT then vel = Vector(-12, 0)
                                elseif dir == ButtonAction.ACTION_SHOOTRIGHT then vel = Vector(12, 0)
                                elseif dir == ButtonAction.ACTION_SHOOTUP then vel = Vector(0, -12)
                                elseif dir == ButtonAction.ACTION_SHOOTDOWN then vel = Vector(0, 12)
                                end
                                
                                local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, player.Position - Vector(0, 4), vel, player)
                                shockwave.Parent = player
                                player:UseActiveItem(CollectibleType.COLLECTIBLE_LARYNX, UseFlag.USE_CUSTOMVARDATA, nil, pData["LeoEXStack"])

                                pData["LeoEXStack"] = 0
                                lastTap[dir] = now
                            end
                        end

                        lastInput[dir] = now
                    end
                end
            end
        end
    end
)
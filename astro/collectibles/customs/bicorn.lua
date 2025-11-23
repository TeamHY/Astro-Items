---

local BICORN_USES_MALE = 3

local BICORN_USES_FEMALE = 6

local REPLACE_CHANCE = 0.5

---

Astro.Collectible.BICORN = Isaac.GetItemIdByName("Bicorn")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BICORN,
        "바이콘",
        "...",
        "{{Collectible77}}My Little Unicorn 등장 시 확률적으로 대체됩니다." ..
        "#사용 시 6초간 무적이 되며 빠르게 이동합니다." ..
        "#{{Blank}} 무적 상태에서 적이 죽을 경우 {{Collectible386}}Eraser 판정으로 영구히 삭제됩니다." ..
        "#스테이지당 사용 횟수가 제한됩니다:" ..
        "#{{Blank}} - 남성 캐릭터: " .. BICORN_USES_MALE .. "번" ..
        "#{{Blank}} - 여성 캐릭터: " .. BICORN_USES_FEMALE .. "번"
    )
end

local femaleCharacters = {}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        femaleCharacters = {
            PlayerType.PLAYER_MAGDALENE,
            PlayerType.PLAYER_MAGDALENE_B,
            PlayerType.PLAYER_EVE,
            PlayerType.PLAYER_EVE_B,
            PlayerType.PLAYER_BETHANY,
            PlayerType.PLAYER_BETHANY_B,
            Astro.Players.LEAH,
            Astro.Players.LEAH_B,
            Astro.Players.DIABELLSTAR,
            Astro.Players.DIABELLSTAR_B,
            Astro.Players.WATER_ENCHANTRESS,
            Astro.Players.WATER_ENCHANTRESS_B,
            Astro.Players.STELLAR,
            Astro.Players.STELLAR_B,
        }
    end
)

-- 여성 캐릭터 확인 함수
---@param player EntityPlayer
local function isFemaleCharacter(player)
    local playerType = player:GetPlayerType()
    
    for _, femaleType in ipairs(femaleCharacters) do
        if playerType == femaleType then
            return true
        end
    end
    
    return false
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
        local data = Astro.SaveManager.GetFloorSave(player)
        local usesThisStage = data["bicornUses"] or 0
        
        local maxUses = isFemaleCharacter(player) and BICORN_USES_FEMALE or BICORN_USES_MALE
        
        if usesThisStage >= maxUses then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end
        
        data["bicornUses"] = usesThisStage + 1
        
        player:UseActiveItem(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, false)
        
        data["bicornActiveUntil"] = Game():GetFrameCount() + 180
        
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.BICORN
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags DamageFlag
    ---@param source EntityRef
    ---@param countdownFrames integer
    function(_, entity, amount, damageFlags, source, countdownFrames)
        -- 적이 죽는 데미지인지 확인
        if entity:IsVulnerableEnemy() and entity.HitPoints - amount <= 0 then
            -- 모든 플레이어 확인
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
                
                if player:HasCollectible(Astro.Collectible.BICORN) then
                    local data = Astro.SaveManager.GetFloorSave(player)
                    local bicornActiveUntil = data["bicornActiveUntil"] or 0
                    
                    -- 바이콘이 활성화된 상태인지 확인
                    if Game():GetFrameCount() < bicornActiveUntil then
                        -- 적을 지우개 판정으로 처리
                        -- 적의 타입을 저장하여 영구적으로 제거
                        if not Astro.Data.ErasedEnemies then
                            Astro.Data.ErasedEnemies = {}
                        end
                        
                        local enemyKey = entity.Type .. "_" .. entity.Variant .. "_" .. entity.SubType
                        Astro.Data.ErasedEnemies[enemyKey] = true
                        
                        -- 즉시 제거
                        entity:Remove()
                        
                        -- 이펙트
                        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
                        poof:GetSprite().Color = Color(0.5, 0.5, 0.5, 1, 0, 0, 0)
                        
                        return false
                    end
                end
            end
        end
    end
)

-- MC_POST_NPC_INIT: 지워진 적은 생성되지 않도록
Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_INIT,
    ---@param npc EntityNPC
    function(_, npc)
        if Astro.Data.ErasedEnemies then
            local enemyKey = npc.Type .. "_" .. npc.Variant .. "_" .. npc.SubType
            
            if Astro.Data.ErasedEnemies[enemyKey] then
                npc:Remove()
            end
        end
    end
)

-- MC_POST_PLAYER_UPDATE: 남은 사용 횟수 표시
Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            
            if player:HasCollectible(Astro.Collectible.BICORN) then
                local data = Astro.SaveManager.GetFloorSave(player)
                local usesThisStage = data["bicornUses"] or 0
                local maxUses = isFemaleCharacter(player) and BICORN_USES_FEMALE or BICORN_USES_MALE
                local remainingUses = maxUses - usesThisStage
                
                -- 화면에 남은 사용 횟수 표시
                local position = Astro:ToScreen(player.Position)
                
                if remainingUses > 0 then
                    Isaac.RenderText(
                        tostring(remainingUses),
                        position.X - 6,
                        position.Y - 40,
                        1,
                        1,
                        1,
                        1
                    )
                else
                    Isaac.RenderText(
                        "X",
                        position.X - 6,
                        position.Y - 40,
                        1,
                        0.3,
                        0.3,
                        1
                    )
                end
            end
        end
    end
)

-- MC_POST_GAME_STARTED: 게임 시작 시 초기화
Astro:AddPriorityCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    CallbackPriority.IMPORTANT,
    function(_, isContinued)
        if not isContinued then
            -- 새 게임 시작 시 지워진 적 목록 초기화
            Astro.Data.ErasedEnemies = {}
        end
    end
)

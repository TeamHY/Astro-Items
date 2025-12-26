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
        "#{{Blank}} 무적 상태에서 적이 죽을 경우 같은 몬스터가 이번 게임 내에 등장하지 않습니다." ..
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

---@param player EntityPlayer
local function IsFemaleCharacter(player)
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
        
        local maxUses = IsFemaleCharacter(player) and BICORN_USES_FEMALE or BICORN_USES_MALE
        
        if usesThisStage >= maxUses then
            SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = true,
            }
        end
        
        player:UseActiveItem(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, false)
        SFXManager():Play(SoundEffect.SOUND_DEVIL_CARD)

        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
        effect:GetSprite().Color = Color(0, 0, 0, 1, 0, 0, 0)
        
        data["bicornUses"] = usesThisStage + 1
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
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        if npc:IsBoss() then
            return
        end

        if npc.Type == EntityType.ENTITY_FIREPLACE then
            return
        end

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            local data = Astro.SaveManager.GetFloorSave(player)
            local bicornActiveUntil = data["bicornActiveUntil"] or 0
            
            if Game():GetFrameCount() < bicornActiveUntil and player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN) then
                local runData = Astro.SaveManager.GetRunSave()

                if not runData.ErasedEnemies then
                    runData.ErasedEnemies = {}
                end
                
                local enemyKey = npc.Type .. "." .. npc.Variant .. "." .. npc.SubType
                runData.ErasedEnemies[enemyKey] = true
                
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector.Zero, nil)
                poof:GetSprite().Color = Color(0, 0, 0, 1, 0, 0, 0)

                local otherEntities = Isaac.FindByType(npc.Type, npc.Variant, npc.SubType)
                for _, entity in ipairs(otherEntities) do
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
                    effect:GetSprite().Color = Color(0, 0, 0, 1, 0, 0, 0)
                    entity:Remove()
                end

                break
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_INIT,
    ---@param npc EntityNPC
    function(_, npc)
        local data = Astro.SaveManager.GetRunSave()

        if data.ErasedEnemies then
            local enemyKey = npc.Type .. "." .. npc.Variant .. "." .. npc.SubType
            
            if data.ErasedEnemies[enemyKey] then
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector.Zero, nil)
                effect:GetSprite().Color = Color(0, 0, 0, 1, 0, 0, 0)
                npc:Remove()
            end
        end
    end
)

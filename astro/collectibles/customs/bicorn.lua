Astro.Collectible.BICORN = Isaac.GetItemIdByName("Bicorn")

---

local BICORN_USES_MALE = 3

local BICORN_USES_FEMALE = 6

---

local femaleCharacters = {}

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

        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.BICORN,
                "바이콘",
                "처녀는 탈 수 없는 말",
                "{{Timer}} 6초 동안:" ..
                "#{{IND}}↑ {{SpeedSmall}}이동속도 +0.28" ..
                "#{{IND}} 무적 상태가 되며 접촉한 적에게 0.5초당 20의 피해를 줍니다." ..
                "#{{IND}} 무적 상태에 죽인 몬스터는 해당 게임에서 제외되어 다시 등장하지 않습니다." ..
                "#!!! 스테이지 당 남성 캐릭터는 " .. BICORN_USES_MALE .. "번, 여성 캐릭터는 " .. BICORN_USES_FEMALE .. "번 사용할 수 있습니다."
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.BICORN),
                femaleCharacters,
                "6번 사용 가능",
                nil, "ko_kr", nil
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.BICORN,
                "Bicorn", "...",
                "{{Timer}} Receive for 6 seconds:" ..
                "#{{IND}}↑ {{Speed}} +0.28 Speed" ..
                "#{{IND}} Isaac can't shoot but deals 40 contact damage per second" ..
                "#{{IND}} Grants invincibility, and enemies killed during this state will not spawn again for the rest of the run" ..
                "#!!! Can only be used " .. BICORN_USES_MALE .. " times per floor by male characters and " .. BICORN_USES_FEMALE .. " times by female characters",
                nil, "en_us"
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.BICORN),
                femaleCharacters,
                "Can be used 6 times",
                nil, "en_us", nil
            )
        end
    end
)

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

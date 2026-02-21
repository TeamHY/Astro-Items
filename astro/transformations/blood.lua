---

-- blood-of-hatred와 별도 확률이며 동시에 한 몬스터에 발동될 시 더 긴 지속 시간으로 적용됩니다.

local BLEEDING_CHANCE = 0.2 -- 현재 행운에 영향을 받지 않습니다.

local BLEEDING_DURATION = 150

local ENEMY_BLEEDING_COOLDOWN_TIME = 30 -- 몬스터 당 쿨타임

local EXTRA_DAMAGE_MULTIPLIER = 1 -- 추가 대미지 배율

local EXTRA_DAMAGE_SOUND_ID = SoundEffect.SOUND_MEATY_DEATHS

local EXTRA_DAMAGE_SOUND_VOLUME = 1

local JEJACK_WANRYO = false    -- 아이템 리스트 완성 후에 true로 바꾸세요

---

if not JEJACK_WANRYO then
    return
end

local isc = require("astro.lib.isaacscript-common")

Astro.TransformationBlood = {}

Astro.TransformationBlood.collectibles = {
    CollectibleType.COLLECTIBLE_SAD_ONION,
    CollectibleType.COLLECTIBLE_1UP,
    CollectibleType.COLLECTIBLE_SPOON_BENDER,
}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local bloodIcon = Sprite()
            bloodIcon:Load("gfx/ui/eid/astro_transform.anm2", true)
            EID:addIcon("TransformBlood", "Transformation3", 0, 16, 16, 0, -1, bloodIcon)
            EID:createTransformation("TransformBlood", "Bloodbath")

            for _, collectibleType in ipairs(Astro.TransformationBlood.collectibles) do
                EID:assignTransformation("collectible", collectibleType, "TransformBlood")
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:Contain(Astro.TransformationBlood.collectibles, collectibleType) and Astro:IsFirstAdded(collectibleType) then
            -- 기존 세트 효과와 동일한 판정을 위해 모래시계 영향을 받지 않습니다.
            -- TODO: 세트 효과 매커니즘 개선 필요
            local data = Astro.SaveManager.GetRunSave(player, true)
            data.transformationBloodCount = (data.transformationBloodCount or 0) + 1

            if data.transformationBloodCount == 3 then
                local Flavor
                if Options.Language == "kr" or REPKOR then
                    Flavor = "유혈사태!"
                else
                    Flavor = "Bloodbath!"
                end

                SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER)
                Game():GetHUD():ShowItemText(Flavor)
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.PLAYER_DEAL_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param player EntityPlayer
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, player, countdownFrames)
        local playerData = Astro.SaveManager.GetRunSave(player, true)

        if playerData.transformationBloodCount and playerData.transformationBloodCount >= 3 then
            local entityData = entity:GetData()

            if not entityData.TransformationBlood then
                entityData.TransformationBlood = {
                    Cooldown = -1,
                }
            end

            if entityData.TransformationBlood.Cooldown < Game():GetFrameCount() then
                if not entityData.BloodOfHatred then
                    entityData.BloodOfHatred = {
                        DurationTime = entity.FrameCount + BLEEDING_DURATION
                    }
                else
                    entityData.BloodOfHatred.DurationTime = math.max(entity.FrameCount + BLEEDING_DURATION, entityData.BloodOfHatred.DurationTime)
                end

                entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
                entity:TakeDamage(amount * EXTRA_DAMAGE_MULTIPLIER, 0, EntityRef(player), 0)

                entityData.TransformationBlood.Cooldown = Game():GetFrameCount() + ENEMY_BLEEDING_COOLDOWN_TIME

                SFXManager():Play(EXTRA_DAMAGE_SOUND_ID, EXTRA_DAMAGE_SOUND_VOLUME)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            local data = Astro.SaveManager.GetRunSave(player, true)

            if data.transformationBloodCount and data.transformationBloodCount >= 3 then
                local entities = Isaac.GetRoomEntities()
                local rng = player:GetCollectibleRNG(Astro.Collectible.BLOOD_OF_HATRED)

                for _, entity in ipairs(entities) do
                    if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
                        if rng:RandomFloat() < BLEEDING_CHANCE then
                            local entityData = entity:GetData()

                            if not entityData.BloodOfHatred then
                                entityData.BloodOfHatred = {
                                    DurationTime = entity.FrameCount + BLEEDING_DURATION
                                }
                            else
                                entityData.BloodOfHatred.DurationTime = math.max(entity.FrameCount + BLEEDING_DURATION, entityData.BloodOfHatred.DurationTime)
                            end
    
                            entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
                        end
                    end
                end

                break
            end
        end
    end
)

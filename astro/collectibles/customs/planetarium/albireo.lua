local isc = require("astro.lib.isaacscript-common")
Astro.Collectible.ALBIREO = Isaac.GetItemIdByName("Albireo")

---

local ALL_STAT_MULTIPLIER = 1.1

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.ALBIREO,
                "알비레오",
                "하나가 될 수 없는 쌍성",
                "!!! 일회용 !!!" ..
                "#사용 시 그 방의 별자리/행성 아이템을 강화합니다."
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.ALBIREO),
                { Astro.Players.STELLAR },
                {
                    "!!! 일회용 !!!#사용 시",
                    "사용 시"
                },
                nil, "ko_kr", nil
            )
            EID:addCondition(
                "5.100." .. tostring(Astro.Collectible.ALBIREO),
                { "5.100." .. tostring(Astro.Collectible.CYGNUS) },
                {   
                    "강화합니다.",
                    "강화합니다." ..
                    "#{{Collectible" .. Astro.Collectible.CYGNUS .. "}} 소지중일 때:" ..
                    "#{{IND}}↑ {{TearsSmall}}연사 배율 x1.1" ..
                    "#{{IND}}↑ {{DamageSmall}}공격력 배율 x1.1" ..
                    "#{{IND}}↑ {{SpeedSmall}}이동속도 배율 x1.1" ..
                    "#{{IND}}↑ {{RangeSmall}}사거리 배율 x1.1" ..
                    "#{{IND}}↑ {{ShotspeedSmall}}탄속 배율 x1.1" ..
                    "#{{IND}}↑ {{LuckSmall}}행운 배율 x1.1"
                },
                nil, "ko_kr", nil
            )

            ----
            
            Astro.EID:AddCollectible(
                Astro.Collectible.ALBIREO,
                "Albireo", "",
                "!!! SINGLE USE !!!" ..
                "#Upgrades zodiac/planet items in the room",
                nil, "en_us"
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.ALBIREO),
                { Astro.Players.STELLAR },
                {
                    "!!! SINGLE USE !!!#Upgrades",
                    "Upgrades"
                },
                nil, "en_us", nil
            )
            EID:addCondition(
                "5.100." .. tostring(Astro.Collectible.ALBIREO),
                { "5.100." .. tostring(Astro.Collectible.CYGNUS) },
                {   
                    "in the room",
                    "in the room" ..
                    "#{{Collectible" .. Astro.Collectible.CYGNUS .. "}} While held:" ..
                    "#{{IND}}↑ {{Tears}} x1.1 Fire rate multiplier" ..
                    "#{{IND}}↑ {{Damage}} x1.1 Damage multiplier" ..
                    "#{{IND}}↑ {{Speed}} x1.1 Speed multiplier" ..
                    "#{{IND}}↑ {{Range}} x1.1 Range multiplier" ..
                    "#{{IND}}↑ {{Shotspeed}} x1.1 Shot speed multiplier" ..
                    "#{{IND}}↑ {{Luck}} x1.1 Luck multiplier"
                },
                nil, "en_us", nil
            )

            ----

            ---@param id CollectibleType
            local function GetMorphString(id)
                local eidKor = EID:getLanguage() == "ko_kr"
                local newItemName = "{{Collectible" .. id .. "}} " .. EID:getObjectName(5, 100, id)
                return eidKor and ("{{ColorYellow}}" .. newItemName .. "{{CR}}(으)로 변환") or ("Rerolls to {{ColorYellow}}" .. newItemName .. "{{CR}}")
            end

            local function AlbireoModifierCondition(descObj)
                if descObj.ObjType == 5 and descObj.ObjVariant == 100 then
                    local numPlayers = Game():GetNumPlayers()
                    for i = 0, numPlayers - 1 do
                        local player = Isaac.GetPlayer(i)
                        if player:HasCollectible(Astro.Collectible.ALBIREO) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(Astro.Collectible.ALBIREO)]) then
                            return true
                        end
                    end
                end
            end

            local function AlbireoModifierCallback(descObj)
                for targetItemId, newItemData in pairs(Astro.PLANETARIUM_UPGRADE_LIST) do
                    if descObj.ObjSubType == targetItemId then
                        local iconStr = "#{{Collectible" .. Astro.Collectible.ALBIREO .. "}} "
                        local text = GetMorphString(newItemData.Id)
                        EID:appendToDescription(descObj, iconStr .. text)
                    end
                end
                return descObj
            end

            EID:addDescriptionModifier("Albireo Modifier", AlbireoModifierCondition, AlbireoModifierCallback)
        end
    end
)

local ALIBREO_POOF_VARIANT = 3115

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            local pickup = entity:ToPickup()
            local id = pickup.SubType

            if Astro.PLANETARIUM_UPGRADE_LIST[id] then
                pickup:Morph(pickup.Type, pickup.Variant, Astro.PLANETARIUM_UPGRADE_LIST[id].Id, true)
                Game():SpawnParticles(pickup.Position + Vector(0, 0.1), ALIBREO_POOF_VARIANT, 1, 0)
            end
        end

        if playerWhoUsedItem:GetPlayerType() == Astro.Players.STELLAR then
            return {
                Discharge = true,
                Remove = false,
                ShowAnim = true,
            }
        end

        local sfx = SFXManager()
        if SoundEffect.SOUND_ITEM_RAISE and sfx:IsPlaying(SoundEffect.SOUND_ITEM_RAISE) then
            sfx:Stop(SoundEffect.SOUND_ITEM_RAISE)
        end
        sfx:Play(Astro.SoundEffect.ALBIREO, 2)

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.ALBIREO
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local sprite = effect:GetSprite()
        sprite.Scale = Vector(1.5, 1.5)
        effect.SpriteOffset = Vector(0, -8)

        if sprite:IsFinished() then
            effect:Remove()
        end
    end,
    ALIBREO_POOF_VARIANT
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:HasCollectible(Astro.Collectible.ALBIREO) then
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        end
    end,
    Astro.Collectible.CYGNUS
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@diagnostic disable-next-line: param-type-mismatch
    Astro.CallbackPriority.MULTIPLY,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function (_, player, cacheFlag)
        if not player:HasCollectible(Astro.Collectible.ALBIREO) or not player:HasCollectible(Astro.Collectible.CYGNUS) then return end

        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = ((player.MaxFireDelay + 1) / ALL_STAT_MULTIPLIER) - 1
        end

        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_LUCK and player.Luck > 0 then
            player.Luck = player.Luck * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed * ALL_STAT_MULTIPLIER
        end
    end
)

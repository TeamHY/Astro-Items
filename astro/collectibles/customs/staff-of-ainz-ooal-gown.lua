---

local USE_SOUND = Astro.SoundEffect.STAFF_OF_AINZ_OOAL_GOWN

local USE_SOUND_VOLUME = 1

local CHARGE_MULTIPLY = 0.2 -- 대미지 당 충전량 비율

---

Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN = Isaac.GetItemIdByName("Staff of Ainz Ooal Gown")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN,
                "스태프 오브 아인즈 울 고운",
                "가볼까, 우리 길드의 상징이여",
                "{{Timer}} 10초 동안:" ..
                "#{{IND}} 캐릭터가 무적 상태가 됩니다." ..
                "#사용 시 방 중앙에 블랙홀을 생성합니다." ..
                "#{{Collectible512}} 블랙홀은 6초동안 지속되며 주변 장애물들을 모두 파괴합니다." ..
                "#{{Battery}} 적에게 일정량의 피해를 줄 때마다 액티브 충전량을 한칸 충전합니다." ..
                "#!!! 한 칸 충전에 필요한 피해량:" ..
                "#{{Blank}} (스테이지 * 20) + 40"
            )
            
            Astro.EID:AddCollectible(
                Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN,
                "Staff of Ainz Ooal Gown", "",
                "{{Timer}} Receive for 10 seconds:" ..
                "#{{IND}} Invincibility" ..
                "#Spawns black hole in room center:" ..
                "#{{IND}} Deals 6 damage per second" ..
                "#{{IND}} Destroys nearby rocks" ..
                "#{{IND}} Lasts 6 seconds" ..
                "#{{Battery}} Dealing damage to enemies slowly fills up the charge bar" ..
                "#Damage needed per charge increases each floor",
                nil, "en_us"
            )
        end
    end
)

---@param player EntityPlayer
---@param charge number
local function UpdateCharge(player, charge)
    for i = 0, ActiveSlot.SLOT_POCKET2 do
        if player:GetActiveItem(i) == Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN then
            player:SetActiveCharge(math.floor(charge), i)
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if
            player ~= nil and player:HasCollectible(Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN) and
                entity:IsVulnerableEnemy() and
                entity.Type ~= EntityType.ENTITY_FIREPLACE
         then
            if not (source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.BLACK_HOLE) then
                local data = Astro:GetPersistentPlayerData(player)

                if data.StaffOfAinzOoalGown == nil then
                    data.StaffOfAinzOoalGown = 0
                end

                data.StaffOfAinzOoalGown = data.StaffOfAinzOoalGown + amount * CHARGE_MULTIPLY

                if data.StaffOfAinzOoalGown >= 100 then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
                        if data.StaffOfAinzOoalGown >= 200 then
                            data.StaffOfAinzOoalGown = 200
                        end
                    else
                        data.StaffOfAinzOoalGown = 100
                    end
                end

                UpdateCharge(player, data.StaffOfAinzOoalGown)
            end
        end
    end
)

local enableRealBlackHole = false

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN) then
                local data = Astro:GetPersistentPlayerData(player)

                if data.StaffOfAinzOoalGown == nil then
                    data.StaffOfAinzOoalGown = 0
                end

                UpdateCharge(player, data.StaffOfAinzOoalGown)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local data = Astro:GetPersistentPlayerData(playerWhoUsedItem)

        if not (data.StaffOfAinzOoalGown and data.StaffOfAinzOoalGown >= 100) then
            return {
                Discharge = true,
                Remove = false,
                ShowAnim = false,
            }
        end

        data.StaffOfAinzOoalGown = data.StaffOfAinzOoalGown - 100

        playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)

        local room = Game():GetRoom()
        local blackhole = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLACK_HOLE, 0, room:GetCenterPos(), Vector.Zero, nil)
        local sprite = blackhole:GetSprite()
        
        sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/Staff of Ainz Ooal Gown.png")
        sprite:LoadGraphics()

        SFXManager():Play(USE_SOUND, USE_SOUND_VOLUME)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN
)

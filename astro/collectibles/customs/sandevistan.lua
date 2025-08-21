---

local PENALTY_CHANCE = 0.2

---

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SANDEVISTAN = Isaac.GetItemIdByName("Sandevistan")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SANDEVISTAN,
        "산데비스탄",
        "...",
        "{{Collectible677}} 사용 시 잠시 유체이탈 상태가 됩니다." ..
        "#{{ArrowGrayRight}} David, Lucy의 경우 순간적으로 높은 {{DamageSmall}}공격력과 {{TearsSmall}}연사를 얻고 10초간 무적이 됩니다." ..
        "#{{ArrowGrayRight}} David, Lucy가 아닌 경우 20%의 확률로 {{Collectible582}}Wavy Cap이 발동됩니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param item CollectibleType
    ---@param rng RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, item, rng, player, useFlags, activeSlot, varData)
        local discharge = true
        local remove = false
        local showAnim = false

        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION, "ASTRO_SANDEVISTAN") then
            discharge = false
            return {
                Discharge = discharge,
                Remove = remove,
                ShowAnim = showAnim
            }
        end
        --[[
     if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION) then
         discharge = false
         goto skipRiraUniform
     end
  ]]
        local clearFlag = false

        local room = Game():GetRoom()
        local level = Game():GetLevel()
        local currentRoomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
        if room:IsClear() then
            clearFlag = true
            if not currentRoomDesc.NoReward then
                currentRoomDesc.NoReward = true
            end
            room:SetClear(false)
        end

        hiddenItemManager:AddForRoom(player, CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION, 150, 1, "ASTRO_SANDEVISTAN")
        player:TakeDamage(
            1,
            DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_INVINCIBLE |
                DamageFlag.DAMAGE_FAKE,
            EntityRef(player),
            60
        )
        player:TakeDamage(
            1,
            DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_INVINCIBLE |
                DamageFlag.DAMAGE_FAKE,
            EntityRef(player),
            60
        )

        Astro:ScheduleForUpdate(
            function()
                local effects = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 10)
                for _, e in ipairs(effects) do
                    if e.Position:DistanceSquared(player.Position) <= 60 ^ 2 then
                        --  wakaba.Log("Forgotten Soul form Rira Uniform found, removing...")
                        e:Remove()
                    end
                end
                local effects2 = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL)
                for _, e in ipairs(effects2) do
                    if e.Position:DistanceSquared(player.Position) <= 60 ^ 2 then
                        --  wakaba.Log("Haemo trail form Rira Uniform found, removing...")
                        e:Remove()
                    end
                end
                if clearFlag then
                    currentRoomDesc.NoReward = false
                end
            end,
            1
        )
        Astro:ScheduleForUpdate(
            function()
                player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION, 2)
            end,
            150
        )
        ::skipRiraUniform::

        if Astro:IsDavidMartinez(player) then
            player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true)
            player:GetEffects():AddNullEffect(NullItemID.ID_CAMO_BOOST, false, 30)
        else
            if rng:RandomFloat() < PENALTY_CHANCE then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, false)
            end
        end

        return {
            Discharge = discharge,
            Remove = remove,
            ShowAnim = showAnim
        }
    end,
    Astro.Collectible.SANDEVISTAN
)

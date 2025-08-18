---

local COIN_TIMEOUT = 300

-- 아래는 내부 쿨타임 관련

local SPAWN_CHANCE = 1

local LUCK_MULTIPLY = 1 / 100

local COOLDOWN_TIME = 75

---

Astro.Collectible.COIN_DETONATOR = Isaac.GetItemIdByName("Coin Detonator")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.COIN_DETONATOR,
        "동전 기폭제",
        "원격으로 동전 폭파",
        "#소지중일 때 아래 효과 발동;" ..
        "#{{ArrowRightGray}} {{Collectible375}} Host Hat 효과가 적용됩니다." ..
        "#{{ArrowRightGray}} 공격이 적에게 명중 시 10초 후 사라지는 끈적이 니켈을 소환합니다." ..
        "#사용 시 소환한 끈적이 니켈이 기가 폭탄으로 변해 터집니다."
    )
end

Astro:AddCallback(
    Astro.Callbacks.PLAYER_DEAL_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param player EntityPlayer
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, player, countdownFrames)
        local data = player:GetData()

        if player:HasCollectible(Astro.Collectible.COIN_DETONATOR) and (data["coinDetonatorCooldown"] == nil or data["coinDetonatorCooldown"] < Game():GetFrameCount()) then
            local rng = player:GetCollectibleRNG(Astro.Collectible.COIN_DETONATOR)
            local baseChance = SPAWN_CHANCE * player:GetCollectibleNum(Astro.Collectible.COIN_DETONATOR)

            if rng:RandomFloat() < baseChance + player.Luck * LUCK_MULTIPLY then
                local stickyNickel = Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 6, entity.Position):ToPickup()
                stickyNickel.Timeout = COIN_TIMEOUT

                data["coinDetonatorCooldown"] = Game():GetFrameCount() + COOLDOWN_TIME / player:GetCollectibleNum(Astro.Collectible.COIN_DETONATOR)
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
        local stickyNickels = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 6)
        
        for _, coin in ipairs(stickyNickels) do
            if coin:ToPickup().Timeout == -1 then
                goto continue
            end

            Isaac.Spawn(EntityType.ENTITY_BOMB, 17, 0, coin.Position, Vector.Zero, nil)
            coin:Remove()

            ::continue::
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.COIN_DETONATOR
)

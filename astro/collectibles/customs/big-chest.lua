---

local ROOM_REWARD_CHANCE = 0.25

local TRINKET_ROOMS_INTERVAL = 5

---

Astro.Collectible.BIG_CHEST = Isaac.GetItemIdByName("Big Chest")

local BIG_CHEST_VARIANT = 3108

---@type Astro.Entity[]
local ROOM_REWARD_ITEMS = {
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_HEART, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_COIN, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_KEY, SubType = 0},
}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIG_CHEST,
                "큰 상자",
                "안락한 곳이야",
                "방 클리어 시 25% 확률로 {{Heart}}하트, {{Coin}}동전, {{Key}}열쇠 중 하나를 소환합니다." ..
                "#5개의 방을 클리어할 때마다 무작위 장신구를 소환합니다." ..
                "#!!! 소지 중일 때 {{Collectible362}}Lil Chest가 등장하지 않습니다."
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if selectedCollectible == CollectibleType.COLLECTIBLE_LIL_CHEST then
                    if Astro:HasCollectible(Astro.Collectible.BIG_CHEST) then
                        return {
                            reroll = true,
                            modifierName = "Big Chest"
                        }
                    end
                end
                return false
            end
        )
    end
)



Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:AddToFollowers()

        local sprite = familiar:GetSprite()
	    sprite:Play("Float")
    end,
    BIG_CHEST_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:FollowParent()

        local sprite = familiar:GetSprite()

        if sprite:IsFinished("Spawn") then
            sprite:Play("Float")
        end
    end,
    BIG_CHEST_VARIANT
)

-- 방 클리어 시 보상 드랍
Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function(_, rng, spawnPosition)
        local chests = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, BIG_CHEST_VARIANT)

        for _, chest in ipairs(chests) do
            local player = chest:ToFamiliar().Player
            local rng = player:GetCollectibleRNG(Astro.Collectible.BIG_CHEST)

            if rng:RandomFloat() < ROOM_REWARD_CHANCE then
                local sprite = chest:GetSprite()
                sprite:Play("Spawn", true)
                
                Astro:SpawnEntity(ROOM_REWARD_ITEMS[rng:RandomInt(1, #ROOM_REWARD_ITEMS)], chest.Position)
            end

            local data = Astro.SaveManager.GetRunSave(chest)
            data["roomsClearedCount"] = (data["roomsClearedCount"] or 0) + 1

            if data["roomsClearedCount"] % TRINKET_ROOMS_INTERVAL == 0 then
                local itemPool = Game():GetItemPool()
                local trinket = itemPool:GetTrinket()
                
                local sprite = chest:GetSprite()
                sprite:Play("Spawn", true)
                
                Astro:SpawnTrinket(trinket, chest.Position)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        player:CheckFamiliar(BIG_CHEST_VARIANT, player:GetCollectibleNum(Astro.Collectible.BIG_CHEST), player:GetCollectibleRNG(Astro.Collectible.BIG_CHEST))
    end,
    CacheFlag.CACHE_FAMILIARS
)

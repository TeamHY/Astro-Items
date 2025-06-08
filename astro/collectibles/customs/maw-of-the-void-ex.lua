---

local BLACK_HEART_SPAWN_CHANCE = 0.5

local MAX_BLACK_HEARTS_PER_ROOM = 5

local DAMAGE_INCREMENT = 1.0

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.MAW_OF_THE_VOID_EX = Isaac.GetItemIdByName("Maw Of The Void EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.MAW_OF_THE_VOID_EX,
                "초 공허의 구멍",
                "향상된 어둠의 입구",
                "↑ {{DamageSmall}}공격력 +1" ..
                "#{{Collectible399}} Maw Of The Void 효과가 적용됩니다." ..
                "#적을 처치할 때 10% 확률로 {{BlackHeart}} 블랙하트를 떨어뜨립니다." ..
                "#!!! 소지중일 때 {{Collectible399}}Maw Of The Void이 등장하지 않습니다."
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.MAW_OF_THE_VOID_EX) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID,
                        modifierName = "Maw Of The Void EX"
                    }
                end
        
                return false
            end
        )
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID)
        end
    end,
    Astro.Collectible.MAW_OF_THE_VOID_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID)
        end
    end,
    Astro.Collectible.MAW_OF_THE_VOID_EX
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        Astro.Data["MawOfTheVoidEx"] = MAX_BLACK_HEARTS_PER_ROOM
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        if Astro:HasCollectible(Astro.Collectible.MAW_OF_THE_VOID_EX) and Astro.Data["MawOfTheVoidEx"] > 0 then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.MAW_OF_THE_VOID_EX)

            if rng:RandomFloat() < BLACK_HEART_SPAWN_CHANCE then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 6, entityNPC.Position, Vector(0, 0), entityNPC)
                Astro.Data["MawOfTheVoidEx"] = Astro.Data["MawOfTheVoidEx"] - 1
            end
        end
    end
)

Astro:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.MAW_OF_THE_VOID_EX) then
            player.Damage = player.Damage + DAMAGE_INCREMENT
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

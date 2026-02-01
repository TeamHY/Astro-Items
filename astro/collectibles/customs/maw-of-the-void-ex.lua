---

local BLACK_HEART_SPAWN_CHANCE = 0.1

local MAX_BLACK_HEARTS_PER_ROOM = 1

local DAMAGE_INCREMENT = 1.0

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.MAW_OF_THE_VOID_EX = Isaac.GetItemIdByName("Maw Of The Void EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.MAW_OF_THE_VOID_EX,
                "초 공허의 구렁텅이",
                "회개하지 못한 자들의 어둠", -- 간접적으로 리펜 이전 구렁텅이라 설명
                "!!! 획득 이후 {{Collectible399}}Maw Of The Void 미등장" ..
                "#↑ {{DamageSmall}}공격력 +" .. string.format("%.f", DAMAGE_INCREMENT) ..
                "#{{Chargeable}} 공격키를 2.5초 이상 누르면 충전되며 공격키를 떼면 캐릭터 주위에 검은 고리가 둘러져 접촉한 적에게 최대 공격력 x30의 피해를 주며;" ..
                "#{{ArrowGrayRight}} 고리로 적 처치 시 " .. string.format("%.f", BLACK_HEART_SPAWN_CHANCE * 100) .. "% 확률로 {{BlackHeart}}블랙하트를 드랍합니다.",
                -- 중첩 시
                "무효과"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.MAW_OF_THE_VOID_EX,
                "Maw Of The Void EX", "",
                "!!! {{Collectible399}} Maw Of The Void doesn't appear after pickup" ..
                "#↑ {{Damage}} +" .. string.format("%.f", DAMAGE_INCREMENT) .. " Damage" ..
                "#{{Chargeable}} Shooting tears for 2.35 seconds and releasing the fire button creates a black brimstone ring around Isaac" ..
                "#{{ArrowGrayRight}} It deals 30x Isaac's damage over 2 seconds" ..
                "#{{BlackHeart}} Enemies killed by the black ring have a " .. string.format("%.f", BLACK_HEART_SPAWN_CHANCE * 100) .. "% chance to drop a Black Heart",
                -- Stacks
                "No effect",
                "en_us"
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

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SUPER_ROCKET_IN_A_JAR = Isaac.GetItemIdByName("Super Rocket in a Jar")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SUPER_ROCKET_IN_A_JAR,
                "슈퍼 로켓 든 병",
                "...",
                "#{{Collectible583}} Rocket in a Jar 효과가 적용됩니다." ..
                "#로켓이 기가 로켓으로 변경됩니다."
            )
        end
    end
)



Astro:AddCallback(
    ModCallbacks.MC_POST_BOMB_INIT,
    ---@param bomb EntityBomb
    function(_, bomb)
        local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
        if player and player:HasCollectible(Astro.Collectible.SUPER_ROCKET_IN_A_JAR) then
            Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_ROCKET_GIGA, 0, bomb.Position, bomb.Velocity, bomb.SpawnerEntity)
            bomb:Remove()
        end
    end,
    19
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR, player:HasCollectible(Astro.Collectible.SUPER_ROCKET_IN_A_JAR) and 1 or 0, "ASTRO_ASTRO_SUPER_ROCKET_IN_A_JAR")
    end
)

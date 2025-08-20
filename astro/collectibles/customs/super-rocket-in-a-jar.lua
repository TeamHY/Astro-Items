local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SUPER_ROCKET_IN_A_JAR = Isaac.GetItemIdByName("Super Rocket in a Jar")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SUPER_ROCKET_IN_A_JAR,
                "슈퍼 로켓 든 병",
                "엄청난 로켓 발사! + 폭탄 5개",
                "↑ {{Bomb}}폭탄 +5" ..
                "#{{Collectible583}} 폭탄 대신 기가 로켓이 나가며 기가 로켓은 캐릭터의 공격방향으로 날아가 폭발합니다."
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

Astro.Collectible.QUASAR = Isaac.GetItemIdByName("Quasar")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.QUASAR,
                "퀘이사",
                "초강력 블랙홀",
                "방마다 처음으로 죽은 적의 위치에 적들을 모두 빨아들여 붙잡아놓는 블랙홀을 소환합니다." ..
                "#{{Collectible512}} 블랙홀은 6초동안 지속되며 주변 장애물들을 모두 파괴합니다." ..
                "#방 클리어 시 캐릭터가 10초간 무적 상태가 됩니다." ..
                "#!!! 패널티 피격 시 해당 피격을 무효화하는 대신 이 아이템은 제거됩니다.",
                -- 중첩 시
                "중첩 시 방을 입장하면 10초동안 무적"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.QUASAR,
                "Quasar", "",
                "{{Collectible512}} Spawns black hole at first killed enemy in the room:" ..
                "#{{IND}} Deals 6 damage per second" ..
                "#{{IND}} Destroys nearby rocks" ..
                "#{{IND}} Lasts 6 seconds" ..
                "#Invincibility for 10 seconds on room clear" ..
                "#!!! Taking damage will remove this item instead of negating the damage",
                -- Stacks
                "On stacking, entering a room has invincibility for 10 seconds",
                "en_us"
            )
        end
    end
)

local remaining = 0

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        remaining = 1

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local quasarNum = player:GetCollectibleNum(Astro.Collectible.QUASAR)

            if not Game():GetRoom():IsClear() and quasarNum >= 2 then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.QUASAR) and remaining > 0 and entityNPC.Type ~= EntityType.ENTITY_FIREPLACE then
                local blackhole = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLACK_HOLE, 0, entityNPC.Position, Vector.Zero, player)
                local sprite = blackhole:GetSprite()
                
                sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/Quasar.png")
                sprite:LoadGraphics()

                remaining = remaining - 1

                break
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.QUASAR) then
                -- local entities = Isaac.GetRoomEntities()

                -- for _, entity in ipairs(entities) do
                --     if entity.Type ~= EntityType.ENTITY_EFFECT and entity.Variant == EffectVariant.BLACK_HOLE then
                --         entity:Remove()
                --     end
                -- end

                player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)

                -- break
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.QUASAR) then
            player:RemoveCollectible(Astro.Collectible.QUASAR)
            return false
        end
    end
)

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM = Isaac.GetItemIdByName("Astro Star of Bethlehem")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM,
                "베들레헴의 한별",
                "빛을 경배하라",
                "클리어하지 않은 방에 입장 시 오라가 생깁니다." ..
                "#캐릭터가 오라 안에 있을 시:" ..
                "#{{IND}}↑ {{TearsSmall}}연사 배율 x2.5" ..
                "#{{IND}}↑ {{DamageSmall}}공격력 배율 x1.2" ..
                "#{{IND}} 공격에 유도 효과가 생깁니다.",
                -- 중첩 시
                "중첩 시 적 탄환에 맞았을 때 50% 확률로 피해를 무시하며, 방 입장 시 사거리가 3 증가하고 공격이 적에게 유도됩니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM,
                "Astro Star of Bethlehem", "",
                "Slowly travels from the uncleared rooms to the {{BossRoom}} Boss Room" ..
                "#Standing in its aura grants:" ..
                "#{{IND}}↑ {{Tears}} x2.5 Tears multiplier" ..
                "#{{IND}}↑ {{Damage}} x1.2 Damage multiplier" ..
                "#{{IND}} Homing Tears",
                -- Stacks
                "Stacks has a 50% chance to block enemy shots, and upon entering a room, their range increases by 3 and homing tears",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local room = Game():GetRoom()

        if room:IsClear() then
            return
        end

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM) then
                if player:GetCollectibleNum(Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM) > 1 then
                    player:UseCard(Card.CARD_MAGICIAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                end

                hiddenItemManager:AddForRoom(player, CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM, nil, 1, "ASTRO_ASTRO_STAR_OF_BETHLEHEM")
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM, "ASTRO_ASTRO_STAR_OF_BETHLEHEM")
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_INFAMY, player:GetCollectibleNum(Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM) > 1 and 1 or 0, "ASTRO_ASTRO_STAR_OF_BETHLEHEM")
    end
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        if Astro:HasCollectible(Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM) and familiar.Variant == FamiliarVariant.STAR_OF_BETHLEHEM then
            local sprite = familiar:GetSprite()
            sprite:ReplaceSpritesheet(0, "gfx/familiar/astro_star_of_bethlehem.png")
            sprite:LoadGraphics()
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    ---@param effect EntityEffect
    function(_, effect)
        if Astro:HasCollectible(Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM) and effect.Variant == EffectVariant.HALLOWED_GROUND then
            local sprite = effect:GetSprite()
            sprite.Color = Color(1, 1, 1, 1, 227 / 255, 142 / 255, 230 / 255)
        end
    end
)

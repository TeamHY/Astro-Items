local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM = Isaac.GetItemIdByName("Astro Star of Bethlehem")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM,
        "베들레헴의 한별",
        "빛을 경배하라",
        "클리어하지 않은 방에 입장 시 {{Collectible651}}Star of Bethlehem를 획득합니다. (방 클리어 시 제거)" ..
        "#!!! 중첩 시 아래 효과 적용;" ..
        "#{{ArrowGrayRight}} {{Collectible242}} 적 탄환에 맞았을 때 50% 확률로 피해를 무시합니다." ..
        "#{{ArrowGrayRight}} {{Collectible192}} 방 입장 시 {{RangeSmall}}사거리 +3#{{Blank}} 공격이 적에게 유도됩니다."
    )
end


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

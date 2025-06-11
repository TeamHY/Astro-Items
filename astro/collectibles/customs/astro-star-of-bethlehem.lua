---

local UPGRADE_CHANCE = 0.5

---

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM = Isaac.GetItemIdByName("Astro Star of Bethlehem")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM,
        "아스트로 베들레헴의 별",
        "...",
        "클리어하지 않은 방에 입장 시 {{Collectible651}}Star of Bethlehem를 획득합니다. 방 클리어 시 제거됩니다." ..
        "#{{ArrowGrayRight}}중첩 시 {{Collectible242}}Infamy 효과가 적용되고 방 입장 시 {{Card2}}I - The Magician이 발동됩니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if selectedCollectible == CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM)

            if rng:RandomFloat() < UPGRADE_CHANCE then
                return Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM
            end
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

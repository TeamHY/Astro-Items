---

local UPGRADE_CHANCE = 0.5

---

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.ASTRO_GODHEAD = Isaac.GetItemIdByName("Astro Godhead")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ASTRO_GODHEAD,
                "아스트로 갓헤드",
                "...",
                "{{Collectible331}}Godhead 효과가 적용됩니다." ..
                "#오라의 공격력이 캐릭터 공격력의 30%로 적용됩니다." ..
                "#{{ArrowGrayRight}} 중첩 시 오라의 공격력이 합 연산으로 증가합니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if selectedCollectible == CollectibleType.COLLECTIBLE_GODHEAD then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.ASTRO_GODHEAD)

            if rng:RandomFloat() < UPGRADE_CHANCE then
                return Astro.Collectible.ASTRO_GODHEAD
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        if amount == 2 and source.Entity ~= nil and source.Entity.Type == 2 and entity.Type ~= 1 then
            local player = Astro:GetPlayerFromEntity(source.Entity)
            local tear = source.Entity:ToTear()
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.ASTRO_GODHEAD) and tear.TearFlags & TearFlags.TEAR_GLOW == TearFlags.TEAR_GLOW then
                local numAstroGodhead = player:GetCollectibleNum(Astro.Collectible.ASTRO_GODHEAD)
                entity:TakeDamage(tear.BaseDamage * (0.3 * numAstroGodhead), damageFlags, source, countdownFrames)
                return false
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_GODHEAD, player:HasCollectible(Astro.Collectible.ASTRO_GODHEAD) and 1 or 0, "ASTRO_ASTRO_GODHEAD")
    end
)

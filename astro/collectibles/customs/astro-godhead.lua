local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.ASTRO_GODHEAD = Isaac.GetItemIdByName("Astro Godhead")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ASTRO_GODHEAD,
                "우주신",
                "진정한 신의 눈물",
                "↑ {{DamageSmall}}공격력 +1" ..
                "#↓ {{TearsSmall}}연사 -0.3" ..
                "#↓ {{ShotspeedSmall}}탄속 -0.3" ..
                "#공격이 적에게 유도됩니다.." ..
                "#{{Collectible331}}눈물에 후광이 생기며 후광에 닿은 적은 프레임당 캐릭터의 공격력 30%의 피해를 받습니다." ..
                "#{{ArrowGrayRight}} 중첩 시 후광의 공격력이 합 연산으로 증가합니다."
            )
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

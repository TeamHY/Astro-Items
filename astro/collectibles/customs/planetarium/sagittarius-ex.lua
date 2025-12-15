---

-- 20% 추가 피해
local EXTRA_DAMAGE_MULTIPLIER = 0.2

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.SAGITTARIUS_EX = Isaac.GetItemIdByName("Sagittarius EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SAGITTARIUS_EX,
                "초 사수자리",
                "꿰뚫어라",
                "공격이 적을 관통하며;" ..
                "#{{ArrowGrayRight}} 관통한 공격은 적이 있는 방향을 향해 직선으로 유도됩니다." ..
                "#보스를 제외한 적이 피해를 입을 때 " .. string.format("%.f", EXTRA_DAMAGE_MULTIPLIER * 100) .. "%의 추가 피해를 주며;" ..
                "#{{ArrowGrayRight}} {{LuckSmall}}행운 1당 1%의 추가 피해를 줍니다." ..
                "#다음 게임에서{{Collectible48}}Cupid's Arrow를 들고 시작합니다.",
                -- 중첩 시
                "중첩 시 추가 피해량이 중첩된 수만큼 합 연산으로 증가"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.SAGITTARIUS_EX,
                "Sagittarius EX",
                "",
                "Piercing tears" ..
                "#Hitting an enemy makes the tear homing" ..
                "#Deals " .. string.format("%.f", EXTRA_DAMAGE_MULTIPLIER * 100) .. "% extra damage to non-boss enemies;" ..
                "#{{ArrowGrayRight}} +1%p per Luck." ..
                "#Grants{{Collectible48}} Cupid's Arrow at the start of the next run",
                -- Stacks
                "On stacking, extra damage increases per stack",
                "en_us"
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
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(Astro.Collectible.SAGITTARIUS_EX) then
            if (not entity:IsBoss()) and entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                entity:TakeDamage(amount * (EXTRA_DAMAGE_MULTIPLIER + player.Luck / 100) * player:GetCollectibleNum(Astro.Collectible.SAGITTARIUS_EX), 0, EntityRef(player), 0)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.SAGITTARIUS_EX) then
            if cacheFlag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and Astro.Data.RunSagittariusEx then
            local player = Isaac.GetPlayer()

            player:AddCollectible(CollectibleType.COLLECTIBLE_CUPIDS_ARROW)

            Astro.Data.RunSagittariusEx = false
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Astro.Data.RunSagittariusEx = true
    end,
    Astro.Collectible.SAGITTARIUS_EX
)

Astro:AddCallback(
    ModCallbacks.MC_POST_TEAR_INIT,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        
        if player and player:HasCollectible(Astro.Collectible.SAGITTARIUS_EX) then
            if tear.TearVariant == tear.BLUE then
                tear:ChangeVariant(TearVariant.CUPID_BLUE)
            elseif tear.TearVariant == TearVariant.BLOOD then
                tear:ChangeVariant(TearVariant.CUPID_BLOOD)
            end
        end
    end
)


------ 관통 시 직각 유도 추가 ------
Astro:AddCallback(
    ModCallbacks.MC_PRE_TEAR_COLLISION,
    ---@param tear EntityTear
    ---@param collider Entity
    ---@param low boolean
    function(_, tear, collider, low)
        local player = Astro:GetPlayerFromEntity(tear)

        if player and player:HasCollectible(Astro.Collectible.SAGITTARIUS_EX) then
            tear:AddTearFlags(TearFlags.TEAR_TURN_HORIZONTAL | TearFlags.TEAR_HOMING)
        end
    end
)
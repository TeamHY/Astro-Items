---

-- 20% 추가 피해
local extraDamageMultiplier = 0.2

---

local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.SAGITTARIUS_EX = Isaac.GetItemIdByName("Sagittarius EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.SAGITTARIUS_EX,
        "초 사수자리",
        "...",
        "공격이 적을 관통합니다.#보스를 제외한 적에게 기본 20% + {{LuckSmall}}행운 1당 1% 추가 피해를 입힙니다.#중첩 시 추가 피해가 합 연산으로 증가합니다.#다음 게임 시작 시 {{Collectible48}}Cupid's Arrow를 가지고 시작합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = AstroItems:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(AstroItems.Collectible.SAGITTARIUS_EX) then
            if (not entity:IsBoss()) and entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                entity:TakeDamage(amount * (extraDamageMultiplier + player.Luck / 100) * player:GetCollectibleNum(AstroItems.Collectible.SAGITTARIUS_EX), 0, EntityRef(player), 0)
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.SAGITTARIUS_EX) then
            if cacheFlag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.RunSagittariusEx then
            local player = Isaac.GetPlayer()

            player:AddCollectible(CollectibleType.COLLECTIBLE_CUPIDS_ARROW)

            AstroItems.Data.RunSagittariusEx = false
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        AstroItems.Data.RunSagittariusEx = true
    end,
    AstroItems.Collectible.SAGITTARIUS_EX
)

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.THREE_BODY_PROBLEM = Isaac.GetItemIdByName("3 Body Problem")

---

local SOUND_VOLUME = 0.7    -- 효과음 음량

local BOSS_EXTRA_DAMAGE = 0.25    -- 보스 데미지 감소

---

---@type CollectibleType[]
local activeItems = {}

---@type CollectibleType[]
local banItems = {}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        activeItems = {
            CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
            CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS,
            CollectibleType.COLLECTIBLE_ERASER,
            CollectibleType.COLLECTIBLE_DADS_KEY,
            CollectibleType.COLLECTIBLE_ANIMA_SOLA,
            CollectibleType.COLLECTIBLE_TELEKINESIS,
            CollectibleType.COLLECTIBLE_FORTUNE_COOKIE,
        }

        banItems = {
            CollectibleType.COLLECTIBLE_SPOON_BENDER,
        }

        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.THREE_BODY_PROBLEM,
                "삼체",
                "예측불허",
                "↑ {{ShotspeedSmall}}탄속 +0.6" ..
                "#{{Collectible329}} 공격이 공격키로 조종 가능한 원격 눈물 공격 3개로 변경됩니다." ..
                "#때때로 아래 효과 중 하나 발동:" ..
                "#{{IND}}↑ {{DamageSmall}}공격력 +2" ..
                "#{{IND}} 캐릭터가 10초간 무적 상태가 됩니다." ..
                "#{{IND}} 그 방의 닫혀있는 문을 모두 엽니다." ..
                "#{{IND}}{{Collectible638}} 공격방향으로 지우개를 발사합니다." ..
                "#{{IND}}{{Chained}} 가장 가까운 적을 5초간 움직이지 못하게 만듭니다." ..
                "#{{IND}} 3초간 캐릭터에게 날아오는 적의 탄환을 붙잡습니다." ..
                "#{{IND}}{{Collectible557}} 30% 확률로 랜덤 픽업을 1개 드랍합니다." ..
                "#보스가 받는 피해량이 감소합니다.",
                -- 중첩 시
                "중첩 시 보스 피해량 패널티 완화"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.THREE_BODY_PROBLEM,
                "3 Body Problem", "",
                "↑ {{Shotspeed}} +0.6 Shot speed" ..
                "#{{Collectible329}} Replaces Isaac's tears with 3 giant controllable tear" ..
                "#Sometimes one of the following item effects activates:" ..
                "#{{IND}}{{Collectible34}} Book of Belial" ..
                "#{{IND}}{{Collectible58}} Book of Shadows" ..
                "#{{IND}}{{Collectible175}} Dad's Key" ..
                "#{{IND}}{{Collectible522}} Telekinesis" ..
                "#{{IND}}{{Collectible557}} Fortune Cookie" ..
                "#{{IND}}{{Collectible638}} Eraser" ..
                "#{{IND}}{{Collectible722}} Anima Sola" ..
                "#Reduces the damage the boss takes",
                -- Stacks
                "Stacks reduce the boss damage penalty",
                "en_us"
            )
        end
    end
)

---@param player EntityPlayer
local function RunEffect(player)
    local rng = player:GetCollectibleRNG(Astro.Collectible.THREE_BODY_PROBLEM)
    local item = activeItems[rng:RandomInt(#activeItems) + 1]

    player:AnimateCollectible(Astro.Collectible.THREE_BODY_PROBLEM, "HideItem")
    player:UseActiveItem(item, false)
    SFXManager():Play(SoundEffect.SOUND_DIVINE_INTERVENTION, SOUND_VOLUME)
end

local isFirstKill = true

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        isFirstKill = true

        if not Game():GetRoom():IsClear() then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) then
                    RunEffect(player)
                    break
                end
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

            if player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) and isFirstKill and entityNPC.Type ~= EntityType.ENTITY_FIREPLACE then
                RunEffect(player)
                isFirstKill = false
                break
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

            if player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) then
                RunEffect(player)
                break
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
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) then
            if entity:IsBoss() and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                entity:TakeDamage(amount * BOSS_EXTRA_DAMAGE * player:GetCollectibleNum(Astro.Collectible.THREE_BODY_PROBLEM), 0, EntityRef(player), 0)
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.THREE_BODY_PROBLEM) then
            for _, item in ipairs(banItems) do
                Astro:RemoveAllCollectible(player, item)
            end
        end
    end,
    Astro.Collectible.THREE_BODY_PROBLEM
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE, player:HasCollectible(Astro.Collectible.THREE_BODY_PROBLEM) and 3 or 0, "ASTRO_THREE_BODY_PROBLEM")
    end
)

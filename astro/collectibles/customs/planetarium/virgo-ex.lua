local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.VIRGO_EX = Isaac.GetItemIdByName("Virgo EX")

---

local INVINCIBLE_COOLDOWN = 60 * 30
local DAMAGE_UP_INCREMENT = 0.6

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.VIRGO_EX,
                "초 처녀자리",
                "하늘을 우러러 한 점 부끄럼 없이",
                "#{{Collectible654}} 능력치 감소 알약 사용 시 {{DamageSmall}}공격력이 +0.6 증가하며;" ..
                "#{{ArrowGrayRight}} 비 능력치 관련 부정 알약 사용 시 블랙하트를 1개 드랍합니다." ..
                "#패널티 피격 시 피해를 무시하고 10초 동안 무적이 됩니다." ..
                "#{{TimerSmall}} (쿨타임 60초)",
                -- 중첩 시
                "중첩 시 공격력, 블랙하트 소환 개수, 무적 시간이 합연산으로 증가"
            )
        end
    end
)


------ 기존 초 양자리 ------
Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.VIRGO_EX) then
            local data = player:GetData()
            if data._ASTRO_VirgoEX == nil then
                data._ASTRO_VirgoEX = {
                    CooldownTime = 0
                }
            end

            local frameCount = Game():GetFrameCount()
            if data._ASTRO_VirgoEX.CooldownTime <= frameCount then
                data._ASTRO_VirgoEX.CooldownTime = frameCount + INVINCIBLE_COOLDOWN

                for _ = 1, player:GetCollectibleNum(Astro.Collectible.VIRGO_EX) do
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)
                end

                return false
            end
        end
    end
)


------ 위조 박사학위  ------
local damageUpPillEffects = {
    PillEffect.PILLEFFECT_HEALTH_DOWN,   -- 6
    PillEffect.PILLEFFECT_RANGE_DOWN,   -- 11
    PillEffect.PILLEFFECT_SPEED_DOWN,   -- 13
    PillEffect.PILLEFFECT_TEARS_DOWN,   -- 15
    PillEffect.PILLEFFECT_LUCK_DOWN,   -- 17
    PillEffect.PILLEFFECT_SHOT_SPEED_DOWN,   -- 47
    PillEffect.PILLEFFECT_EXPERIMENTAL,   -- 49
}

local blackHeartPillEffects = {
    PillEffect.PILLEFFECT_PARALYSIS,   -- 22
    PillEffect.PILLEFFECT_AMNESIA,   -- 25
    PillEffect.PILLEFFECT_WIZARD,   -- 27
    PillEffect.PILLEFFECT_ADDICTED,   -- 29
    PillEffect.PILLEFFECT_QUESTIONMARK,   -- 31
    PillEffect.PILLEFFECT_RETRO_VISION,   -- 37
    PillEffect.PILLEFFECT_IM_EXCITED,   -- 42
}

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            Astro.Data.VirgoEXFalsePHD = {
                Damage = 0,
            }
        else
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(Astro.Collectible.VIRGO_EX) then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_PILL,
    ---@param pillEffect PillEffect
    ---@param player EntityPlayer
    ---@param flag UseFlags
    function(_, pillEffect, player, flag)
        if player:HasCollectible(Astro.Collectible.VIRGO_EX) then
            for i = 1, player:GetCollectibleNum(Astro.Collectible.VIRGO_EX) do
                for j, damageUpPillEffect in ipairs(damageUpPillEffects) do
                    if pillEffect == damageUpPillEffect then
                        Astro.Data.VirgoEXFalsePHD.Damage = Astro.Data.VirgoEXFalsePHD.Damage + DAMAGE_UP_INCREMENT
                        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                        player:EvaluateItems()
                    end
                end

                for k, blackHeartPillEffect in ipairs(blackHeartPillEffects) do
                    if pillEffect == blackHeartPillEffect then
                        Astro:Spawn(5, 10, 6, player.Position)
                    end
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.VIRGO_EX) and Astro.Data.VirgoEXFalsePHD ~= nil then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + Astro.Data.VirgoEXFalsePHD.Damage
            end
        end
    end
)

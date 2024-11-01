---

local SPAWN_CHANCE = 0.1

local LUCK_MULTIPLY = 1 / 100

local COOLDOWN_TIME = 75 -- 30 프레임 = 1초

---

Astro.Collectible.ABORTION = Isaac.GetItemIdByName("Abortion")

local function Init()
    if EID then
        Astro:AddEIDCollectible(
            Astro.Collectible.ABORTION,
            "낙태",
            "...",
            "공격 시 10%의 확률로 특수한 눈물을 발사합니다. 해당 눈물은 적 명중 시 {{Collectible678}}C Section의 눈물로 변화합니다." ..
            "#중첩 시 최종 확률이 합 연산으로 증가하고 쿨타임이 줄어듭니다." ..
            "#!!! {{LuckSmall}}행운 수치 비례: 행운 90 이상일 때 100% 확률 (행운 1당 +1%p)"
        )
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        local tearData = tear:GetData()

        if player ~= nil and player:HasCollectible(Astro.Collectible.ABORTION) and not player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
            local data = player:GetData()

            if (data["abortionCooldown"] == nil or data["abortionCooldown"] < Game():GetFrameCount()) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.ABORTION)
                local collectibleNum = player:GetCollectibleNum(Astro.Collectible.ABORTION)

                if rng:RandomFloat() < (SPAWN_CHANCE + player.Luck * LUCK_MULTIPLY) * collectibleNum then
                    tearData.Abortion = {}
                    tear.Color = Color(1, 0.1, 0.2, 1, 0, 0, 0)
                    
                    data["abortionCooldown"] = Game():GetFrameCount() + COOLDOWN_TIME / collectibleNum
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_TEAR_COLLISION,
    ---@param tear EntityTear
    ---@param collider Entity
    ---@param low boolean
    function(_, tear, collider, low)
        if tear:GetData().Abortion ~= nil then
            tear:AddTearFlags(TearFlags.TEAR_FETUS | TearFlags.TEAR_SPECTRAL)
            tear:ChangeVariant(TearVariant.FETUS)

            tear:GetData().Abortion = nil
        end
    end
)

return {
    Init = Init
}

---

local EXTRA_DAMAGE_MULTIPLIER = 0.3

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.DENEB = Isaac.GetItemIdByName("Deneb")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.DENEB,
                "데네브",
                "가장 밝게 빛나는",
                "다음 게임에서 애프터버스 변종 스테이지(Burning Basement, Flooded Caves, Dank Depths, Scarred Womb) 등장하지 않습니다." ..
                "#변종 몬스터 직접 공격 시 30%의 추가 피해를 입힙니다.",
                -- 중첩 시
                "추가 피해가 중첩된 수만큼 합 연산으로 증가"
            )
        end
    end
)

local function TryChangeStage()
    if Astro.Data.BanAfterbirthStage then
        local level = Game():GetLevel()
        local stage = level:GetStage()
        local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.DENEB)

        if level:GetStageType() == StageType.STAGETYPE_AFTERBIRTH and stage <= LevelStage.STAGE4_2 then
            Isaac.ExecuteCommand("stage " .. stage .. (rng:RandomFloat() < 0.5 and "" or "a"))
            print("Deneb Effect: Ban Afterbirth Stage")
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            if Astro.Data.RunDeneb then
                Astro.Data.BanAfterbirthStage = true
                TryChangeStage()
            else
                Astro.Data.BanAfterbirthStage = false
            end

            Astro.Data.RunDeneb = false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Game():GetFrameCount() > 1 then
            TryChangeStage()
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Astro.Data.RunDeneb = true
    end,
    Astro.Collectible.DENEB
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
        local npc = entity:ToNPC()

        if player ~= nil and npc ~= nil and player:HasCollectible(Astro.Collectible.DENEB) then
            if npc:IsChampion() and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                npc:TakeDamage(amount * EXTRA_DAMAGE_MULTIPLIER * player:GetCollectibleNum(Astro.Collectible.DENEB), 0, EntityRef(player), 0)
            end
        end
    end
)

Astro.Collectible.LIMBO = Isaac.GetItemIdByName("Limbo")

---

local RIFT_SIZE_MULTI = 1.25    -- 균열의 크기. (기본값 1.25, 1.25로 설정 시 기존 크기의 1.25배 = 40 * 1.25)

local SPAWN_AMOUNT = 4    -- 소환하려는 유령 수

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.LIMBO,
                "변옥",
                "그 고난의 연기가 세세토록 올라가리로다",
                "방 안에 랜덤 위치에 푸른 균열이 생성됩니다." ..
                "#균열에 닿을 시 " .. SPAWN_AMOUNT .. "마리의 유령이 나와 적에게 돌진해 공격력 x2의 피해를 줍니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        local level = Game():GetLevel()
        local room = level:GetCurrentRoom()

        if not room:IsClear() and Astro:HasCollectible(Astro.Collectible.LIMBO) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 0, room:GetRandomPosition(30), Vector.Zero, nil)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    ---@param effect EntityEffect
    function(_, effect)
        if Astro:HasCollectible(Astro.Collectible.LIMBO) then
            local newColor = effect.Color
            newColor:SetColorize(1, 1, 1, 2)
            effect.Color = newColor
            effect.Size = 40 * RIFT_SIZE_MULTI
            effect.SpriteScale = Vector(RIFT_SIZE_MULTI, RIFT_SIZE_MULTI)
        end
    end,
    EffectVariant.PURGATORY
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        if effect.SubType == 0 and Astro:HasCollectible(Astro.Collectible.LIMBO) then
            local sprite = effect:GetSprite()

            if sprite:IsEventTriggered("Shoot") then
                for i = 1, SPAWN_AMOUNT do
                    local ghost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, effect.Position, Vector.Zero, nil)
                    local newColor = effect.Color
                    
                    newColor:SetColorize(1, 1, 1, i + 1)
                    ghost.Color = newColor
                    ghost.Size = 40 * RIFT_SIZE_MULTI
                    ghost.SpriteScale = Vector(RIFT_SIZE_MULTI - (i * 0.125), RIFT_SIZE_MULTI - (i * 0.125))
                end
            end
        end
    end,
    EffectVariant.PURGATORY
)
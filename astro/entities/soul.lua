local soulItems = {}

-- 소울류 아이템을 추가합니다. 등록된 아이템을 소지 중일 경우, 몬스터 처치 시 소울이 생성됩니다.
---@param collectable any
function Astro:AddSoulItem(collectable)
    table.insert(soulItems, collectable)
end

-- TODO: 소울 하나로 통합하기
Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for _, item in ipairs(soulItems) do
                if player:HasCollectible(item) then
                    local soul =
                        Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        EffectVariant.ENEMY_SOUL,
                        0,
                        npc.Position,
                        Vector.Zero,
                        player
                    )

                    local data = soul:GetData()
                    data["astroSoulPlayer"] = player

                    -- local rng = player:GetCollectibleRNG(Astro.Collectible.DUNNELL_THE_NOBLE_ARMS_OF_LIGHT)
                    -- soul:AddVelocity(Vector.FromAngle(rng:RandomInt(360)):Resized(200))

                    break
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        if effect.Variant == EffectVariant.ENEMY_SOUL then
            local data = effect:GetData()

            if data["astroSoulPlayer"] then
                local player = data["astroSoulPlayer"]

                effect:AddVelocity((player.Position - effect.Position):Resized(20))

                if effect.Position:Distance(player.Position) < 10 then
                    Isaac.RunCallback(Astro.Callbacks.SOUL_COLLECTED, player)
                    effect:Remove()
                end
            end
        end
    end
)

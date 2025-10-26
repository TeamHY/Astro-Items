---

local COIN_COST = 30

---

Astro.Collectible.PILLARS_OF_CREATION = Isaac.GetItemIdByName("Pillars of Creation")

local PILLARS_OF_CREATION_VARIANT = Isaac.GetEntityVariantByName("Pillars of Creation")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.PILLARS_OF_CREATION,
                "창조의 기둥",
                "가슴 시리도록 아름다워",
                "{{Planetarium}} 스테이지 첫 방에 천체관으로 갈 수 있는 기둥이 생성됩니다." ..
                "#{{ArrowGrayRight}} 입장엔 {{Coin}}" .. COIN_COST .. "개의 동전이 필요합니다." ..
                "#!!! 기둥은 방을 벗어나면 사라집니다.",
                -- 중첩 시
                "중첩 시 방을 벗어나도 기둥이 사라지지 않음"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.PILLARS_OF_CREATION) then
            local level = Game():GetLevel()
            local room = level:GetCurrentRoom()
            local data = Astro.SaveManager.GetFloorSave(Isaac.GetPlayer())

            if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then
                if room:IsFirstVisit() then
                    data["runPillarsOfCreation"] = false
                end

                if not data["runPillarsOfCreation"] and (room:IsFirstVisit() or Astro:GetCollectibleNum(Astro.Collectible.PILLARS_OF_CREATION) > 1) then
                    Astro:Spawn(EntityType.ENTITY_EFFECT, PILLARS_OF_CREATION_VARIANT, 0, room:GetGridPosition(109))
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    function(_, effect)
        local players = Isaac.FindInRadius(effect.Position, 20, EntityPartition.PLAYER)

        if #players > 0 then
            local player = Isaac.GetPlayer()
            local data = Astro.SaveManager.GetFloorSave(player)

            if data["lockedToPillar"] then
                local toCenter = effect.Position - player.Position
                local dist = toCenter:Length()
                if dist > 0.5 then
                    player.Velocity = toCenter * 0.25
                else
                    player.Velocity = Vector(0,0)
                    player.Position = effect.Position
                end
                player.ControlsEnabled = false

                goto continue
            end

            if player:GetNumCoins() >= COIN_COST and not data["runPillarsOfCreation"] then
                player:AddCoins(-COIN_COST)
                player:AnimateLightTravel()
                player.Velocity = (effect.Position - player.Position) * 0.12
                player.ControlsEnabled = false

                effect:GetSprite():Play("teleport", true)
                SFXManager():Play(Isaac.GetSoundIdByName("PillarTeleport"))
                data["runPillarsOfCreation"] = true
                data["lockedToPillar"] = true
                
                Astro:ScheduleForUpdate(function()
                    player.ControlsEnabled = true
                    Isaac.ExecuteCommand("goto s.planetarium")
                end, 32)
            elseif player:GetNumCoins() < COIN_COST and not data["runPillarsOfCreation"] then
                local dirVec = player.Position - effect.Position
                dirVec = dirVec:Normalized()
                player:AddVelocity(dirVec * 1.5)
            end

            ::continue::
        end
    end,
    PILLARS_OF_CREATION_VARIANT
)
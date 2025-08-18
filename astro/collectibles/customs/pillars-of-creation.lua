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
                "...",
                "{{Planetarium}} 스테이지 첫 방에 천체관으로 갈 수 있는 사다리가 생성됩니다." ..
                "#{{ArrowGrayRight}} 입장엔 {{Coin}}" .. COIN_COST .. "개의 동전이 필요합니다." ..
                "#!!! 기둥은 방을 벗어나면 사라집니다. (중첩 시 사라지지 않음)"
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

            if player:GetNumCoins() >= COIN_COST and not data["runPillarsOfCreation"] then
                player:AddCoins(-COIN_COST)
                effect:GetSprite():Play("teleport", true)
                SFXManager():Play(Isaac.GetSoundIdByName("PillarTeleport"))
                data["runPillarsOfCreation"] = true
                
                Astro:ScheduleForUpdate(function()
                    Isaac.ExecuteCommand("goto s.planetarium")
                end, 32)
            end
        end
    end,
    PILLARS_OF_CREATION_VARIANT
)

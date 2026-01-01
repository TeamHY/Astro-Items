Astro.Collectible.BIRTHRIGHT_APOLLYON_B = Isaac.GetItemIdByName("Apollyon's Frame")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_APOLLYON_B,
                "아폴리온의 액자",
                "재앙의 동료",
                "{{Collectible706}} 클리어하지 않은 방에 입장 시 심연의 파리 3마리를 소환합니다.",
                -- 중첩 시
                "중첩된 수만큼 소환 시도"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local game = Game()

        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_APOLLYON_B) then
                local num = player:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_APOLLYON_B)
                local list = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST)

                if game:GetRoom():IsClear() then
                    for _, ent in ipairs(list) do
                        local eData = ent:GetData()

                        if eData.ASTRO_byApollyonsFrame then
                            ent:Remove()
                        end
                    end
                elseif num >= 1 then
                    for _, ent in ipairs(list) do
                        local eData = ent:GetData()

                        if eData.ASTRO_byApollyonsFrame then
                            ent:Remove()
                        end
                    end

                    for _ = 1, num do
                        for j = 1, 3 do
                            local locust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST, 0, player.Position, Vector(0,0), player)
                            local lData = locust:GetData()
                            
                            lData.ASTRO_byApollyonsFrame = true
                        end
                    end
                end
            end
        end
    end
)

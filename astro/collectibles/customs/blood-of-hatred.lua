local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BLOOD_OF_HATRED = Isaac.GetItemIdByName("Blood Of Hatred")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.BLOOD_OF_HATRED,
                "증오의 피",
                "피 한 방울에 서린 복수심",
                "!!! 최초 획득 시 2개 획득" ..
                "#↑ {{BlackHeart}}블랙하트 +1" ..
                "#{{BleedingOut}} 방 입장 시 12.5% 확률로 적을 출혈시킵니다." ..
                "#{{LuckSmall}} 행운 30 이상일 때 100% 확률 (행운 1당 +2.5%p)",
                -- 중첩 시
                "중첩 시 출혈 확률이 중첩된 수만큼 합연산으로 증가"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.BLOOD_OF_HATRED) then
                local entities = Isaac.GetRoomEntities()

                for _, entity in ipairs(entities) do
                    if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
                        local rng = player:GetCollectibleRNG(Astro.Collectible.BLOOD_OF_HATRED)

                        if rng:RandomFloat() < (0.125 * player:GetCollectibleNum(Astro.Collectible.BLOOD_OF_HATRED)) + player.Luck / 40 then
                            entity:GetData().BloodOfHatred = {
                                DurationTime = entity.FrameCount + 150 -- 5초
                            }
    
                            entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
                        end
                    end
                end

                -- 여러 플레이어가 가지고 있으면 각각 발동한다
            end
        end
    end
)

-- TODO: Aquarius EX와 로직 통합하기
Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function()
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            local data = entity:GetData().BloodOfHatred

            if data ~= nil and data.DurationTime <= entity.FrameCount then
                entity:ClearEntityFlags(EntityFlag.FLAG_BLEED_OUT)
                entity:GetData().BloodOfHatred = nil
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.BLOOD_OF_HATRED) then
            player:AddCollectible(Astro.Collectible.BLOOD_OF_HATRED)
        end
    end,
    Astro.Collectible.BLOOD_OF_HATRED
)

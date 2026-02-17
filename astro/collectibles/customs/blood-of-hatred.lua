local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BLOOD_OF_HATRED = Isaac.GetItemIdByName("Blood Of Hatred")

---

local BLEEDING_CHANCE = 0.125

local LUCK_MULTIPLY = 1 / 40

---

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
                "#{{BleedingOut}} 방 입장 시 " .. string.format("%.1f", BLEEDING_CHANCE * 100) .. "% 확률로 적을 출혈시킵니다." ..
                "#{{LuckSmall}} 행운 30 이상일 때 100% 확률 (행운 1당 +2.5%p)",
                -- 중첩 시
                "중첩 시 출혈 확률이 중첩된 수만큼 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.BLOOD_OF_HATRED,
                "Blood Of Hatred",
                "Random bleeding",
                "!!! +2 on first pickup" ..
                "#↑ {{BlackHeart}} +1 Black Heart" ..
                "#12.5% chance to bleed enemies on room entry (+2.5%p per Luck)",
                -- Stacks
                "Stacks increase chance",
                "en_us"
            )
            
            Astro.EID.LuckFormulas["5.100." .. tostring(Astro.Collectible.BLOOD_OF_HATRED)] = function(luck, num)
                return (BLEEDING_CHANCE * num + luck * LUCK_MULTIPLY) * 100
            end
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

                        if rng:RandomFloat() < (BLEEDING_CHANCE * player:GetCollectibleNum(Astro.Collectible.BLOOD_OF_HATRED)) + player.Luck * LUCK_MULTIPLY then
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

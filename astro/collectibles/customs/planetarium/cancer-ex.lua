local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.CANCER_EX = Isaac.GetItemIdByName("Cancer EX")

---

local SOUND_VOLUME = 1

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.CANCER_EX,
                "초 게자리",
                "순수함에 보호받다",
                "↑ {{SoulHeart}}소울하트 +3" ..
                "#{{Collectible301}} 피격 시 이후 그 방에서 받는 피해를 절반으로 줄여줍니다. (최소 반칸)" ..
                "#{{Card57}} 2분마다 1분간 적과 탄환이 캐릭터에게 가까이 가지 못하게 합니다." ..
                "#다음 게임에서 {{Card57}}I - The Magician?을 소환합니다.",
                -- 중첩 시
                "중첩 시 발동 쿨타임 감소"
            )
            
            Astro:AddEIDCollectible(
                Astro.Collectible.CANCER_EX,
                "Cancer EX",
                "",
                "{{SoulHeart}} +3 Soul Hearts" ..
                "#{{Collectible301}} Taking damage reduces all future damage in the room to half a heart" ..
                "#{{Card57}} Grants an aura that repels enemies and projectiles for 60 seconds every 2 minutes" ..
                "#Spawns {{Card57}} I - The Magician? in the next run",
                -- Stacks
                "Stacks reduce {{Card57}}'s cooldown",
                "en_us"
            )
        end
    end
)


------ 기존 초 물고기자리 ------
Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.CANCER_EX) then
            if Game():GetFrameCount() % math.floor(3600 / player:GetCollectibleNum(Astro.Collectible.CANCER_EX)) == 0 then
                player:UseCard(Card.CARD_REVERSE_MAGICIAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                SFXManager():Play(Astro.SoundEffect.CANCER_EX, SOUND_VOLUME)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and Astro.Data.CancerEXCount ~= nil and Astro.Data.CancerEXCount > 0 then
            local player = Isaac.GetPlayer()
            local currentRoom = Game():GetLevel():GetCurrentRoom()

            for _ = 1, Astro.Data.CancerEXCount do
                Isaac.Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TAROTCARD,
                    Card.CARD_REVERSE_MAGICIAN,
                    currentRoom:FindFreePickupSpawnPosition(player.Position, 40, true),
                    Vector.Zero,
                    nil
                )
            end

            Astro.Data.CancerEXCount = 0
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Astro.Data.CancerEXCount = player:GetCollectibleNum(Astro.Collectible.CANCER_EX)
    end,
    Astro.Collectible.CANCER_EX
)


------ 히든 아이템 ------
Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_CANCER)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_CANCER) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_CANCER)
        end
    end,
    Astro.Collectible.CANCER_EX
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_CANCER) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_CANCER)
        end
    end,
    Astro.Collectible.CANCER_EX
)
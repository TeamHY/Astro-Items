---

local SOUND_VOLUME = 1

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.PISCES_EX = Isaac.GetItemIdByName("Pisces EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.PISCES_EX,
                "초 물고기자리",
                "밀어내기",
                "{{Card57}} 2분마다 1분간 적과 탄환이 캐릭터에게 가까이 가지 못합니다." ..
                "#다음 게임에서 {{Card57}}I - The Magician?을 소환합니다.",
                -- 중첩 시
                "발동 쿨타임 감소"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.PISCES_EX) then
            if Game():GetFrameCount() % math.floor(3600 / player:GetCollectibleNum(Astro.Collectible.PISCES_EX)) == 0 then
                player:UseCard(Card.CARD_REVERSE_MAGICIAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                SFXManager():Play(Astro.SoundEffect.PISCES_EX, SOUND_VOLUME)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and Astro.Data.PiscesEXCount ~= nil and Astro.Data.PiscesEXCount > 0 then
            local player = Isaac.GetPlayer()
            local currentRoom = Game():GetLevel():GetCurrentRoom()

            for _ = 1, Astro.Data.PiscesEXCount do
                Isaac.Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TAROTCARD,
                    Card.CARD_REVERSE_MAGICIAN,
                    currentRoom:FindFreePickupSpawnPosition(player.Position, 40, true),
                    Vector.Zero,
                    nil
                )
            end

            Astro.Data.PiscesEXCount = 0
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Astro.Data.PiscesEXCount = player:GetCollectibleNum(Astro.Collectible.PISCES_EX)
    end,
    Astro.Collectible.PISCES_EX
)

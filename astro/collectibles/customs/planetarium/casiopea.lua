local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.CASIOPEA = Isaac.GetItemIdByName("Casiopea")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.CASIOPEA,
                "카시오페아",
                "자만과 허영",
                "#랜덤 황금 장신구와 {{Pill1}}Gulp!를 드랍합니다." ..
                "#{{Collectible654}} False PHD 소지 시 {{Pill1}}Gulp!를 드랍하는 대신 {{Pill1}}Gulp! {{ColorCyan}}말{{CR}}약을 즉시 사용합니다." ..
                "#다음 게임에서 랜덤 황금 장신구를 하나 소환합니다.",
                -- 중첩 시
                "중첩 시 다음 게임에서 소환되는 랜덤 황금 장신구 수 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.CASIOPEA,
                "Casiopea", "",
                "#Spawns a random golden trinket and {{Pill1}} Gulp" ..
                "#{{Collectible654}} With False PHD, instantly uses a {{Pill1}} Gulp! horse pill instead of dropping Gulp" ..
                "#Spawns 1 random golden trinket in the next run",
                -- Stacks
                "Stacks increases the number of golden trinkets spawned in the next run",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and Astro.Data.CasiopeaCount ~= nil and Astro.Data.CasiopeaCount > 0 then
            local itemPool = Game():GetItemPool()

            for _ = 1, Astro.Data.CasiopeaCount do
                Astro:SpawnTrinket(itemPool:GetTrinket() + 32768, Game():GetRoom():GetCenterPos())
            end

            Astro.Data.CasiopeaCount = 0
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.CASIOPEA) then
            local game = Game()
            local itemPool = game:GetItemPool()

            if player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD) then
                local pillColor = itemPool:ForceAddPillEffect(PillEffect.PILLEFFECT_GULP)
                player:UsePill(PillEffect.PILLEFFECT_GULP, pillColor | PillColor.PILL_GIANT_FLAG)
            else
                Astro:SpawnPill(PillEffect.PILLEFFECT_GULP, player.Position)
            end
            Astro:SpawnTrinket(itemPool:GetTrinket() + 32768, player.Position)
        end

        Astro.Data.CasiopeaCount = player:GetCollectibleNum(Astro.Collectible.CASIOPEA)
    end,
    Astro.Collectible.CASIOPEA
)

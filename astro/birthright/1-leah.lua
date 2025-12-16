---

local SPAWN_AMOUNT = 7

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDBirthright(
                Astro.Players.LEAH,
                "게임이 끝나기 전까지 죽지 않는 꼬마 아이작 패밀리어 " .. SPAWN_AMOUNT .. "마리를 소환합니다." ..
                "#{{Collectible658}} 꼬마 아이작은 캐릭터와 함께 이동하며 적이 있는 방향으로 공격력 1.35의 눈물을 발사합니다.",
                "뜻밖의 결혼",
                "ko_kr"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = Astro:GetPersistentPlayerData(player)

            pData["spawnedByLeahBirhtight"] = pData["spawnedByLeahBirhtight"] or {}
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:GetPlayerType() == Astro.Players.LEAH and Astro:IsFirstAdded(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            for i = 1, SPAWN_AMOUNT do
                local minisaac = player:AddMinisaac(player.Position)
                minisaac:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)

                local pData = Astro:GetPersistentPlayerData(player)
                pData["spawnedByLeahBirhtight"][tostring(minisaac.InitSeed)] = true
            end
        end
    end,
    CollectibleType.COLLECTIBLE_BIRTHRIGHT
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.MINISAAC then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
                local pData = Astro:GetPersistentPlayerData(player)

                if Astro.isFight and (Astro:IsLatterStage() or pData["LeahBirthrightPenalty"]) then
                    return true
                elseif pData["spawnedByLeahBirhtight"][tostring(entity.InitSeed)] then
                    return false
                end
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        if player:GetPlayerType() ~= Astro.Players.LEAH then return end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            local pData = Astro:GetPersistentPlayerData(player)
            pData["LeahBirthrightPenalty"] = true
        end
    end
)
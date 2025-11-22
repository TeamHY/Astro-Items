--[[
아이디어 구현본 겸 생득권 효과 구현 기반 다지기

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDBirthright(
                Astro.Players.LEAH,
                "게임이 끝나기 전까지 죽지 않는 꼬마 아이작 패밀리어 7마리를 소환합니다." ..
                "#{{Collectible658}} 꼬마 아이작은 캐릭터와 함께 이동하며 적이 있는 방향으로 공격력 1.35의 눈물을 발사합니다.",
                "뜻밖의 결혼",
                "ko_kr"
            )
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:GetPlayerType() == Astro.Players.LEAH and Astro:IsFirstAdded(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            for i = 1, 7 do
                local minisaac = player:AddMinisaac(player.Position)
                if minisaac then
                    local d = minisaac:GetData()
                    d.Astro_isLeahBirthright = true

                    minisaac:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
                end
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
            local entityData = entity:GetData()
            if entityData and entityData.Astro_isLeahBirthright then
                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)
                    local playerData = Astro:GetPersistentPlayerData(player)

                    if Astro.isFight and (Astro:IsLatterStage() or playerData["ASTRO_LeahBirthrightPenalty"]) then
                        return true
                    end
                end
                return false
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
            local playerData = Astro:GetPersistentPlayerData(player)
            playerData["ASTRO_LeahBirthrightPenalty"] = true
        end
    end
)]]
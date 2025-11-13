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
        if player:GetPlayerType() == Astro.Players.LEAH and collectibleType == CollectibleType.COLLECTIBLE_BIRTHRIGHT then
            for i = 1, 7 do
                local minisaac = player:AddMinisaac(player.Position)
                if minisaac then
                    local d = minisaac:GetData()
                    d.Astro_isInvulMinisaac = true

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
            local d = entity:GetData()
            if d and d.Astro_isInvulMinisaac then
                if Astro.isFight and Astro:IsLatterStage() then
                    return true
                end
                return false
            end
        end
    end
)
]]
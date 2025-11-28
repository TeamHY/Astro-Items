Astro.Collectible.BIRTHRIGHT_BLUE_BABY = Isaac.GetItemIdByName("???'s Frame")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_BLUE_BABY,
                "???의 액자",
                "더 강한 영혼",
                "↑ {{SoulHeart}}소울하트 +2" ..
                "#{{SoulHeart}} 소울하트 획득량이 증가합니다." ..
                "#!!! 획득량: 기본 획득량 * ({{Collectible" .. Astro.Collectible.BIRTHRIGHT_BLUE_BABY .. "}}개수 + 1)"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local data = player:GetData()
        
        if (data.prevSoulHearts == nil) then
            data.prevSoulHearts = -1
        end
        
        if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_BLUE_BABY) then
            local currentSoulHearts = player:GetSoulHearts()

            if currentSoulHearts > data.prevSoulHearts then
                if data.prevSoulHearts ~= -1 then
                    local additionalSoulHearts = currentSoulHearts - data.prevSoulHearts
                    player:AddSoulHearts(additionalSoulHearts * player:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_BLUE_BABY))
                end
            end
        end

        data.prevSoulHearts = player:GetSoulHearts()
    end
)

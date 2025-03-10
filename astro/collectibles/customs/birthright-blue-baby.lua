Astro.Collectible.BIRTHRIGHT_BLUE_BABY = Isaac.GetItemIdByName("Birthright - Blue Baby")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_BLUE_BABY,
                "생득권 - 블루베이비",
                "...",
                "소울하트를 획득 시 소울하트 1개가 더 늘어납니다."
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
                    player:AddSoulHearts(additionalSoulHearts)
                end
            end
        end

        data.prevSoulHearts = player:GetSoulHearts()
    end
)

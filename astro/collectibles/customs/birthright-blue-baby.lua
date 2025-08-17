Astro.Collectible.BIRTHRIGHT_BLUE_BABY = Isaac.GetItemIdByName("Birthright - Blue Baby")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_BLUE_BABY,
                "???의 생득권",
                "더 강한 영혼",
                "{{SoulHeart}}소울하트 +1"..
                "#소울하트 획득량이 2배가 됩니다."..
                "#중첩이 가능합니다."
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

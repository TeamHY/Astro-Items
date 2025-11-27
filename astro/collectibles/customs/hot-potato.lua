---

local EXPLOSION_INTERVAL = 120

local EXPLOSION_DAMAGE = 185

---

Astro.Collectible.HOT_POTATO = Isaac.GetItemIdByName("Hot Potato")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.HOT_POTATO,
                "뜨거운 감자",
                "화젯거리",
                "↑ {{Bomb}}폭탄 +2" ..
                "#{{Collectible40}} 클리어하지 않은 방에서 " .. string.format("%.f", EXPLOSION_INTERVAL / 30) .. "초마다 캐릭터의 위치에 공격력 " .. EXPLOSION_DAMAGE .. "의 폭발을 일으킵니다." ..
                "#{{Blank}} {{ColorGray}}(자해 없음){{CR}}",
                -- 중첩 시
                "중첩한 수만큼 폭발을 일으킴"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.HOT_POTATO,
                "Hot Potato",
                "",
                "↑ {{Bomb}} +2 Bombs" ..
                "#{{Collectible40}} Explodes at character position, dealing " .. EXPLOSION_DAMAGE .. " damage every " .. string.format("%.f", EXPLOSION_INTERVAL / 30) .. " seconds in an uncleared room" ..
                "#{{Blank}} {{ColorGray}}(Immune to explosion damage){{CR}}",
                -- Stacks
                "Causes an explosion equal to the number of stacks",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.HOT_POTATO) then
            return
        end

        local data = Astro:GetPersistentPlayerData(player)
        local room = Game():GetRoom()

        data.hotPotatoCounter = (data.hotPotatoCounter or 0) + 1

        if data.hotPotatoCounter >= EXPLOSION_INTERVAL and not room:IsClear() then
            local num = player:GetCollectibleNum(Astro.Collectible.HOT_POTATO)
            Game():BombExplosionEffects(player.Position, EXPLOSION_DAMAGE * num, player:GetBombFlags(), nil, player)

            data.hotPotatoCounter = 0
        end
    end
)


------ 알가튼 스킨 ------
Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.HOT_POTATO) then
            local ic = Isaac.GetItemConfig()
            local hotPotatoCfg = ic:GetCollectible(Astro.Collectible.HOT_POTATO)
            local forgottenCfg = ic:GetNullItem(NullItemID.ID_FORGOTTEN_BOMB)
            
            local pType = player:GetPlayerType()
            if pType == (PlayerType.PLAYER_THEFORGOTTEN_B or PlayerType.PLAYER_THESOUL_B) then
                player:RemoveCostume(hotPotatoCfg)
                player:AddCostume(forgottenCfg)

                local data = Astro:GetPersistentPlayerData(player)
                data.hotPotatoCostume = true
            end
        end
    end,
    Astro.Collectible.HOT_POTATO
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local pType = player:GetPlayerType()
        if pType ~= PlayerType.PLAYER_THEFORGOTTEN_B then return end

        if not player:HasCollectible(Astro.Collectible.HOT_POTATO) then
            local data = Astro:GetPersistentPlayerData(player)

            if data.hotPotatoCostume then
                local ic = Isaac.GetItemConfig()
                local forgottenCfg = ic:GetNullItem(NullItemID.ID_FORGOTTEN_BOMB)
                player:RemoveCostume(forgottenCfg)

                data.hotPotatoCostume = false
            end
        end
    end
)
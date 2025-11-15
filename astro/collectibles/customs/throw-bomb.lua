local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.THROW_BOMB = Isaac.GetItemIdByName("Throw Bomb")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.THROW_BOMB,
                "투척 폭탄",
                "폭탄 받아라!",
                "↑ {{Bomb}}폭탄 +5" ..
                "#폭탄을 설치하지 않고 투척합니다."
            )

            --[[
            EID:addCondition(
                "5.100.52",   -- Dr. Fetus
                { "5.100."  .. tostring(Astro.Collectible.THROW_BOMB) },    
                "{{ColorYellow}}폭탄을 손에 들고 발사함{{CR}}",
                nil, "ko_kr", nil
            )]]

            EID:addCondition(
                "5.100.583",    -- Rocket in a Jar
                { "5.100." .. tostring(Astro.Collectible.THROW_BOMB) },
                "{{ColorYellow}}로켓을 손에 들고 발사함{{CR}}",
                nil, "ko_kr", nil
            )
        end
    end
)


local THROW_BOMB_FLAGS = nil

Astro:AddCallback(ModCallbacks.MC_POST_BOMB_INIT,
    ---@param bomb EntityBomb
    function(_, bomb)
        local var = bomb.Variant
        if var == BombVariant.BOMB_BIG then return end    -- TODO: Mr. Boom 게이지가 소모되지 않는 문제가 있음
        if var == BombVariant.BOMB_DECOY then return end    -- TODO: Best Friend 게이지가 소모되지 않는 문제가 있음
        if var == BombVariant.BOMB_TROLL then return end
        if var == BombVariant.BOMB_SUPERTROLL then return end
        if var == BombVariant.BOMB_THROWABLE then return end
        if var == BombVariant.BOMB_SMALL then return end
        if var == BombVariant.BOMB_GOLDENTROLL then return end
        if var == BombVariant.BOMB_ROCKET_GIGA then return end    -- TODO: (설계상) Super Rocket in a Jar로 생성된 로켓의 방향 조절이 이상하게 됩니다

        local bdata = bomb:GetData()
        if bdata._ASTRO_throwPending or bdata._ASTRO_throwHandled then return end

        local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
        if not player or not player:HasCollectible(Astro.Collectible.THROW_BOMB) then
            return
        end

        if player:IsHoldingItem() then
            return
        end

        bdata._ASTRO_throwPending = true
        bdata._ASTRO_throwSpawner = player
    end
)

Astro:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE,
    ---@param bomb EntityBomb
    function(_, bomb)
        local bdata = bomb:GetData()
        if not bdata._ASTRO_throwPending then return end
        if bdata._ASTRO_throwHandled then return end

        -- TODO: Dr. Fetus 자체로는 문제가 없는데 C Section이랑 조합될 경우
        -- 태아가 소환하는 폭탄을 캐릭터가 드는 문제가 있어서 조건문 걸어놨습니다.
        if bomb.IsFetus then
            bdata._ASTRO_throwHandled = true
            bdata._ASTRO_throwPending = nil
            return
        end

        local player = bdata._ASTRO_throwSpawner
        if not player or not player:Exists() or not player:HasCollectible(Astro.Collectible.THROW_BOMB) then
            bdata._ASTRO_throwHandled = true
            bdata._ASTRO_throwPending = nil
            bdata._ASTRO_throwSpawner = nil
            return
        end

        if player:IsHoldingItem() then
            bdata._ASTRO_throwHandled = true
            bdata._ASTRO_throwPending = nil
            bdata._ASTRO_throwSpawner = nil
            return
        end

        bdata._ASTRO_throwHandled = true
        bdata._ASTRO_throwPending = nil
        bdata._ASTRO_throwSpawner = nil
        player:TryHoldEntity(bomb)
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    function(_, player)
        if Astro:IsFirstAdded(Astro.Collectible.THROW_BOMB) then
            player:AddBombs(5)
        end
    end,
    Astro.Collectible.THROW_BOMB
)
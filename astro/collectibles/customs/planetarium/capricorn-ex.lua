Astro.Collectible.CAPRICORN_EX = Isaac.GetItemIdByName("Capricorn EX")

---

local CARPICORN_DAMAGE = 1.5
local CARPICORN_TEARMULTI = 1.2

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.CAPRICORN_EX,
                "초 염소자리",
                "실속있는 제물",
                "↑ {{DamageSmall}}최종 공격력 +1.5" ..
                "#↑ {{TearsSmall}}연사 배율 x1.2" ..
                "#↑ {{DevilChanceSmall}}악마방 확률 +10%" ..
                "#↑ {{PlanetariumChanceSmall}}천체방 확률 +9%" ..
                "#↑ {{PlanetariumChanceSmall}}첫 천체방 확률 +15%" ..
                "#{{Trinket174}} 악마방에서 Krampus 보스가 등장하지 않으며;" ..
                "#{{ArrowGrayRight}} 악마방 구조가 특수하게 변경되며 악마방에서 적들과 {{BlackHeart}}블랙하트의 등장 확률 및 빈도가 높아집니다." ..
                "#{{Trinket152}} Womb/Corpse 스테이지에서 천체방이 등장할 수 있습니다.",
                -- 중첩 시
                "공격력 및 연사만 곱연산으로 중첩 가능"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.CAPRICORN_EX,
                "Capricorn EX",
                "",
                "↑ {{Damage}} +1.5 Damage" ..
                "#↑ {{Tears}} x1.2 Tears multiplier" ..
                "#{{DevilChance}} +10% Devil Room chance" ..
                "#{{PlanetariumChance}} +9% Planetarium chance" ..
                "##Additional +15% chance if a Planetarium hasn't been entered yet" ..
                "#{{Trinket174}} Prevents Krampus from appearing in Devil Rooms;" ..
                "#{{ArrowGrayRight}} Devil Rooms are special variants with more deals, Black Hearts and enemies" ..
                "#{{Trinket152}} Planetariums can spawn in the Womb and Corpse",
                -- Stacks
                "Only damage and tears can be stacked through multiplication.",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.CAPRICORN_EX) then
            Astro:SmeltTrinket(player, TrinketType.TRINKET_NUMBER_MAGNET)
            Astro:SmeltTrinket(player, TrinketType.TRINKET_TELESCOPE_LENS)
        end
    end,
    Astro.Collectible.CAPRICORN_EX
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.CAPRICORN_EX) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + (CARPICORN_DAMAGE ^ player:GetCollectibleNum(Astro.Collectible.CAPRICORN_EX))
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = (player.MaxFireDelay + 1) / (CARPICORN_TEARMULTI ^ player:GetCollectibleNum(Astro.Collectible.CAPRICORN_EX)) - 1
            end
        end
    end
)
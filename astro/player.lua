-- local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Players = {
    LEAH = Isaac.GetPlayerTypeByName("Leah"),
    LEAH_B = Isaac.GetPlayerTypeByName("Tainted Leah", true),
    DIABELLSTAR = Isaac.GetPlayerTypeByName("Diabellstar"),
    DIABELLSTAR_B = Isaac.GetPlayerTypeByName("Tainted Diabellstar", true),
    WATER_ENCHANTRESS = Isaac.GetPlayerTypeByName("Water Enchantress"),
    WATER_ENCHANTRESS_B = Isaac.GetPlayerTypeByName("Tainted Water Enchantress", true),
    DAVID_MARTINEZ = Isaac.GetPlayerTypeByName("David Martinez"),
    DAVID_MARTINEZ_B = Isaac.GetPlayerTypeByName("Tainted David Martinez", true),
    STELLAR = Isaac.GetPlayerTypeByName("Stellar"),
    STELLAR_B = Isaac.GetPlayerTypeByName("Tainted Stellar", true),
    AINZ_OOAL_GOWN = Isaac.GetPlayerTypeByName("Ainz Ooal Gown"),
    AINZ_OOAL_GOWN_B = Isaac.GetPlayerTypeByName("Tainted Ainz Ooal Gown", true),
}

local LEAH_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_leah_hair.anm2")
local LEAH_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_leahb_hair.anm2")
local DIABELLSTAR_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_diabellstar_hair.anm2")
local DIABELLSTAR_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_diabellstarb_hair.anm2")
local WATER_ENCHANTRESS_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_water_enchantress_hair.anm2")
local WATER_ENCHANTRESS_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_water_enchantressb_hair.anm2")
local DAVID_MARTINEZ_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_david_martinez_hair.anm2")
local DAVID_MARTINEZ_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_david_martinezb_hair.anm2")
local STELLAR_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_stellar_hair.anm2")
local STELLAR_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_stellarb_hair.anm2")
local AINZ_OOAL_GOWN_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_ainz_ooal_gown_hair.anm2")
local AINZ_OOAL_GOWN_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_ainz_ooal_gownb_hair.anm2")

---@param player EntityPlayer
function Astro:IsLeah(player)
    return player:GetPlayerType() == Astro.Players.LEAH or player:GetPlayerType() == Astro.Players.LEAH_B
end

---@param player EntityPlayer
function Astro:IsDiabellstar(player)
    return player:GetPlayerType() == Astro.Players.DIABELLSTAR or player:GetPlayerType() == Astro.Players.DIABELLSTAR_B
end

---@param player EntityPlayer
function Astro:IsWaterEnchantress(player)
    return player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS or player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS_B
end

---@param player EntityPlayer
function Astro:IsDavidMartinez(player)
    return player:GetPlayerType() == Astro.Players.DAVID_MARTINEZ or player:GetPlayerType() == Astro.Players.DAVID_MARTINEZ_B
end

---@param player EntityPlayer
function Astro:IsStellar(player)
    return player:GetPlayerType() == Astro.Players.STELLAR or player:GetPlayerType() == Astro.Players.STELLAR_B
end

---@param player EntityPlayer
function Astro:IsAinzOoalGown(player)
    return player:GetPlayerType() == Astro.Players.AINZ_OOAL_GOWN or player:GetPlayerType() == Astro.Players.AINZ_OOAL_GOWN_B
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:GetPlayerType() == Astro.Players.LEAH then
            if not player:GetEffects():HasNullEffect(LEAH_HAIR) then
                player:GetEffects():AddNullEffect(LEAH_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(LEAH_HAIR) then
                player:GetEffects():RemoveNullEffect(LEAH_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.LEAH_B then
            if not player:GetEffects():HasNullEffect(LEAH_B_HAIR) then
                player:GetEffects():AddNullEffect(LEAH_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(LEAH_B_HAIR) then
                player:GetEffects():RemoveNullEffect(LEAH_B_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.DIABELLSTAR then
            if not player:GetEffects():HasNullEffect(DIABELLSTAR_HAIR) then
                player:GetEffects():AddNullEffect(DIABELLSTAR_HAIR, true)
                -- hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        else
            if player:GetEffects():HasNullEffect(DIABELLSTAR_HAIR) then
                player:GetEffects():RemoveNullEffect(DIABELLSTAR_HAIR)
                -- hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        end

        if player:GetPlayerType() == Astro.Players.DIABELLSTAR_B then
            if not player:GetEffects():HasNullEffect(DIABELLSTAR_B_HAIR) then
                player:GetEffects():AddNullEffect(DIABELLSTAR_B_HAIR, true)
                -- hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        else
            if player:GetEffects():HasNullEffect(DIABELLSTAR_B_HAIR) then
                player:GetEffects():RemoveNullEffect(DIABELLSTAR_B_HAIR)
                -- hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        end

        if player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS then
            if not player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_HAIR) then
                player:GetEffects():AddNullEffect(WATER_ENCHANTRESS_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_HAIR) then
                player:GetEffects():RemoveNullEffect(WATER_ENCHANTRESS_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS_B then
            if not player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_B_HAIR) then
                player:GetEffects():AddNullEffect(WATER_ENCHANTRESS_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_B_HAIR) then
                player:GetEffects():RemoveNullEffect(WATER_ENCHANTRESS_B_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.DAVID_MARTINEZ then
            if not player:GetEffects():HasNullEffect(DAVID_MARTINEZ_HAIR) then
                player:GetEffects():AddNullEffect(DAVID_MARTINEZ_HAIR, true)
                -- hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        else
            if player:GetEffects():HasNullEffect(DAVID_MARTINEZ_HAIR) then
                player:GetEffects():RemoveNullEffect(DAVID_MARTINEZ_HAIR)
                -- hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        end

        if player:GetPlayerType() == Astro.Players.DAVID_MARTINEZ_B then
            if not player:GetEffects():HasNullEffect(DAVID_MARTINEZ_B_HAIR) then
                player:GetEffects():AddNullEffect(DAVID_MARTINEZ_B_HAIR, true)
                -- hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        else
            if player:GetEffects():HasNullEffect(DAVID_MARTINEZ_B_HAIR) then
                player:GetEffects():RemoveNullEffect(DAVID_MARTINEZ_B_HAIR)
                -- hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        end

        if player:GetPlayerType() == Astro.Players.STELLAR then
            if not player:GetEffects():HasNullEffect(STELLAR_HAIR) then
                player:GetEffects():AddNullEffect(STELLAR_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(STELLAR_HAIR) then
                player:GetEffects():RemoveNullEffect(STELLAR_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.STELLAR_B then
            if not player:GetEffects():HasNullEffect(STELLAR_B_HAIR) then
                player:GetEffects():AddNullEffect(STELLAR_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(STELLAR_B_HAIR) then
                player:GetEffects():RemoveNullEffect(STELLAR_B_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.AINZ_OOAL_GOWN then
            if not player:GetEffects():HasNullEffect(AINZ_OOAL_GOWN_HAIR) then
                player:GetEffects():AddNullEffect(AINZ_OOAL_GOWN_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(AINZ_OOAL_GOWN_HAIR) then
                player:GetEffects():RemoveNullEffect(AINZ_OOAL_GOWN_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.AINZ_OOAL_GOWN_B then
            if not player:GetEffects():HasNullEffect(AINZ_OOAL_GOWN_B_HAIR) then
                player:GetEffects():AddNullEffect(AINZ_OOAL_GOWN_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(AINZ_OOAL_GOWN_B_HAIR) then
                player:GetEffects():RemoveNullEffect(AINZ_OOAL_GOWN_B_HAIR)
            end
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    CallbackPriority.LATE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:GetPlayerType() == Astro.Players.DIABELLSTAR then
            player.Damage = player.Damage * 1.2
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

-- Astro:AddCallback(
--     ModCallbacks.MC_POST_PLAYER_RENDER,
--     ---@param player EntityPlayer
--     ---@param offset Vector
--     function(_, player, offset)
--         if player:GetPlayerType() == Astro.Players.STELLAR_B then
--             sprite:Update()
--             sprite:Render(Astro:ToScreen(player.Position), Vector.Zero, Vector.Zero)
--         end
--     end
-- )

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            EID:addCharacterInfo(Astro.Players.LEAH, "", "Leah", "ko_kr")
            EID:addCharacterInfo(Astro.Players.LEAH_B, "", "Rachel", "ko_kr")
            EID:addCharacterInfo(Astro.Players.DIABELLSTAR, "", "Diabellstar", "ko_kr")
            EID:addCharacterInfo(Astro.Players.DIABELLSTAR_B, "", "Diabellze", "ko_kr")
            EID:addCharacterInfo(Astro.Players.WATER_ENCHANTRESS, "", "Water Enchantress", "ko_kr")
            EID:addCharacterInfo(Astro.Players.WATER_ENCHANTRESS_B, "", "Illegal Knight", "ko_kr")
            EID:addCharacterInfo(Astro.Players.DAVID_MARTINEZ, "", "David Martinez", "ko_kr")
            EID:addCharacterInfo(Astro.Players.DAVID_MARTINEZ_B, "", "Lucy", "ko_kr")
            EID:addCharacterInfo(Astro.Players.STELLAR, "", "Stellar", "ko_kr")
            EID:addCharacterInfo(Astro.Players.STELLAR_B, "", "Nayuta", "ko_kr")
            EID:addCharacterInfo(Astro.Players.AINZ_OOAL_GOWN, "", "Ainz Ooal Gown", "ko_kr")
            EID:addCharacterInfo(Astro.Players.AINZ_OOAL_GOWN_B, "", "Pandora's Actor", "ko_kr")

            -- InvDesc
            if InventoryDescriptions then
                EID:addEntity(-997, -1,
                    Astro.Players.LEAH,
                    "레아",
                    "야곱의 첫 번째 아내이자 라헬의 언니입니다."
                    .. "#{{Collectible" .. Astro.Collectible.QUANTUM_MIND .. "}} 고유 능력 : 퀀텀 마인드"
                    .. "#{{Blank}} 사용 시 충전량이 6칸 남습니다."
                    .. "#{{Collectible" .. Astro.Collectible.VENUS_EX .. "}} 기본 소지 아이템 : 초 금성",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.LEAH_B,
                    "라헬",
                    "야곱의 두 번째 아내이자 레아의 동생입니다."
                    .. "#{{Collectible" .. Astro.Collectible.PURE_LOVE .. "}} 고유 능력 : 순애"
                    .. "#{{Blank}} 순애의 행운 감소 페널티가 적용되지 않습니다.",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.DIABELLSTAR,
                    "디아벨스타",
                    "디아벨스타는 {{ColorMaroon}}유희왕 오피셜 카드게임{{CR}}의 죄보 테마에서 등장하였습니다."
                    .. "#뱀눈의 용, 포프루스라는 펫과 함께 지냅니다."
                    .. "#{{DamageSmall}} 공격력이 높습니다."
                    .. "#{{Collectible" .. Astro.Collectible.SNAKE_EYES_POPLAR .. "}} 기본 소지 아이템 : 스네이크아이즈 포프루스",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.DIABELLSTAR_B,
                    "디아벨제",
                    "디아벨제는 {{ColorMaroon}}유희왕 오피셜 카드게임{{CR}}의 죄보 테마에서 등장하였습니다."
                    .. "#디아벨스타의 라이벌입니다. 그녀와 달리 더 많은 유령을 다룹니다."
                    .. "#{{Collectible" .. Astro.Collectible.OVERWHELMING_SINFUL_SPOILS .. "}} 고유 능력 : 폭주하는 죄보"
                    .. "#{{Blank}} 영혼을 최대 5개까지 흡수할 수 있습니다."
                    .. "#{{Collectible" .. Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE .. "}} 기본 소지 아이템 : 원죄보 - 스네이크 아이",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.WATER_ENCHANTRESS,
                    "성전의 수견사",
                    "성전의 수견사는 {{ColorMaroon}}유희왕 오피셜 카드게임{{CR}}의 용사 이야기에서 등장하였습니다."
                    .. "#물의 힘을 다루는 마법사 소녀입니다."
                    .. "#{{Collectible" .. Astro.Collectible.RITE_OF_ARAMESIR .. "}} 고유 능력 : 아라메시아의 의"
                    .. "#{{Blank}} 사용 시 행운 감소 페널티가 적용되지 않습니다.",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.WATER_ENCHANTRESS_B,
                    "일리걸 나이트",
                    "일리걸 나이트는 {{ColorMaroon}}유희왕 오피셜 카드게임{{CR}}의 용사 이야기에서 등장하였습니다."
                    .. "#유적 안에서 만난 사검을 지닌 마법검사입니다."
                    .. "#{{Collectible" .. Astro.Collectible.CURSE_OF_ARAMATIR .. "}} 고유 능력 : 금주 아라마티아"
                    .. "#{{Blank}} 금주 아라마티아를 스테이지 당 한번 사용할 수 있습니다.",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.DAVID_MARTINEZ,
                    "데이비드",
                    "데이비드는 {{ColorYellow}}사이버펑크: 엣지러너{{CR}}에서 등장하였습니다."
                    .. "#{{Collectible" .. Astro.Collectible.SANDEVISTAN .. "}} 고유 능력 : 산데비스탄"
                    .. "#{{Blank}} 사용 시 {{Collectible582}}Wavy Cap을 발동하지 않으며 순간적으로 높은 {{DamageSmall}}공격력과 {{TearsSmall}}연사를 얻으며 10초동안 무적이 됩니다.",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.DAVID_MARTINEZ_B,
                    "루시",
                    "루시는 {{ColorYellow}}사이버펑크: 엣지러너{{CR}}에서 등장하였습니다."
                    .. "#데이비드의 애인으로 달에 가고 싶어하는 소망이 있습니다."
                    .. "#{{Collectible" .. Astro.Collectible.MY_MOON_MY_MAN .. "}} 기본 소지 아이템 : 나의 달 나의 그대"
                    .. "#{{Blank}} 나의 달 나의 그대를 무한정 사용할 수 있습니다.",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.STELLAR,
                    "스텔라",
                    "별자리와 행성에 관심이 많은 소녀입니다."
                    .. "#{{Collectible" .. Astro.Collectible.ALBIREO .. "}} 고유 능력 : 알비레오"
                    .. "#{{Blank}} 알비레오를 무한정 사용할 수 있습니다.",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.STELLAR_B,
                    "나유타",
                    "준비중",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.AINZ_OOAL_GOWN,
                    "아인즈",
                    "준비중",
                    "ko_kr"
                )

                EID:addEntity(-997, -1,
                    Astro.Players.AINZ_OOAL_GOWN_B,
                    "판도라즈 액터",
                    "준비중",
                    "ko_kr"
                )
            end
        end
    end
)
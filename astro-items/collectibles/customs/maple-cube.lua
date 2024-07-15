---

local USE_CUBE_SOUND = Isaac.GetSoundIdByName("UseCube")

local USE_CUBE_VOULME = 1

local BLACK_COST_COINS = 10

local BLACK_MAX_STAT = 50

local BLACK_MAX_BOSS = 50

local BLACK_MAX_MONSTER = 50

local RED_COST_COINS = 5

local RED_MAX_STAT = 25

local RED_MAX_BOSS = 25

local RED_MAX_MONSTER = 25

---

AstroItems.Collectible.BLACK_CUBE = Isaac.GetItemIdByName("Black Cube")
AstroItems.Collectible.RED_CUBE = Isaac.GetItemIdByName("Red Cube")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.BLACK_CUBE,
        "블랙 큐브",
        "...",
        "사용 시 " .. BLACK_COST_COINS .. "코인을 소모하고, 아래 옵션 중 2가지를 얻습니다." ..
        "#공력력 +1%p~+" .. BLACK_MAX_STAT .. "%p" ..
        "#보스 공격력 +1%p~+" .. BLACK_MAX_BOSS .. "%p" ..
        "#일반 몬스터 공격력 +1%p~+" .. BLACK_MAX_MONSTER .. "%p"
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.RED_CUBE,
        "레드 큐브",
        "...",
        "사용 시 " .. RED_COST_COINS .. "코인을 소모하고, 아래 옵션 중 1가지를 얻습니다." ..
        "#공력력 +1%p~+" .. RED_MAX_STAT .. "%p" ..
        "#보스 공격력 +1%p~+" .. RED_MAX_BOSS .. "%p" ..
        "#일반 몬스터 공격력 +1%p~+" .. RED_MAX_MONSTER .. "%p"
    )
end

-- 표기 순서 문제로 역순 정렬 함.
local OptionType = {
    MONSTER_DAMAGE = 3,
    BOSS_DAMAGE = 2,
    STAT_DAMAGE = 1
}

local MaxDamage = {
    [AstroItems.Collectible.BLACK_CUBE] = {
        [OptionType.STAT_DAMAGE] = BLACK_MAX_STAT,
        [OptionType.BOSS_DAMAGE] = BLACK_MAX_BOSS,
        [OptionType.MONSTER_DAMAGE] = BLACK_MAX_MONSTER
    },
    [AstroItems.Collectible.RED_CUBE] = {
        [OptionType.STAT_DAMAGE] = RED_MAX_STAT,
        [OptionType.BOSS_DAMAGE] = RED_MAX_BOSS,
        [OptionType.MONSTER_DAMAGE] = RED_MAX_MONSTER
    }
}

local OptionDisplayName = {
    [OptionType.STAT_DAMAGE] = "DMG",
    [OptionType.BOSS_DAMAGE] = "BOSS",
    [OptionType.MONSTER_DAMAGE] = "MOB"
}

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if isContinued then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(AstroItems.Collectible.BLACK_CUBE) then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        if playerWhoUsedItem:GetNumCoins() < BLACK_COST_COINS then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false
            }
        end

        playerWhoUsedItem:AddCoins(-BLACK_COST_COINS)

        local data = AstroItems:GetPersistentPlayerData(playerWhoUsedItem)
        data["mapleCube"] = {}

        local ignoreOption = rngObj:RandomInt(3) + 1

        for _, option in pairs(OptionType) do
            if option ~= ignoreOption then
                table.insert(
                    data["mapleCube"],
                    {
                        option = option,
                        damage = rngObj:RandomInt(MaxDamage[collectibleID][option]) + 1
                    }
                )
            end
        end

        playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        playerWhoUsedItem:EvaluateItems()

        SFXManager():Play(USE_CUBE_SOUND, USE_CUBE_VOULME)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    AstroItems.Collectible.BLACK_CUBE
)

AstroItems:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        if playerWhoUsedItem:GetNumCoins() < RED_COST_COINS then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false
            }
        end

        playerWhoUsedItem:AddCoins(-RED_COST_COINS)

        local data = AstroItems:GetPersistentPlayerData(playerWhoUsedItem)
        data["mapleCube"] = {}

        local option = rngObj:RandomInt(3) + 1

        table.insert(
            data["mapleCube"],
            {
                option = option,
                damage = rngObj:RandomInt(MaxDamage[collectibleID][option]) + 1
            }
        )

        playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        playerWhoUsedItem:EvaluateItems()

        SFXManager():Play(USE_CUBE_SOUND, USE_CUBE_VOULME)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    AstroItems.Collectible.RED_CUBE
)

AstroItems:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = AstroItems:GetPlayerFromEntity(source.Entity)

        if
            player ~= nil and
                (source.Type == EntityType.ENTITY_TEAR or
                    damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or
                    source.Type == EntityType.ENTITY_KNIFE)
         then
            local data = AstroItems:GetPersistentPlayerData(player)

            if data["mapleCube"] then
                for _, value in ipairs(data["mapleCube"]) do
                    if value.option == OptionType.BOSS_DAMAGE and entity:IsBoss() then
                        entity:TakeDamage(amount * value.damage / 100, 0, EntityRef(player), 0)
                    elseif value.option == OptionType.MONSTER_DAMAGE and not entity:IsBoss() then
                        entity:TakeDamage(amount * value.damage / 100, 0, EntityRef(player), 0)
                    end
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local data = AstroItems:GetPersistentPlayerData(player)

        if data and data["mapleCube"] then
            for _, value in ipairs(data["mapleCube"]) do
                if value.option == OptionType.STAT_DAMAGE then
                    player.Damage = player.Damage + player.Damage * value.damage / 100
                    break
                end
            end
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local data = AstroItems:GetPersistentPlayerData(player)
            local position = AstroItems:ToScreen(player.Position)

            if data and data["mapleCube"] then
                for index, value in ipairs(data["mapleCube"]) do
                    Isaac.RenderText(
                        OptionDisplayName[value.option] .. string.format(" +%d%%", value.damage),
                        position.X - 24,
                        position.Y - 40 - index * 10,
                        1,
                        1,
                        1,
                        1
                    )
                end
            end
        end
    end
)

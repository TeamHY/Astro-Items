---

local USE_CUBE_VOLUME = 1

local BLACK_COST_COINS = 10

local BLACK_MAX_STAT = 50

local BLACK_MAX_BOSS = 50

local BLACK_MAX_MONSTER = 50

local RED_COST_COINS = 5

local RED_MAX_STAT = 25

local RED_MAX_BOSS = 25

local RED_MAX_MONSTER = 25

local BONUS_POTENTIAL_COST_COINS = 5

local BONUS_POTENTIAL_MAX_STAT = 25

local BONUS_POTENTIAL_MAX_BOSS = 25

local BONUS_POTENTIAL_MAX_MONSTER = 25

---

Astro.Collectible.BLACK_CUBE = Isaac.GetItemIdByName("Black Cube")
Astro.Collectible.RED_CUBE = Isaac.GetItemIdByName("Red Cube")
Astro.Collectible.BONUS_POTENTIAL_CUBE = Isaac.GetItemIdByName("Bonus Potential Cube")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BLACK_CUBE,
                "블랙 큐브",
                "강력한 잠재능력 추가",
                "사용 시 {{Coin}}동전 " .. BLACK_COST_COINS .. "개를 소모하고 아래 옵션 중 2가지를 얻습니다." ..
                "#{{ArrowGrayRight}} 공력력 +1%p~+" .. BLACK_MAX_STAT .. "%p" ..
                "#{{ArrowGrayRight}} 보스 공격력 +1%p~+" .. BLACK_MAX_BOSS .. "%p" ..
                "#{{ArrowGrayRight}} 일반 몬스터 공격력 +1%p~+" .. BLACK_MAX_MONSTER .. "%p"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.RED_CUBE,
                "레드 큐브",
                "잠재능력 추가",
                "사용 시 {{Coin}}동전 " .. RED_COST_COINS .. "개를 소모하고 아래 옵션 중 하나를 얻습니다." ..
                "#{{ArrowGrayRight}} 공력력 +1%p~+" .. RED_MAX_STAT .. "%p" ..
                "#{{ArrowGrayRight}} 보스 공격력 +1%p~+" .. RED_MAX_BOSS .. "%p" ..
                "#{{ArrowGrayRight}} 일반 몬스터 공격력 +1%p~+" .. RED_MAX_MONSTER .. "%p"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.BONUS_POTENTIAL_CUBE,
                "에디셔널 큐브",
                "더 많은 잠재능력",
                "사용 시 {{Coin}}동전 " .. BONUS_POTENTIAL_COST_COINS .. "개를 소모하고, 아래 옵션 중 하나를 얻습니다." ..
                "#{{ArrowGrayRight}} 공력력 +1%p~+" .. BONUS_POTENTIAL_MAX_STAT .. "%p" ..
                "#{{ArrowGrayRight}} 보스 공격력 +1%p~+" .. BONUS_POTENTIAL_MAX_BOSS .. "%p" ..
                "#{{ArrowGrayRight}} 일반 몬스터 공격력 +1%p~+" .. BONUS_POTENTIAL_MAX_MONSTER .. "%p" ..
                "#!!! {{Collectible" .. Astro.Collectible.BLACK_CUBE .. "}}Black Cube 및 {{Collectible" .. Astro.Collectible.RED_CUBE .. "}}Red Cube와 별개로 적용"
            )
        end
    end
)

-- 표기 순서 문제로 역순 정렬 함.
local OptionType = {
    STAT_DAMAGE = 1,
    BOSS_DAMAGE = 2,
    MONSTER_DAMAGE = 3,
    BONUS_STAT_DAMAGE = 4,
    BONUS_BOSS_DAMAGE = 5,
    BONUS_MONSTER_DAMAGE = 6,
}

local MaxDamage = {
    [Astro.Collectible.BLACK_CUBE] = {
        [OptionType.STAT_DAMAGE] = BLACK_MAX_STAT,
        [OptionType.BOSS_DAMAGE] = BLACK_MAX_BOSS,
        [OptionType.MONSTER_DAMAGE] = BLACK_MAX_MONSTER
    },
    [Astro.Collectible.RED_CUBE] = {
        [OptionType.STAT_DAMAGE] = RED_MAX_STAT,
        [OptionType.BOSS_DAMAGE] = RED_MAX_BOSS,
        [OptionType.MONSTER_DAMAGE] = RED_MAX_MONSTER
    },
    [Astro.Collectible.BONUS_POTENTIAL_CUBE] = {
        [OptionType.BONUS_STAT_DAMAGE] = BONUS_POTENTIAL_MAX_STAT,
        [OptionType.BONUS_BOSS_DAMAGE] = BONUS_POTENTIAL_MAX_BOSS,
        [OptionType.BONUS_MONSTER_DAMAGE] = BONUS_POTENTIAL_MAX_MONSTER
    }
}

local OptionDisplayName = {
    [OptionType.STAT_DAMAGE] = "DMG",
    [OptionType.BOSS_DAMAGE] = "BOSS",
    [OptionType.MONSTER_DAMAGE] = "MOB",
    [OptionType.BONUS_STAT_DAMAGE] = "B-DMG",
    [OptionType.BONUS_BOSS_DAMAGE] = "B-BOSS",
    [OptionType.BONUS_MONSTER_DAMAGE] = "B-MOB"
}

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if isContinued then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(Astro.Collectible.BLACK_CUBE) then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
            end
        end
    end
)

Astro:AddCallback(
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

        local data = Astro:GetPersistentPlayerData(playerWhoUsedItem)
        
        if (not data["mapleCube"]) then
            data["mapleCube"] = {}
        end

        local newData = {}

        for _, value in pairs(data["mapleCube"]) do
            if value.option >= OptionType.BONUS_STAT_DAMAGE then
                table.insert(newData, value)
            end
        end

        data["mapleCube"] = newData

        local ignoreOption = rngObj:RandomInt(3) + 1

        for _, option in pairs(OptionType) do
            if option ~= ignoreOption and option < OptionType.BONUS_STAT_DAMAGE then
                table.insert(
                    data["mapleCube"],
                    {
                        option = option,
                        damage = rngObj:RandomInt(MaxDamage[collectibleID][option]) + 1
                    }
                )
            end
        end

        table.sort(data["mapleCube"], function(a, b)
            return a.option > b.option
        end)

        playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        playerWhoUsedItem:EvaluateItems()

        SFXManager():Play(Astro.SoundEffect.MAPLE, USE_CUBE_VOLUME)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.BLACK_CUBE
)

Astro:AddCallback(
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

        local data = Astro:GetPersistentPlayerData(playerWhoUsedItem)
        
        if (not data["mapleCube"]) then
            data["mapleCube"] = {}
        end

        local newData = {}

        for _, value in pairs(data["mapleCube"]) do
            if value.option >= OptionType.BONUS_STAT_DAMAGE then
                table.insert(newData, value)
            end
        end

        data["mapleCube"] = newData

        local option = rngObj:RandomInt(3) + 1

        table.insert(
            data["mapleCube"],
            {
                option = option,
                damage = rngObj:RandomInt(MaxDamage[collectibleID][option]) + 1
            }
        )

        table.sort(data["mapleCube"], function(a, b)
            return a.option > b.option
        end)

        playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        playerWhoUsedItem:EvaluateItems()

        SFXManager():Play(Astro.SoundEffect.MAPLE, USE_CUBE_VOLUME)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.RED_CUBE
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        if playerWhoUsedItem:GetNumCoins() < BONUS_POTENTIAL_COST_COINS then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false
            }
        end

        playerWhoUsedItem:AddCoins(-BONUS_POTENTIAL_COST_COINS)

        local data = Astro:GetPersistentPlayerData(playerWhoUsedItem)
        
        if (not data["mapleCube"]) then
            data["mapleCube"] = {}
        end

        local newData = {}

        for _, value in pairs(data["mapleCube"]) do
            if value.option < OptionType.BONUS_STAT_DAMAGE then
                table.insert(newData, value)
            end
        end

        data["mapleCube"] = newData

        local option = rngObj:RandomInt(3) + 4

        table.insert(
            data["mapleCube"],
            {
                option = option,
                damage = rngObj:RandomInt(MaxDamage[collectibleID][option]) + 1
            }
        )

        table.sort(data["mapleCube"], function(a, b)
            return a.option > b.option
        end)

        playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        playerWhoUsedItem:EvaluateItems()

        SFXManager():Play(Astro.SoundEffect.MAPLE, USE_CUBE_VOLUME)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.BONUS_POTENTIAL_CUBE
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if
            player ~= nil and
                (source.Type == EntityType.ENTITY_TEAR or
                    damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or
                    source.Type == EntityType.ENTITY_KNIFE)
         then
            local data = Astro:GetPersistentPlayerData(player)

            if data["mapleCube"] then
                for _, value in ipairs(data["mapleCube"]) do
                    if (value.option == OptionType.BOSS_DAMAGE or value.option == OptionType.BONUS_BOSS_DAMAGE) and entity:IsBoss() then
                        entity:TakeDamage(amount * value.damage / 100, 0, EntityRef(player), 0)
                    elseif (value.option == OptionType.MONSTER_DAMAGE or value.option == OptionType.BONUS_MONSTER_DAMAGE) and not entity:IsBoss() then
                        entity:TakeDamage(amount * value.damage / 100, 0, EntityRef(player), 0)
                    end
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local data = Astro:GetPersistentPlayerData(player)

        if data and data["mapleCube"] then
            for _, value in ipairs(data["mapleCube"]) do
                if value.option == OptionType.STAT_DAMAGE then
                    player.Damage = player.Damage + player.Damage * value.damage / 100
                    break
                elseif value.option == OptionType.BONUS_STAT_DAMAGE then
                    player.Damage = player.Damage + player.Damage * value.damage / 100
                    break
                end
            end
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

local font = Font()
font:Load("font/pftempestasevencondensed.fnt")

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        if not Game():GetRoom():IsClear() then
            return
        end

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local data = Astro:GetPersistentPlayerData(player)
            local position = Astro:ToScreen(player.Position)

            if data and data["mapleCube"] then
                for index, value in ipairs(data["mapleCube"]) do
                    font:DrawString(
                        OptionDisplayName[value.option] .. string.format(" +%d%%", value.damage),
                        position.X - 24,
                        position.Y - 40 - index * 10,
                        KColor(1, 1, 1, 1),
                        48,
                        true
                    )
                end
            end
        end
    end
)

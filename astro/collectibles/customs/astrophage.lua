---

local ABSORB_SPEED = 0.05

local ABSORB_TEARS = 0.3

local ABSORB_DAMAGE_MULTIPLIER = 1.05

local ABSORB_RANGE = 0.5

local ABSORB_LUCK = 0.5

local SUMMON_KEY = Keyboard.KEY_8

local SUMMON_LIMIT_PER_STAGE = 1

---

Astro.Collectible.ASTROPHAGE = Isaac.GetItemIdByName("Astrophage")

local ITEM_ID = Astro.Collectible.ASTROPHAGE

---@type CollectibleType[]
local planetariumCollectibles = {}

---@return CollectibleType[]
local function GetSunAndMoonCollectibles()
    local collectibles = {
        CollectibleType.COLLECTIBLE_SOL,
        CollectibleType.COLLECTIBLE_LUNA,
    }
    
    return collectibles
end

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        ---행성방 아이템 목록
        planetariumCollectibles = {
            CollectibleType.COLLECTIBLE_CRYSTAL_BALL,
            CollectibleType.COLLECTIBLE_ZODIAC,
            CollectibleType.COLLECTIBLE_SOL,
            CollectibleType.COLLECTIBLE_LUNA,
            CollectibleType.COLLECTIBLE_MERCURIUS,
            CollectibleType.COLLECTIBLE_VENUS,
            CollectibleType.COLLECTIBLE_TERRA,
            CollectibleType.COLLECTIBLE_MARS,
            CollectibleType.COLLECTIBLE_JUPITER,
            CollectibleType.COLLECTIBLE_SATURNUS,
            CollectibleType.COLLECTIBLE_URANUS,
            CollectibleType.COLLECTIBLE_NEPTUNUS,
            CollectibleType.COLLECTIBLE_PLUTO,
            Astro.Collectible.CYGNUS,
            Astro.Collectible.LIBRA_EX,
            Astro.Collectible.CANCER_EX,
            Astro.Collectible.SCORPIO_EX,
            Astro.Collectible.CAPRICORN_EX,
            Astro.Collectible.VIRGO_EX,
            Astro.Collectible.LEO_EX,
            Astro.Collectible.ARIES_EX,
            Astro.Collectible.TAURUS_EX,
            Astro.Collectible.AQUARIUS_EX,
            Astro.Collectible.CASIOPEA,
            Astro.Collectible.CORVUS,
            Astro.Collectible.PAVO,
            Astro.Collectible.COMET,
            Astro.Collectible.PISCES_EX,
            Astro.Collectible.GEMINI_EX,
            Astro.Collectible.PTOLEMAEUS,
            Astro.Collectible.ALTAIR,
            Astro.Collectible.VEGA,
            Astro.Collectible.DENEB,
            Astro.Collectible.SOLAR_SYSTEM,
            Astro.Collectible.QUASAR,
            Astro.Collectible.LANIAKEA_SUPERCLUSTER,
            Astro.Collectible.COPERNICUS,
            Astro.Collectible.SUPER_NOVA,
            Astro.Collectible.PILLARS_OF_CREATION,
        }

        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "아스트로파지",
                "별을 먹는 미생물",
                "!!! 사용 이후 다음 게임에서 {{Collectible" .. CollectibleType.COLLECTIBLE_SOL .. "}}Sol, " ..
                "{{Collectible" .. CollectibleType.COLLECTIBLE_LUNA .. "}}Luna 미등장" ..
                "#사용 시:" ..
                "#{{IND}}↑ {{PlanetariumChanceSmall}}천체방 확률 +9%" ..
                "#{{IND}}↑ {{PlanetariumChanceSmall}}첫 천체방 확률 +15%" ..
                "#{{IND}}{{PlanetariumChanceSmall}} Womb/Corpse 스테이지에서 천체방이 등장할 수 있습니다." ..
                "#{{IND}} 그 방의 {{Planetarium}}천체관 아이템을 흡수하고 능력치가 증가합니다." ..
                "#{{IND}}{{Blank}} ({{TearsSmall}}+" .. ABSORB_TEARS ..
                "/{{DamageSmall}}x" .. ABSORB_DAMAGE_MULTIPLIER ..
                "/{{SpeedSmall}}+" .. ABSORB_SPEED ..
                "/{{RangeSmall}}+" .. ABSORB_RANGE ..
                "/{{LuckSmall}}+" .. ABSORB_LUCK .. ")" ..
                "#스테이지당 " .. SUMMON_LIMIT_PER_STAGE .. "번 숫자 8키를 누르면 소지중인 모든 천체관 아이템을 드랍합니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Astrophage", "",
                "Absorbs every planetarium item in the room" ..
                "#Per absorbed item:" ..
                "#{{IND}}↑ {{Speed}} +" .. ABSORB_SPEED .. " Speed" ..
                "#{{IND}}↑ {{Tears}} +" .. ABSORB_TEARS .. " Tears" ..
                "#{{IND}}↑ {{Damage}} x" .. ABSORB_DAMAGE_MULTIPLIER .. " Damage multiplier" ..
                "#{{IND}}↑ {{Range}} +" .. ABSORB_RANGE .. " Range" ..
                "#{{IND}}↑ {{Luck}} +" .. ABSORB_LUCK .. " Luck" ..
                "#{{Trinket152}} Smelts Telescope Lens on the first use" ..
                "#Press the number 8 key to drop every held planetarium item. Can only be used once per floor" ..
                "#!!! Sol and Luna will not appear in the next run",
                nil, "en_us"
            )
        end

        Astro:AddRerollCondition(
            ---@param selectedCollectible CollectibleType
            function(selectedCollectible)
                if not Astro.Data["astrophageBanSunAndMoon"] then
                    return false
                end

                return {
                    reroll = Astro:Contain(GetSunAndMoonCollectibles(), selectedCollectible),
                    modifierName = "Astrophage"
                }
            end
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            Astro.Data["astrophageBanSunAndMoon"] = Astro.Data["usedAstrophage"] == true
            Astro.Data["usedAstrophage"] = false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleType CollectibleType
    ---@param rng RNG
    ---@param player EntityPlayer
    function(_, collectibleType, rng, player)
        local absorbedCount = 0

        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            local pickup = entity:ToPickup()

            if pickup and Astro:Contain(planetariumCollectibles, pickup.SubType) then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, player)
                pickup:Remove()

                absorbedCount = absorbedCount + 1
            end
        end

        local data = Astro:GetPersistentPlayerData(player)

        if data then
            if not data["astrophageSmeltedLens"] then
                data["astrophageSmeltedLens"] = true
                Astro:SmeltTrinket(player, TrinketType.TRINKET_TELESCOPE_LENS)
            end

            if absorbedCount > 0 then
                data["astrophageAbsorbedCount"] = (data["astrophageAbsorbedCount"] or 0) + absorbedCount

                player:AddCacheFlags(CacheFlag.CACHE_ALL)
                player:EvaluateItems()

                SFXManager():Play(SoundEffect.SOUND_VAMP_GULP)
            end
        end

        Astro.Data["usedAstrophage"] = true

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    ITEM_ID
)

---@param player EntityPlayer
local function SummonHeldPlanetariumCollectibles(player)
    local floorData = Astro.SaveManager.GetFloorSave(player)

    if not floorData or (floorData["astrophageSummonCount"] or 0) >= SUMMON_LIMIT_PER_STAGE then
        SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)

        return
    end

    local summonedCount = 0

    for _, collectible in ipairs(planetariumCollectibles) do
        for _ = 1, player:GetCollectibleNum(collectible, true) do
            player:RemoveCollectible(collectible)
            Astro:SpawnCollectible(collectible, player.Position)

            summonedCount = summonedCount + 1
        end
    end

    if summonedCount <= 0 then
        SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)

        return
    end

    floorData["astrophageSummonCount"] = (floorData["astrophageSummonCount"] or 0) + 1

    SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND)
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        if Game():IsPaused() then
            return
        end

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player.ControllerIndex == 0
                and player:HasCollectible(ITEM_ID)
                and Input.IsButtonTriggered(SUMMON_KEY, player.ControllerIndex)
            then
                SummonHeldPlanetariumCollectibles(player)
            end
        end
    end
)

---@param player EntityPlayer
---@return integer
local function GetAbsorbedCount(player)
    local data = Astro:GetPersistentPlayerData(player)

    return data and data["astrophageAbsorbedCount"] or 0
end

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local absorbedCount = GetAbsorbedCount(player)

        if absorbedCount <= 0 then
            return
        end

        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + ABSORB_SPEED * absorbedCount
        elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, ABSORB_TEARS * absorbedCount)
        elseif cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + (ABSORB_RANGE * 40) * absorbedCount
        elseif cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + ABSORB_LUCK * absorbedCount
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.MULTIPLY,
    ---@param player EntityPlayer
    function(_, player)
        local absorbedCount = GetAbsorbedCount(player)

        if absorbedCount > 0 then
            player.Damage = player.Damage * (ABSORB_DAMAGE_MULTIPLIER ^ absorbedCount)
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

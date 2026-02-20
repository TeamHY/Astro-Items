---

-- 후광 적용 반지름
local HALO_RADIUS = 128

-- 슬로우 지속 시간 (매 프레임 갱신됩니다. 1 프레임 적용 시에 깜박임이 있어 2 프레임 적용했습니다.)
local SLOW_EFFECT_DURATION = 2

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.URANUS_EX = Isaac.GetItemIdByName("URANUS EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.URANUS_EX,
                "초 천왕성",
                "꽁꽁꽁",
                "{{Collectible596}} Uranus 효과 발동:" ..
                "#{{IND}}{{Freezing}} 적 처치시 적이 얼어붙습니다." ..
                "#{{IND}}{{Freezing}} 얼어붙은 적은 접촉 시 직선으로 날아가 10방향으로 고드름 눈물을 발사합니다." ..
                "#{{Slow}} 캐릭터에게 오라가 생기며 오라 안에 들어온 적을 둔화시킵니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.URANUS_EX,
                "Uranus EX", "",
                "{{Collectible596}} Uranus effect applied:" ..
                "#{{IND}}{{Freezing}} Isaac shoots petrifying tears that freeze enemies on death" ..
                "#{{IND}} Touching a frozen enemy makes it slide away and explode into 10 ice shards" ..
                "#{{Slow}} Aura slows enemies inside",
                nil, "en_us"
            )
        end
    end
)

local URANUS_EX_HALO_VARIANT = Isaac.GetEntityVariantByName("Uranus Ex Halo")

local function CreateHaloForPlayer(player)
    local halo = Isaac.Spawn(EntityType.ENTITY_EFFECT, URANUS_EX_HALO_VARIANT, 0, player.Position, Vector.Zero, player)
    halo.Parent = player

    local scale = HALO_RADIUS / 64
    halo:GetSprite().Scale = Vector(scale, scale)

    return halo
end

local function HasHaloForPlayer(player)
    for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, URANUS_EX_HALO_VARIANT)) do
        if entity.Parent == player then
            return true
        end
    end
    return false
end

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    function(_, effect)
        local player = effect.Parent:ToPlayer()

        if not player then return end

        if not player:HasCollectible(Astro.Collectible.URANUS_EX) then
            effect:Remove()
            return
        end

        effect.Position = player.Position + Vector(0, -10)
        effect.Velocity = player.Velocity

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if not (entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE) then
                goto continue
            end

            local distance = effect.Position:Distance(entity.Position)
            if distance <= HALO_RADIUS then
                entity:AddSlowing(EntityRef(effect), SLOW_EFFECT_DURATION, 0.5, Color(0.5, 0.8, 1.0, 1.0, 0, 0, 0))
                entity:AddEntityFlags(EntityFlag.FLAG_ICE)
            end

            ::continue::
        end
    end,
    URANUS_EX_HALO_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if player:HasCollectible(Astro.Collectible.URANUS_EX) and not HasHaloForPlayer(player) then
                CreateHaloForPlayer(player)
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_URANUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_URANUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_URANUS)
        end

        if not HasHaloForPlayer(player) then
            CreateHaloForPlayer(player)
        end
    end,
    Astro.Collectible.URANUS_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_URANUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_URANUS)
        end
    end,
    Astro.Collectible.URANUS_EX
)

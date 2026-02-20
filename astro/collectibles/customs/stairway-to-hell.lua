local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.STAIRWAY_TO_HELL = Isaac.GetItemIdByName("Stairway to Hell")

local STAIRWAY_TO_HELL_VARIANT = 3103
local FOOL_DEVIL_BUM_VARIANT = 3100

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.STAIRWAY_TO_HELL,
                "지옥의 계단",
                "기다린 것을 얻을 수 있기를",
                "{{DevilRoom}} 스테이지 첫 방에 {{BrokenHeart}}부서진하트 2칸으로 거래하는 악마방으로 갈 수 있는 사다리가 생성됩니다." ..
                "#!!! 사다리는 방을 벗어나면 사라집니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.STAIRWAY_TO_HELL,
                "Stairway to Hell",
                "",
                "Spawns a ladder in the first room of every floor that leads to a unique {{DevilRoom}} Devil Room where all deals cost 2 {{BrokenHeart}} broken hearts",
                nil, "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.STAIRWAY_TO_HELL) then
            local level = Game():GetLevel()
            local room = level:GetCurrentRoom()

            if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() and room:IsFirstVisit() then
                Astro:Spawn(EntityType.ENTITY_EFFECT, STAIRWAY_TO_HELL_VARIANT, 0, room:GetGridPosition(19))
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local players = Isaac.FindInRadius(effect.Position, 20, EntityPartition.PLAYER)

        if #players > 0 then
            for _, player in pairs(players) do
                player:ToPlayer():GetEffects():RemoveNullEffect(NullItemID.ID_LOST_CURSE)
            end
            Isaac.ExecuteCommand("goto s.devil")
            Astro:ScheduleForUpdate(
                function()
                    local level = Game():GetLevel()
                    local enterDoor = level.EnterDoor
                    local room = level:GetCurrentRoom()
                    local spawnPos, spawnOffset = Vector(0, 0), Vector(0, 0)

                    if enterDoor == DoorSlot.LEFT0 or enterDoor == DoorSlot.UP0 then
                        spawnPos = room:GetDoorSlotPosition(DoorSlot.RIGHT0)
                        spawnOffset = Vector(-100, 50)
                    elseif enterDoor == DoorSlot.RIGHT0 or enterDoor == DoorSlot.DOWN0 then
                        spawnPos = room:GetDoorSlotPosition(DoorSlot.LEFT0)
                        spawnOffset = Vector(100, 50)
                    end

                    room:GetDoor(enterDoor):SpawnDust()
                    room:RemoveDoor(enterDoor)
                    Astro:Spawn(EntityType.ENTITY_PICKUP, FOOL_DEVIL_BUM_VARIANT, 1, spawnPos + spawnOffset)
                end,
                2
            )
        end
    end,
    STAIRWAY_TO_HELL_VARIANT
)


------ 브로큰 하트 거래 by Epiphany ------
local BrokenHeartSprite1 = Sprite()
BrokenHeartSprite1:Load("gfx/items/shop/broken_heart.anm2", true)

local BrokenHeartSprite2 = Sprite()
BrokenHeartSprite2:Load("gfx/items/shop/two_broken_hearts.anm2", true)

---@param pickup EntityPickup
local function IsDevilDealItem(pickup)
	return pickup.Price < 0 and pickup.Price ~= PickupPrice.PRICE_FREE and pickup.Price ~= PickupPrice.PRICE_SPIKES
end

---@param player EntityPlayer
---@param pickup EntityPickup
local function CanPickupDeal(player, pickup)
	return IsDevilDealItem(pickup) and pickup.Price ~= PickupPrice.PRICE_SOUL
end

--- Kills all pedestals that cost hearts. For use when Lost buys a devil item
---@param ignoredPickup? EntityPickup A pointer hash to a pedestal that will be ignored. In most cases, this should be a pedestal that the player just picked up.
---@param filter? fun(Pedestal: EntityPickup): boolean
local function KillDevilPedestals(ignoredPickup, filter)
	local ignoredHash = GetPtrHash(ignoredPickup) or -1
	local level = Game():GetLevel()

	local ent = Isaac.FindByType(EntityType.ENTITY_PICKUP)
    if #ent > 0 then
        for _, p in ipairs(ent) do
            local pickup = p:ToPickup() ---@cast pickup EntityPickup

            if GetPtrHash(pickup) ~= ignoredHash
                and IsDevilDealItem(pickup)
                    and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE
                and (not filter or filter(pickup))
            then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
                pickup:Remove()
            end
        end
    end
end

local function IsAnyLost(player, onlyReal)
	local type = player:GetPlayerType()
	return type == PlayerType.PLAYER_THELOST
		or type == PlayerType.PLAYER_THELOST_B
		or (not onlyReal and (type == PlayerType.PLAYER_JACOB2_B
			or player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE)))
end

local function specialPickupEffect(pos, player, c)
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, pos, Vector.Zero, nil):ToEffect() ---@cast effect1 EntityEffect
	effect.Color = c

	if player then
		effect:FollowParent(player)
	end

	Game():ShakeScreen(15)
	SFXManager():Play(SoundEffect.SOUND_DEATH_CARD)
end

local PAY_PRICE = {}
PAY_PRICE[Astro.PickupPrice.PRICE_BROKEN_HEART] = function(player)
	if not IsAnyLost(player) then
		player:AddBrokenHearts(1)
	end
	specialPickupEffect(player.Position, player, Color(0, 0, 0, 1, 1, 0, 0))
end
PAY_PRICE[Astro.PickupPrice.PRICE_TWO_BROKEN_HEARTS] = function(player)
	if not IsAnyLost(player) then
		player:AddBrokenHearts(2)
	end
	specialPickupEffect(player.Position, player, Color(0, 0, 0, 1, 1, 0, 0))
end

---@param pickup EntityPickup
---Options? compatibility and Choice pedestals in general.
---Kills choices connected to the pickup passed.
local function KillChoice(pickup)
	if pickup.OptionsPickupIndex ~= 0 then
		local ents = Isaac.FindByType(EntityType.ENTITY_PICKUP)
        
        for _, e in ipairs(ents) do
            local p = e:ToPickup()

            if p and pickup.OptionsPickupIndex == p.OptionsPickupIndex and GetPtrHash(pickup) ~= GetPtrHash(p) then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
                p:Remove()
            end
        end
	end
end

---@param pedestal EntityPickup
---@param Price PickupPrice
local function ForcePedestalPrice(pedestal, Price)
    if pedestal.Price == 0 then return end
    
	local prpData = Astro.SaveManager.GetRerollPickupSave(pedestal)
	prpData.Price = Price

	if Astro:HasTrinket(TrinketType.TRINKET_YOUR_SOUL)
		and prpData.Price < 0 and prpData.Price ~= PickupPrice.PRICE_FREE and prpData.Price ~= PickupPrice.PRICE_SPIKES then
		pedestal.Price = PickupPrice.PRICE_SOUL
	else
		pedestal.Price = Price
	end

	pedestal.ShopItemId = -3
	pedestal.AutoUpdatePrice = false

    BrokenHeartSprite1:Play("Default", true)
    BrokenHeartSprite2:Play("Default", true)
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    ---@param pickup EntityPickup
    function(_, pickup)
        local room = Game():GetLevel():GetCurrentRoom()
        local roomType = room:GetType()
        local slots = Isaac.FindByType(EntityType.ENTITY_PICKUP, FOOL_DEVIL_BUM_VARIANT, -1, true)

        if roomType == RoomType.ROOM_DEVIL
            and pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL
            and pickup:Exists()
            and #slots > 0
        then
            local pData = Astro.SaveManager.GetRerollPickupSave(pickup)

            if not pData.prevSubType then
                pData.prevSubType = pickup.SubType
            elseif pData.prevSubType ~= pickup.SubType then
                local forcePrice = Astro.PickupPrice.PRICE_TWO_BROKEN_HEARTS

                if pickup.Price == (PickupPrice.PRICE_ONE_HEART or PickupPrice.PRICE_ONE_SOUL_HEART) then
                    forcePrice = Astro.PickupPrice.PRICE_BROKEN_HEART
                end

                ForcePedestalPrice(pickup, forcePrice)
                pData.prevSubType = pickup.SubType
            end
        end
    end,
    PickupVariant.PICKUP_COLLECTIBLE
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_PICKUP_COLLISION,
    ---@param pickup EntityPickup
    ---@param ent Entity
    function(_, pickup, ent)
        local player = ent:ToPlayer()

        if not player then return end

        if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
            player = player:GetMainTwin()
        end

        if pickup.Price == (Astro.PickupPrice.PRICE_BROKEN_HEART) then
            if pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL
                and pickup.Wait == 0
                and not player:IsHoldingItem()
                and player:CanPickupItem()
                and player.ItemHoldCooldown == 0
            then
                PAY_PRICE[pickup.Price](player)
                KillChoice(pickup)
            else
                return true
            end
        elseif pickup.Price == (Astro.PickupPrice.PRICE_TWO_BROKEN_HEARTS) then
            if pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL
                and pickup.Wait == 0
                and not player:IsHoldingItem()
                and player:CanPickupItem()
                and player.ItemHoldCooldown == 0
            then
                PAY_PRICE[pickup.Price](player)
                KillChoice(pickup)
            else
                return true
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_PICKUP_COLLISION,
    ---@param pickup EntityPickup
    ---@param collider Entity
    function(_, pickup, collider)
        local player = collider:ToPlayer()
    
        if player and CanPickupDeal(player, pickup) then
            local slots = Isaac.FindByType(EntityType.ENTITY_PICKUP, FOOL_DEVIL_BUM_VARIANT, -1, true)
            
            if #slots > 0 then
                if pickup.Price == (Astro.PickupPrice.PRICE_BROKEN_HEART or Astro.PickupPrice.PRICE_TWO_BROKEN_HEARTS) then
                    if IsAnyLost(player) then
                        KillDevilPedestals(pickup)
                    end
                end
            end
        end
    end,
    PickupVariant.PICKUP_COLLECTIBLE
)

---@param ent Entity | Vector
---@param offset Vector
---@param ignoreShake? boolean
local function GetEntityRenderPos(ent, offset, ignoreShake)
	local pos
	if getmetatable(ent).__type == "Vector" then
		---@cast ent Vector
		pos = ent
	else
		---@cast ent Entity
		pos = ent.Position + ent.PositionOffset

		if ent:ToPlayer() and Game():GetLevel():GetCurrentRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
			---@cast ent EntityPlayer
			pos = pos + ent:GetFlyingOffset()
		end
	end

	local renderPos = Isaac.WorldToRenderPosition(pos) + offset

	if ignoreShake then
		renderPos = renderPos - Game().ScreenShakeOffset
	end

	return renderPos
end

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function()
        local room = Game():GetLevel():GetCurrentRoom()
        local roomType = room:GetType()
        local slots = Isaac.FindByType(EntityType.ENTITY_PICKUP, FOOL_DEVIL_BUM_VARIANT, -1, true)

        if roomType == RoomType.ROOM_DEVIL and #slots > 0 then
            BrokenHeartSprite1:Update()
            BrokenHeartSprite2:Update()
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_RENDER, 
    ---@param pickup EntityPickup
    ---@param offset Vector
    function(_, pickup, offset)
        local renderPos = GetEntityRenderPos(pickup, offset)

        if pickup.Price == Astro.PickupPrice.PRICE_BROKEN_HEART then
            BrokenHeartSprite1:Render(renderPos + Vector(0, 1), Vector(0,0), Vector(0,0))
        elseif pickup.Price == Astro.PickupPrice.PRICE_TWO_BROKEN_HEARTS then
            BrokenHeartSprite2:Render(renderPos + Vector(0, 1), Vector(0,0), Vector(0,0))
        end
    end
)


------ 카드 주는 거지 ------
Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        local sprite = pickup:GetSprite()
	    sprite:Play("Appear", false)

        pickup.SpriteOffset = Vector(0, -4)
        pickup:AddEntityFlags(EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_DONT_OVERWRITE | EntityFlag.FLAG_NO_KNOCKBACK)
        
        local room = Game():GetLevel():GetCurrentRoom()
        local roomType = room:GetType()

        if roomType == RoomType.ROOM_DEVIL then
            local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, false, false)

            for _, p in ipairs(pickups) do
                local pickup = p:ToPickup()
                
                if pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL then
                    local pData = Astro.SaveManager.GetRerollPickupSave(pickup)

                    if not pData.ASTRO_PlayerCheckedPedestal then
                        local forcePrice = Astro.PickupPrice.PRICE_TWO_BROKEN_HEARTS

                        if pickup.Price == (PickupPrice.PRICE_ONE_HEART or PickupPrice.PRICE_ONE_SOUL_HEART) then
                            forcePrice = Astro.PickupPrice.PRICE_BROKEN_HEART
                        end

                        ForcePedestalPrice(pickup, forcePrice)
                        pData.ASTRO_PlayerCheckedPedestal = true
                        pData.prevSubType = pickup.SubType
                    end
                end
            end
        end
    end,
    FOOL_DEVIL_BUM_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    ---@param pickup EntityPickup
    function(_, pickup)
        pickup.SpriteOffset = Vector(0, -4)

        local sprite = pickup:GetSprite()
        if sprite:IsFinished("Appear") then
            sprite:Play("Idle", true)
        end
    end,
    FOOL_DEVIL_BUM_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_PICKUP_COLLISION,
    ---@param pickup EntityPickup
    ---@param collider Entity
    ---@param low boolean
    function(_, pickup, collider, low)
        local player = collider:ToPlayer()

        if player then
			player:UseCard(Card.CARD_FOOL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            pickup:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT)
        end
    end,
    FOOL_DEVIL_BUM_VARIANT
)
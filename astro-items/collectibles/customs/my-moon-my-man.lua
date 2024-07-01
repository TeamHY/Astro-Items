local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.MY_MOON_MY_MAN = Isaac.GetItemIdByName("My Moon My Man")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.MY_MOON_MY_MAN,
        "나의 달 나의 그대",
        "...",
    "#{wakaba_md1} 버튼으로 소지 중인 액티브와 픽업 슬롯 액티브를 교체합니다."
        .. "#카드/알약 액티브가 비어있을 경우 액티브를 픽업 슬롯으로 옮깁니다."
        .. "#데이비드, 루시가 아닐 경우 사용 시 사라집니다."
        .. "#!!! (일부 아이템은 픽업 슬롯으로 옮길 수 없음)"
        .. "{{CR}}"
    )
end

-- 아이템 위치 바꾸는 키
local swapKey = Keyboard.KEY_8

AstroItems.MaidDuetBlackLists = {
    [CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE] = true,
    [CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES] = true,
    [CollectibleType.COLLECTIBLE_D_INFINITY] = true,
    [CollectibleType.COLLECTIBLE_BLANK_CARD] = true,
    [CollectibleType.COLLECTIBLE_PLACEBO] = true,
    [CollectibleType.COLLECTIBLE_CLEAR_RUNE] = true
}
-- 밸런스 문제로 REPENTOGON 여부 상관 없이 제외합니다.
-- if not REPENTOGON then
    AstroItems.MaidDuetBlackLists[CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = true
    AstroItems.MaidDuetBlackLists[CollectibleType.COLLECTIBLE_JAR_OF_WISPS] = true
-- end
AstroItems.MaidDuetBlackListsCharges = {
    [CollectibleType.COLLECTIBLE_EVERYTHING_JAR] = true,
    [CollectibleType.COLLECTIBLE_WOODEN_NICKEL] = true,
    [CollectibleType.COLLECTIBLE_BREATH_OF_LIFE] = true,
    [CollectibleType.COLLECTIBLE_NOTCHED_AXE] = true
}

AstroItems.MaidDuetBlackListsPlayers = {
    [PlayerType.PLAYER_CAIN_B] = true
}

---@param player EntityPlayer
local function canUseMaidDuet(player, force)
    local active1 = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
    local active2 = player:GetActiveItem(ActiveSlot.SLOT_POCKET)
    local extraCond = Isaac.RunCallback(AstroItems.Callbacks.EVALUATE_MAID_DUET, player)
    return active1 > 0 and not AstroItems.MaidDuetBlackLists[active1] and not AstroItems.MaidDuetBlackLists[active2] and
        not extraCond -- and
        -- (force or not player:GetEffects():HasCollectibleEffect(AstroItems.Collectible.UNTITLED))
end

AstroItems:AddCallback(
    AstroItems.Callbacks.EVALUATE_MAID_DUET,
    ---@param player EntityPlayer
    function(_, player)
        if AstroItems.MaidDuetBlackListsPlayers[player:GetPlayerType()] then
            return true
        end
    end
)

local function GetMinimumPreservedCharge(player, itemID)
	local pr = 0
	local cfg = Isaac.GetItemConfig():GetCollectible(itemID)
	local chargeType = cfg.ChargeType

	if chargeType == ItemConfig.CHARGE_NORMAL then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT) then
			pr = pr + 1
		end
		if REPENTOGON and player:HasCollectible(AstroItems.Collectible.MY_MOON_MY_MAN) and AstroItems.MaidDuetBlackListsCharges[itemID] then
			pr = pr + 2
		end
	elseif chargeType == ItemConfig.CHARGE_TIMED then
	elseif chargeType == ItemConfig.CHARGE_SPECIAL then
	end
	return pr
end

---@param player EntityPlayer
function AstroItems:PlayerUpdate_MaidDuet(player)
    if not player:HasCollectible(AstroItems.Collectible.MY_MOON_MY_MAN) then
        return
    end
    
    local data = player:GetData()

    if not data.wakaba then
        data.wakaba = {}
    end

    local lastPlayer = data.wakaba.lastmaidplayertype
    if lastPlayer and lastPlayer ~= player:GetPlayerType() then
        player:AddCollectible(
            data.wakaba.lastmaidpocketitem,
            data.wakaba.lastmaidpocketcharge or 0,
            false,
            ActiveSlot.SLOT_POCKET
        )
        isc:setActiveItem(
            player,
            data.wakaba.lastmaidpocketitem,
            ActiveSlot.SLOT_POCKET,
            data.wakaba.lastmaidpocketcharge or 0
        )
        if REPENTOGON then
            local a = player:GetActiveItemDesc(ActiveSlot.SLOT_POCKET)
            --a.Item = data.wakaba.lastmaidpocketitem
            --a.Charge = data.wakaba.lastmaidcharge
            --a.BatteryCharge = data.wakaba.lastmaidbatterycharge
            a.PartialCharge = data.wakaba.lastmaidpartialcharge
            a.VarData = data.wakaba.lastmaidvardata
        end
        data.wakaba.lastmaidplayertype = player:GetPlayerType()
    end

    for i = 0, 2 do
        local itemID = player:GetActiveItem(i)
        if
            AstroItems.MaidDuetBlackListsCharges[itemID] and
                player:GetActiveCharge(i) < GetMinimumPreservedCharge(player, itemID)
         then
            player:SetActiveCharge(GetMinimumPreservedCharge(player, itemID), i)
        end
    end

    if player.ControlsEnabled then
        --TODO 설정 가능 옵션으로 교체
        if
            (player.ControllerIndex == 0 and Input.IsButtonTriggered(swapKey, player.ControllerIndex)) or
                (player.ControllerIndex > 0 and Controller and
                    Input.IsButtonPressed(Controller.STICK_RIGHT, player.ControllerIndex) and
                    Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex))
         then
            if canUseMaidDuet(player) then
                local duetPower = player:GetCollectibleNum(AstroItems.Collectible.MY_MOON_MY_MAN)
                local config = Isaac.GetItemConfig()

                local firstActive = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
                local firstConfig = config:GetCollectible(firstActive)
                local firstCharge =
                    player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + player:GetBatteryCharge(ActiveSlot.SLOT_PRIMARY)

                local firstVarData
                local firstPartialCharge

                local extraFirstCharge = 0
                if firstConfig:IsCollectible() then
                    if firstConfig.ChargeType == ItemConfig.CHARGE_TIMED then
                        extraFirstCharge = (firstConfig.MaxCharges * (duetPower - 1)) // 10
                    elseif firstConfig.ChargeType == ItemConfig.CHARGE_TIMED then
                        extraFirstCharge = duetPower - 1
                    end
                end

                local secondActive = player:GetActiveItem(ActiveSlot.SLOT_POCKET)
                local secondCharge = 0
                local extraSecondCharge = 0

                local secondVarData
                local secondPartialCharge
                if secondActive ~= 0 then
                    local secondConfig = config:GetCollectible(secondActive)
                    secondCharge =
                        player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
                    if secondConfig:IsCollectible() then
                        if secondConfig.ChargeType == ItemConfig.CHARGE_TIMED then
                            extraSecondCharge = (secondConfig.MaxCharges * (duetPower - 1)) // 10
                        elseif secondConfig.ChargeType == ItemConfig.CHARGE_TIMED then
                            extraSecondCharge = duetPower - 1
                        end
                    end
                end

                if REPENTOGON then
                    local prDesc = player:GetActiveItemDesc(ActiveSlot.SLOT_PRIMARY)
                    firstPartialCharge = prDesc.PartialCharge
                    firstVarData = prDesc.VarData

                    local poDesc = player:GetActiveItemDesc(ActiveSlot.SLOT_POCKET)
                    secondPartialCharge = poDesc.PartialCharge
                    secondVarData = poDesc.VarData
                end

                isc:setActiveItem(player, firstActive, ActiveSlot.SLOT_POCKET, firstCharge + extraFirstCharge)
                isc:setActiveItem(player, secondActive, ActiveSlot.SLOT_PRIMARY, secondCharge + extraSecondCharge)
                if REPENTOGON then
                    local prDesc = player:GetActiveItemDesc(ActiveSlot.SLOT_PRIMARY)
                    local poDesc = player:GetActiveItemDesc(ActiveSlot.SLOT_POCKET)
                    poDesc.VarData = firstVarData or 0
                    poDesc.PartialCharge = firstPartialCharge or 0
                    prDesc.VarData = secondVarData or 0
                    prDesc.PartialCharge = secondPartialCharge or 0
                end

                SFXManager():Play(SoundEffect.SOUND_DIVINE_INTERVENTION)

                player:AnimateCollectible(AstroItems.Collectible.MY_MOON_MY_MAN, "HideItem")
                -- player:GetEffects():AddCollectibleEffect(AstroItems.Collectible.UNTITLED)
                data.wakaba.lastmaidplayertype = player:GetPlayerType()
                data.wakaba.lastmaidpocketitem = player:GetActiveItem(ActiveSlot.SLOT_POCKET)

                if not AstroItems:IsDavidMartinez(player) then
                    player:RemoveCollectible(AstroItems.Collectible.MY_MOON_MY_MAN)
                end
            else
                SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
            end
        end
    end
    data.wakaba.lastmaidpocketcharge =
        player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
    if REPENTOGON then
        local a = player:GetActiveItemDesc(ActiveSlot.SLOT_POCKET)
        --data.wakaba.lastmaidpocketitem = a.Item
        --data.wakaba.lastmaidcharge = a.Charge
        --data.wakaba.lastmaidbatterycharge = a.BatteryCharge
        data.wakaba.lastmaidpartialcharge = a.PartialCharge
        data.wakaba.lastmaidvardata = a.VarData
    end
end
AstroItems:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, AstroItems.PlayerUpdate_MaidDuet)

-- -- TODO 패밀리어 기능으로 교체
-- function AstroItems:RoomClear_MaidDuet()
--     for i = 1, Game():GetNumPlayers() do
--         local player = Isaac.GetPlayer(i - 1)
    
--         if player:GetEffects():HasCollectibleEffect(AstroItems.Collectible.UNTITLED) then
--             player:GetEffects():RemoveCollectibleEffect(AstroItems.Collectible.UNTITLED, -1)
--         end
--     end
-- end
-- AstroItems:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, AstroItems.RoomClear_MaidDuet)
-- AstroItems:AddCallbackCustom(isc.ModCallbackCustom.POST_GREED_MODE_WAVE, AstroItems.RoomClear_MaidDuet)

local function GetAllMainPlayers()
	local mainPlayers = {}
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		-- Make sure this player isn't the non-main twin, or an item-related spawned-in player like strawman.
		if player and player:Exists() and GetPtrHash(player:GetMainTwin()) == GetPtrHash(player)
				and (not player.Parent or player.Parent.Type ~= EntityType.ENTITY_PLAYER) then
			table.insert(mainPlayers, player)
		end
	end
	return mainPlayers
end

if EID then
    local HotkeyToString = {}
    for key, num in pairs(Keyboard) do
        local keyString = key
        local keyStart, keyEnd = string.find(keyString, "KEY_")
        keyString = string.sub(keyString, keyEnd + 1, string.len(keyString))
        keyString = string.gsub(keyString, "_", " ")
        HotkeyToString[num] = keyString
    end
    --convert controller enum to buttons
    local ControllerToString = {
        [0] = "{{ButtonDLeft}}",
        "{{ButtonDRight}}",
        "{{ButtonDUp}}",
        "{{ButtonDDown}}",
        "{{ButtonA}}",
        "{{ButtonB}}",
        "{{ButtonX}}",
        "{{ButtonY}}",
        "{{ButtonLB}}",
        "{{ButtonLT}}",
        "{{ButtonLStick}}",
        "{{ButtonRB}}",
        "{{ButtonRT}}",
        "{{ButtonRStick}}",
        "{{ButtonSelect}}",
        "{{ButtonMenu}}"
    }

    EID.descriptions["ko_kr"].MaidDuetBlacklisted = "!!! {{Collectible"..AstroItems.Collectible.MY_MOON_MY_MAN.."}}My Moon My Man으로 교체 불가"

    local function CaramellaCondition(descObj)
        if descObj.ObjType == 5 and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE then
            return true
        end
        return false
    end
    local function CaramellaCallback(descObj)
        if descObj.ObjSubType == AstroItems.Collectible.MY_MOON_MY_MAN then
            local controllerEnabled = #GetAllMainPlayers() > 0
            local maidKey = HotkeyToString[swapKey]
            local maidButton = controllerEnabled and ControllerToString[ButtonAction.ACTION_DROP]

            local append = ""
            if maidKey and maidButton then
                append = append .. maidKey .. "/{{ButtonLStick}}+" .. maidButton
            else
                append = append .. (maidKey or maidButton)
            end
            descObj.Description = descObj.Description:gsub("{wakaba_md1}", append)
        elseif AstroItems.MaidDuetBlackLists[descObj.ObjSubType] then
            local append =
                EID:getDescriptionEntry("MaidDuetBlacklisted") or EID:getDescriptionEntryEnglish("MaidDuetBlacklisted")
            descObj.Description = descObj.Description .. "#" .. append
        end
        return descObj
    end
    EID:addDescriptionModifier("AstroItemsMyMoonMyMan", CaramellaCondition, CaramellaCallback)
end

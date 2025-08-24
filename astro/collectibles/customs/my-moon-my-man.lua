local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.MY_MOON_MY_MAN = Isaac.GetItemIdByName("My Moon My Man")
Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.MY_MOON_MY_MAN,
                "나의 달 나의 그대",
                "이대로 네 집에 계속 머물고 싶어",
                "!!! 효과가 발동된 후 이 아이템은 사라집니다." ..
                "#{wakaba_md1} 키로 소지중인 액티브 아이템과 카드/알약 슬롯 액티브 아이템을 교체합니다." ..
                "#{{ArrowGrayRight}} 카드/알약 슬롯이 비어있을 경우 액티브 아이템을 그 슬롯으로 옮깁니다." ..
                "#{{ArrowGrayRight}} 일부 아이템은 카드/알약 슬롯으로 옮길 수 없습니다." ..
                "#!!! 캐릭터 변경 시 카드/알약 슬롯의 액티브 아이템은 사라집니다."
            )

            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.MY_MOON_MY_MAN),
                { Astro.Players.DAVID_MARTINEZ, Astro.Players.DAVID_MARTINEZ_B },
                {
                    "!!! 효과가 발동된 후 이 아이템은 사라집니다.#",
                    ""
                },
                nil, "ko_kr", nil
            )
        end
    end
)

-- 아이템 위치 바꾸는 키
local SWAP_KEY = Keyboard.KEY_8

local ADDED_SOUND = Isaac.GetSoundIdByName('MyMoonMyMan')
local ADDED_SOUND_VOULME = 1 -- 0 ~ 1

Astro.MaidDuetBlackLists = {
    [CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE] = true,
    [CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES] = true,
    [CollectibleType.COLLECTIBLE_D_INFINITY] = true,
    [CollectibleType.COLLECTIBLE_BLANK_CARD] = true,
    [CollectibleType.COLLECTIBLE_PLACEBO] = true,
    [CollectibleType.COLLECTIBLE_CLEAR_RUNE] = true,
    -- 밸런스 문제로 REPENTOGON 여부 상관 없이 제외합니다.
    [CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = true,
    [CollectibleType.COLLECTIBLE_JAR_OF_WISPS] = true,
}
Astro.MaidDuetBlackListsCharges = {
    [CollectibleType.COLLECTIBLE_EVERYTHING_JAR] = true,
    [CollectibleType.COLLECTIBLE_WOODEN_NICKEL] = true,
    [CollectibleType.COLLECTIBLE_BREATH_OF_LIFE] = true,
    [CollectibleType.COLLECTIBLE_NOTCHED_AXE] = true
}

Astro.MaidDuetBlackListsPlayers = {
    [PlayerType.PLAYER_CAIN_B] = true
}
if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_POST_MODS_LOADED,
        function()
            if _wakaba then
                -- 랜덤보스의 경우 와카바 모드의 리스트를 그대로 사용. 에피파니 등 추가 모드 호환을 위한 조치
                Astro.MaidDuetBlackLists = wakaba.Blacklists.MaidDuet
                Astro.MaidDuetBlackListsCharges = wakaba.Blacklists.MaidDuetCharges
                Astro.MaidDuetBlackListsPlayers = wakaba.Blacklists.MaidDuetPlayers
            end
        end
    )
end

---@param player EntityPlayer
local function canUseMyMoon(player, force)
    local active1 = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
    local active2 = player:GetActiveItem(ActiveSlot.SLOT_POCKET)
    local extraCond = Isaac.RunCallback(Astro.Callbacks.EVALUATE_MY_MOON, player)
    return active1 > 0 and not Astro.MaidDuetBlackLists[active1] and not Astro.MaidDuetBlackLists[active2] and
        not extraCond -- and
        -- (force or not player:GetEffects():HasCollectibleEffect(Astro.Collectible.UNTITLED))
end

Astro:AddCallback(
    Astro.Callbacks.EVALUATE_MY_MOON,
    ---@param player EntityPlayer
    function(_, player)
        if Astro.MaidDuetBlackListsPlayers[player:GetPlayerType()] then
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
		if REPENTOGON and player:HasCollectible(Astro.Collectible.MY_MOON_MY_MAN) and Astro.MaidDuetBlackListsCharges[itemID] then
			pr = pr + 2
		end
	elseif chargeType == ItemConfig.CHARGE_TIMED then
	elseif chargeType == ItemConfig.CHARGE_SPECIAL then
	end
	return pr
end

---@param player EntityPlayer
function Astro:PlayerUpdate_MyMoon(player)
    if not player:HasCollectible(Astro.Collectible.MY_MOON_MY_MAN) then
        return
    end
    
    local data = player:GetData()

    if not data.astro then
        data.astro = {}
    end

    local lastPlayer = data.astro.lastmoonplayertype
    -- 해당 블록은 캐릭터 교체 시 교체한 액티브가 바뀌는 걸 방지하는 용도. 불필요 시 삭제 요망
    if lastPlayer and lastPlayer ~= player:GetPlayerType() then
        player:AddCollectible(
            data.astro.lastmoonpocketitem,
            data.astro.lastmoonpocketcharge or 0,
            false,
            ActiveSlot.SLOT_POCKET
        )
        isc:setActiveItem(
            player,
            data.astro.lastmoonpocketitem,
            ActiveSlot.SLOT_POCKET,
            data.astro.lastmoonpocketcharge or 0
        )
        if REPENTOGON then
            local a = player:GetActiveItemDesc(ActiveSlot.SLOT_POCKET)
            --a.Item = data.astro.lastmoonpocketitem
            --a.Charge = data.astro.lastmooncharge
            --a.BatteryCharge = data.astro.lastmoonbatterycharge
            a.PartialCharge = data.astro.lastmoonpartialcharge
            a.VarData = data.astro.lastmoonvardata
        end
        data.astro.lastmoonplayertype = player:GetPlayerType()
    end

    for i = 0, 2 do
        local itemID = player:GetActiveItem(i)
        if
            Astro.MaidDuetBlackListsCharges[itemID] and
                player:GetActiveCharge(i) < GetMinimumPreservedCharge(player, itemID)
         then
            player:SetActiveCharge(GetMinimumPreservedCharge(player, itemID), i)
        end
    end

    if player.ControlsEnabled then
        --TODO 설정 가능 옵션으로 교체
        if
            (player.ControllerIndex == 0 and Input.IsButtonTriggered(SWAP_KEY, player.ControllerIndex)) --[[ or
                (player.ControllerIndex > 0 and Controller and
                    Input.IsButtonPressed(Controller.STICK_RIGHT, player.ControllerIndex) and
                    Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)) ]]
         then
            if canUseMyMoon(player) then
                local duetPower = player:GetCollectibleNum(Astro.Collectible.MY_MOON_MY_MAN)
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

                player:AnimateCollectible(Astro.Collectible.MY_MOON_MY_MAN, "HideItem")
                -- player:GetEffects():AddCollectibleEffect(Astro.Collectible.UNTITLED)
                data.astro.lastmoonplayertype = player:GetPlayerType()
                data.astro.lastmoonpocketitem = player:GetActiveItem(ActiveSlot.SLOT_POCKET)

                if not Astro:IsDavidMartinez(player) then
                    player:RemoveCollectible(Astro.Collectible.MY_MOON_MY_MAN)
                end
            else
                SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
            end
        end
    end
    data.astro.lastmoonpocketcharge =
        player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
    if REPENTOGON then
        local a = player:GetActiveItemDesc(ActiveSlot.SLOT_POCKET)
        --data.astro.lastmoonpocketitem = a.Item
        --data.astro.lastmooncharge = a.Charge
        --data.astro.lastmoonbatterycharge = a.BatteryCharge
        data.astro.lastmoonpartialcharge = a.PartialCharge
        data.astro.lastmoonvardata = a.VarData
    end
end
Astro:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Astro.PlayerUpdate_MyMoon)

-- -- TODO 패밀리어 기능으로 교체
-- function Astro:RoomClear_MyMoon()
--     for i = 1, Game():GetNumPlayers() do
--         local player = Isaac.GetPlayer(i - 1)
    
--         if player:GetEffects():HasCollectibleEffect(Astro.Collectible.UNTITLED) then
--             player:GetEffects():RemoveCollectibleEffect(Astro.Collectible.UNTITLED, -1)
--         end
--     end
-- end
-- Astro:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Astro.RoomClear_MyMoon)
-- Astro:AddCallbackCustom(isc.ModCallbackCustom.POST_GREED_MODE_WAVE, Astro.RoomClear_MyMoon)

Astro:AddCallback(
	ModCallbacks.MC_PRE_PICKUP_COLLISION,
	---@param entityPickup EntityPickup
	---@param collider Entity
	---@param low boolean
	function(_, entityPickup, collider, low)
        if collider:ToPlayer() and entityPickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and entityPickup.SubType == Astro.Collectible.MY_MOON_MY_MAN then
            Astro:ScheduleForUpdate(
                function()
                    SFXManager():Stop(SoundEffect.SOUND_CHOIR_UNLOCK)
                end,
                1
            )
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.PRE_ITEM_PICKUP,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        SFXManager():Play(ADDED_SOUND, ADDED_SOUND_VOULME)
    end,
    ItemType.ITEM_PASSIVE,
    Astro.Collectible.MY_MOON_MY_MAN
)

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

    EID.descriptions["ko_kr"].MyMoonBlacklisted = "!!! {{Collectible"..Astro.Collectible.MY_MOON_MY_MAN.."}} My Moon My Man: 픽업 슬롯으로 옮길 수 없음"

    local function MyMoonCondition(descObj)
        if descObj.ObjType == 5 and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE then
            return true
        end
        return false
    end
    local function MyMoonCallback(descObj)
        if descObj.ObjSubType == Astro.Collectible.MY_MOON_MY_MAN then
            local controllerEnabled = #GetAllMainPlayers() > 0
            local moonKey = HotkeyToString[SWAP_KEY]
            --local moonButton = controllerEnabled and ControllerToString[ButtonAction.ACTION_DROP]

            local append = ""
            if moonKey then
                append = append .. moonKey
            end
            --[[
            if moonKey and moonButton then
                append = append .. moonKey .. "/{{ButtonLStick}}+" .. moonButton
            else
                append = append .. (moonKey or moonButton)
            end
            ]]
            descObj.Description = descObj.Description:gsub("{wakaba_md1}", append)
        elseif Astro.MaidDuetBlackLists[descObj.ObjSubType] and EID:getLanguage() == "ko_kr" then
            -- 아이템 소지 시에만 설명 등장, 항상 등장하게 하려면 if 조건 제거
            if isc:anyPlayerHasCollectible(Astro.Collectible.MY_MOON_MY_MAN) then
                local append =
                -- TODO 아직 Astro 모드에 영어 설명이 없으므로 EID 언어가 한글일 때만 출력.
                    EID:getDescriptionEntry("MyMoonBlacklisted") -- or EID:getDescriptionEntryEnglish("MyMoonBlacklisted")
                descObj.Description = descObj.Description .. "#" .. append
            end
        end
        return descObj
    end
    EID:addDescriptionModifier("AstroItemsMyMoonMyMan", MyMoonCondition, MyMoonCallback)
end

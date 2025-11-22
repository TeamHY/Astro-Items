Astro.Collectible.QUBIT_DICE = Isaac.GetItemIdByName("Qubit Dice")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.QUBIT_DICE,
                "양자 주사위",
                "-3 ~ +3",
                "사용 시 그 방의 아이템을:" ..
                "#{{ArrowGrayRight}} {{Collectible723}} 코드 1~3번 앞의 번호의 아이템으로 바꾸거나;" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.SPINUP_DICE .. "}} 코드 1~3번 뒤의 번호의 아이템으로 바꿉니다." ..
                "#!!! 일부 아이템은 등장하지 않습니다."
            )
        end
    end
)

local function SpindownModifierConfition(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 100 and Astro:HasCollectible(Astro.Collectible.QUBIT_DICE) then
        local numPlayers = Game():GetNumPlayers()
        for i = 0, numPlayers - 1 do
            if
                not (Isaac.GetPlayer(i):HasCollectible(CollectibleType.COLLECTIBLE_SPINDOWN_DICE) or
                    (EID.absorbedItems[tostring(i)] and
                        EID.absorbedItems[tostring(i)][tostring(CollectibleType.COLLECTIBLE_SPINDOWN_DICE)]))
             then
                return true
            end
        end
    end
end

local function SpindownModifierCallback(descObj)
    -- don't display in item reminder, or if we've already printed it earlier in the desc
    if EID.InsideItemReminder or string.match(descObj.Description, "#{{Collectible723}} :") then
        return descObj
    end
    -- get the ID of the player that owns the Spindown Dice
    local playerID = 0
    EID:appendToDescription(descObj, "#{{Collectible723}} :")
    local refID = descObj.ObjSubType
    local hasCarBattery = Isaac.GetPlayer(playerID):HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
    local firstID = 0
    for i = 1, EID.Config["SpindownDiceResults"] do
        local spinnedID = EID:getSpindownResult(refID)
        if hasCarBattery and spinnedID ~= 668 then
            refID = spinnedID
            spinnedID = EID:getSpindownResult(refID)
        end
        refID = spinnedID
        if refID > 0 and refID < 4294960000 then
            if i == 1 then
                firstID = refID
            end
            EID:appendToDescription(descObj, "{{Collectible" .. refID .. "}}")
            if EID.itemUnlockStates[refID] == false then
                EID:appendToDescription(descObj, "?")
            end
            if EID.Config["SpindownDiceDisplayID"] then
                EID:appendToDescription(descObj, "/" .. refID)
            end
            if EID.Config["SpindownDiceDisplayName"] then
                EID:appendToDescription(descObj, "/" .. EID:getObjectName(5, 100, refID))
                if refID == 668 then
                    break
                end
                if i ~= EID.Config["SpindownDiceResults"] then
                    EID:appendToDescription(descObj, "#{{Blank}}")
                end
            end

            if refID == 668 then
                break
            end -- Dad's Note is not affected by Spindown Dice
            if i ~= EID.Config["SpindownDiceResults"] then
                EID:appendToDescription(descObj, " ->")
            end
        else
            local errorMsg = EID:getDescriptionEntry("spindownError") or ""
            EID:appendToDescription(descObj, errorMsg)
            break
        end
    end
    if hasCarBattery then
        EID:appendToDescription(
            descObj,
            " " .. EID:ReplaceVariableStr(EID:getDescriptionEntry("ResultsWithX"), 1, "{{Collectible356}}")
        )
    end
    if firstID ~= 0 and EID.TabPreviewID == 0 then
        EID.TabPreviewID = firstID
        EID:appendToDescription(descObj, "#{{Blank}} " .. EID:getDescriptionEntry("FlipItemToggleInfo"))
    end
    return descObj
end

if EID and EID.Config["SpindownDiceResults"] > 0 then
    EID:addDescriptionModifier("Spindown Modifier", SpindownModifierConfition, SpindownModifierCallback)
    -- spinup-dice.lua에 추가 코드 있음
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local stringUp, stringDown = "Spinup", "Spindown"
        if Options.Language == "kr" or REPKOR then
            stringUp, stringDown = "스핀업", "스핀다운"
        end
        
        local number = rngObj:RandomInt(3) + 1
        if rngObj:RandomFloat() < 0.5 then
            for _ = 1, rngObj:RandomInt(3) + 1 do
                playerWhoUsedItem:UseActiveItem(Astro.Collectible.SPINUP_DICE, false)
            end

            Game():GetHUD():ShowFortuneText("+" .. number, stringUp)
        else
            for _ = 1, rngObj:RandomInt(3) + 1 do
                playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_SPINDOWN_DICE, false)
            end

            Game():GetHUD():ShowFortuneText("-" .. number, stringDown)
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.QUBIT_DICE
)

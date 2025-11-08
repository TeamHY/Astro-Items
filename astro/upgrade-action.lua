---

local LEFT_CTRL_HOLD_DURATION = 30

---

local dropActionPressTime = 0

---@type {condition: fun(player: EntityPlayer): table? | boolean, action: fun(player: EntityPlayer, data: table?)}[]
local upgradeActions = {}

---@param conditionFunc fun(player: EntityPlayer): table? | boolean
---@param actionFunc fun(player: EntityPlayer, data: table?)
function Astro:AddUpgradeAction(conditionFunc, actionFunc)
    table.insert(
        upgradeActions,
        {
            condition = conditionFunc,
            action = actionFunc
        }
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        local input = Input.GetActionValue(ButtonAction.ACTION_DROP, 0)

        if input > 0 then
            dropActionPressTime = dropActionPressTime + 1

            if dropActionPressTime >= LEFT_CTRL_HOLD_DURATION * 2 then
                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)

                    for _, upgradeAction in ipairs(upgradeActions) do
                        local data = upgradeAction.condition(player)

                        if data ~= nil then
                            upgradeAction.action(player, data)
                            dropActionPressTime = 0
                            break
                        end
                    end
                end
            end
        else
            dropActionPressTime = 0
        end
    end
)

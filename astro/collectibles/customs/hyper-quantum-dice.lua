Astro.Collectible.HYPER_QUANTUM_DICE = Isaac.GetItemIdByName("Hyper Quantum Dice")

local ITEM_ID = Astro.Collectible.HYPER_QUANTUM_DICE

---

local SPIN_AMOUNTS = { -3, -2, -1, 1, 2, 3 }

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "초양자 주사위",
                "-3 ~ +3 선택",
                "사용 시 {{ColorOrange}}-3 ~ +3 중 하나를 골라{{CR}} 그 방의 아이템을 그만큼 앞/뒤 코드의 아이템으로 바꿉니다." ..
                "#!!! 일부 아이템은 등장하지 않습니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Hyper Quantum Dice",
                "",
                "When used, {{ColorOrange}}choose -3 ~ +3{{CR}} and reroll items in the room by that many IDs" ..
                "#!!! Some items cannot appear",
                nil,
                "en_us"
            )
        end
    end
)

Astro.MegaUI:CreateInstance({
    anm2Path = "gfx/ui/hyper-quantum-dice-ui.anm2",
    choiceCount = #SPIN_AMOUNTS,
    itemId = ITEM_ID,
    onChoiceSelected = function(player, choice)
        local amount = SPIN_AMOUNTS[choice]
        local dice = amount > 0 and Astro.Collectible.SPINUP_DICE or CollectibleType.COLLECTIBLE_SPINDOWN_DICE

        for _ = 1, math.abs(amount) do
            player:UseActiveItem(dice, UseFlag.USE_NOANIM)
        end
    end
})

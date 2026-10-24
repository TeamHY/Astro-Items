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
                "-3 ~ +3 중에서 골라",
                "사용 시 그 방의 아이템을 코드 1~3번 앞/뒷번호의 아이템으로 바꿉니다." ..
                "#!!! 해금하지 않은 아이템과 현재 게임에서 등장할 수 없는 아이템은 등장하지 않습니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Hyper Quantum Dice", "",
                "Rerolls all items in the room by shifting their internal IDs by a randomly chosen value from -3 to +3",
                nil, "en_us"
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

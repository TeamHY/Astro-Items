Astro.Collectible.ANOREXIA_NERVOSA = Isaac.GetItemIdByName("Anorexia Nervosa")

local FOOD_ITEMS = {
    CollectibleType.COLLECTIBLE_LUNCH,
    CollectibleType.COLLECTIBLE_DINNER,
    CollectibleType.COLLECTIBLE_DESSERT,
    CollectibleType.COLLECTIBLE_BREAKFAST,
    CollectibleType.COLLECTIBLE_MARROW,
    CollectibleType.COLLECTIBLE_MIDNIGHT_SNACK,
    CollectibleType.COLLECTIBLE_CRACK_JACKS,
    CollectibleType.COLLECTIBLE_ROTTEN_MEAT,
    CollectibleType.COLLECTIBLE_SNACK,
    CollectibleType.COLLECTIBLE_SUPPER,
}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ANOREXIA_NERVOSA,
                "거식증",
                "식욕이 없어요...",
                "음식 관련 {{Heart}}최대 체력 증가 아이템이 등장하지 않습니다."
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.ANOREXIA_NERVOSA) and Astro:FindIndex(FOOD_ITEMS, selectedCollectible) ~= -1 then
                    return {
                        reroll = true,
                        modifierName = "Anorexia Nervosa"
                    }
                end

                return false
            end
        )
    end
)

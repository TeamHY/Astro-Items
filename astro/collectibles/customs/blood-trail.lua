---

local MAX_GIVE_COUNT = 2

---

Astro.Collectible.BLOOD_TRAIL = Isaac.GetItemIdByName("Blood Trail")


Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BLOOD_TRAIL,
                "블러드 트레일",
                "믿으라구!",
                "!!! 최초 획득 시 {{Collectible73}}Cube of Meat 2개 획득" ..
                "#{{Collectible73}} 스테이지 진입 시 Cube of Meat를 획득합니다." ..
                "#!!! 획득량: ({{Collectible" .. Astro.Collectible.BLOOD_TRAIL .. "}}개수+{{Collectible" .. Astro.Collectible.BANDAGE_GIRL .. "}}개수)개"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.BLOOD_TRAIL) then
                for _ = 1 , player:GetCollectibleNum(Astro.Collectible.BLOOD_TRAIL) + player:GetCollectibleNum(Astro.Collectible.BANDAGE_GIRL) do
                    player:AddCollectible(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT)
                end
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.BLOOD_TRAIL) then
            for _ = 1 , MAX_GIVE_COUNT - player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT) do
                player:AddCollectible(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT)
            end
        end
    end,
    Astro.Collectible.BLOOD_TRAIL
)

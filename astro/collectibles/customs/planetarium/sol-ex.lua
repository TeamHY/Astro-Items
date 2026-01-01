local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SOL_EX = Isaac.GetItemIdByName("SOL EX")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.SOL_EX,
        "초 태양",
        "광나는 승리",
        "!!! 획득 이후 {{Collectible588}}Sol 미등장" ..
        "#{{BossRoom}} 맵에 보스방의 위치가 표시됩니다." ..
        "#{{Collectible588}} {{ColorOrange}}표시된 방의 보스 처치{{CR}}시 다음 효과 발동:" ..
        "#{{ArrowGrayRight}} {{Card20}}맵에 스테이지 구조, 특수방, 일반비밀방 위치 표시" ..
        "#{{ArrowGrayRight}} {{Heart}}체력을 모두 회복" ..
        "#{{ArrowGrayRight}} 그 스테이지에서 {{DamageSmall}}+3/{{LuckSmall}}+1" ..
        "#{{ArrowGrayRight}} {{CurseCursedSmall}}스테이지의 저주 제거" ..
        "#{{ArrowGrayRight}} {{Collectible633}}Dogma 획득" ..
        "#{{ArrowGrayRight}} 랜덤 장신구 소환" ..
        "#{{ArrowGrayRight}} {{Battery}}액티브 아이템의 충전량을 모두 채워줍니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()
        local itemPool = Game():GetItemPool()

        if currentRoom:GetType() == RoomType.ROOM_BOSS then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(Astro.Collectible.SOL_EX) then
                    for _ = 1, player:GetCollectibleNum(Astro.Collectible.SOL_EX) do
                        if not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) then
                            player:AddCollectible(CollectibleType.COLLECTIBLE_DOGMA)
                        end
    
                        -- for _ = 1, 2 do
                            Astro:SpawnTrinket(itemPool:GetTrinket(), player.Position)
                        -- end
                    end
                end
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
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SOL)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SOL) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SOL)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    Astro.Collectible.SOL_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SOL) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SOL)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    Astro.Collectible.SOL_EX
)

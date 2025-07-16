---

local BASE_CHANCE = 0.5

local LUCK_CHANCE = 0.01

---

Astro.Collectible.MAYUSHIIS_POCKET_WATCH = Isaac.GetItemIdByName("Mayushii's Pocket Watch")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.MAYUSHIIS_POCKET_WATCH,
        "마유시의 회중시계",
        "...",
        "패널티 피격 시 50% 확률로 {{Collectible422}}Glowing Hourglass가 발동됩니다. 클리어 상태인 방과 {{BossRoom}}보스방에서는 발동하지 않습니다." ..
        "#중첩 시 최종 확률이 합 연산으로 증가합니다." ..
        "#!!! {{LuckSmall}}행운 수치 비례: 행운 50 이상일 때 100% 확률 (행운 1당 +1%p)"
    )
end

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.MAYUSHIIS_POCKET_WATCH) then
            return
        end

        local room = Game():GetRoom()
        
        if room:IsClear() then
            return
        end
        
        if room:GetType() == RoomType.ROOM_BOSS then
            return
        end

        local data = Astro.SaveManager.GetRunSave(player, true)

        if not data["mayushiisPocketWatchRNG"] then
            data["mayushiisPocketWatchRNG"] = Astro:CopyRNG(player:GetCollectibleRNG(Astro.Collectible.MAYUSHIIS_POCKET_WATCH))
        end

        local rng = data["mayushiisPocketWatchRNG"]
        local itemCount = player:GetCollectibleNum(Astro.Collectible.MAYUSHIIS_POCKET_WATCH)
        
        if rng:RandomFloat() < (BASE_CHANCE + player.Luck * LUCK_CHANCE) * itemCount then
            player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end
    end
) 

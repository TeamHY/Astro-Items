---

local ACTIVATION_DELAY = 120

---

Astro.Collectible.URINARY_INCONTINENCE = Isaac.GetItemIdByName("Urinary Incontinence")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.URINARY_INCONTINENCE,
        "요실금",
        "...",
        "전투 중일 때 4초마다 {{Collectible578}}Free Lemonade가 발동됩니다." ..
        "#몬스터 처치 시 {{Collectible56}}Lemon Mishap이 발동됩니다." ..
        "#중첩 시 방 내에서 {{Collectible56}}Lemon Mishap 발동 횟수가 증가합니다."
    )
end

local remainingMishaps = 0

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local itemCount = player:GetCollectibleNum(Astro.Collectible.URINARY_INCONTINENCE)
            
            if itemCount > 0 then
                remainingMishaps = itemCount
            end
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.URINARY_INCONTINENCE) and 
               remainingMishaps > 0 and 
               entityNPC.Type ~= EntityType.ENTITY_FIREPLACE then
                
                player:UseActiveItem(CollectibleType.COLLECTIBLE_LEMON_MISHAP, false)
                remainingMishaps = remainingMishaps - 1
                break
            end
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.URINARY_INCONTINENCE) then
            local frameCount = Game():GetFrameCount()
            local room = Game():GetRoom()
            

            if not room:IsClear() and frameCount % ACTIVATION_DELAY == 0 then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_FREE_LEMONADE, false)
            end
        end
    end
)

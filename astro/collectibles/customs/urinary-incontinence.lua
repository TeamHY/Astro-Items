---

local ACTIVATION_DELAY = 450

---

Astro.Collectible.URINARY_INCONTINENCE = Isaac.GetItemIdByName("Urinary Incontinence")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.URINARY_INCONTINENCE,
                "요실금",
                "골든 샤워",
                "{{Collectible578}} 방에 적이 있을 때 15초마다 캐릭터의 주위에 커다란 노란 장판이 생깁니다." ..
                "#{{Collectible56}} 몬스터 처치 시 캐릭터의 주위에 노란 장판을 생성합니다." ..
                "#{{ArrowGrayRight}} 두 장판은 지상 위의 적에게 초당 24의 피해를 줍니다.",
                -- 중첩 시
                "중첩 시 중첩된 수만큼 노란 장판 생성"
            )
        end
    end
)

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

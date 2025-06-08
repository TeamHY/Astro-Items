local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.WE_NEED_TO_GO_DEEPER_ASTRO = Isaac.GetItemIdByName("We Need To Go Deeper (Astro)")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.WE_NEED_TO_GO_DEEPER_ASTRO,
        "더 깊이 가야 해 (아스트로)",
        "...",
        "1회 사용: 멤버십 상점 소환#" ..
        "2회 사용: 장식 타일에서 함정문 소환#" ..
        "3회 사용: 스킵 문 소환#" ..
        "스테이지마다 사용 횟수 초기화"
    )
end

local function spawnMembershipShop(player, position)
    local room = Game():GetRoom()
    local gridIndex = room:GetGridIndex(position)

    local gridEntity = room:GetGridEntity(gridIndex)

    if gridEntity then
        gridEntity:Destroy()
    end
    
    Isaac.GridSpawn(18, 2, position, false)
end

local function spawnTrapdoor(player, position)
    local room = Game():GetRoom()
    local gridIndex = Isaac
    
    room:SpawnGridEntity(gridIndex, 17, 0, 0, 0)
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleType CollectibleType
    ---@param rng RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleType, rng, player, useFlags, activeSlot, varData)
        local room = Game():GetRoom()
        local position = player.Position
        
        local gridIndex = room:GetGridIndex(position)
        local gridEntity = room:GetGridEntity(gridIndex)
        
        if gridEntity then
            if gridEntity:GetType() == isc.GridEntityType.DECORATION then
                spawnMembershipShop(player, position)

                return {
                    Discharge = true,
                    Remove = false,
                    ShowAnim = true
                }
            end
        end

        spawnTrapdoor(player, position)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.WE_NEED_TO_GO_DEEPER_ASTRO
)

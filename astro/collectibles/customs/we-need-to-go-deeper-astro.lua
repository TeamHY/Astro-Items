local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.WE_NEED_TO_GO_DEEPER_ASTRO = Isaac.GetItemIdByName("We Need To Go Deeper! (Astro)")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.WE_NEED_TO_GO_DEEPER_ASTRO,
        "더 깊이 가야 해 (아스트로)",
        "...",
        "사용 시 다음 스테이지로 갈 수 있는 다락문을 소환합니다." ..
        "#치장성 타일 위에서 사용 시 멤버십 상점이 소환됩니다."
    )
end




local function spawnMembershipShop(player, position)
    local room = Game():GetRoom()
    local gridIndex = room:GetGridIndex(room:FindFreePickupSpawnPosition(position, 0))

    local gridEntity = room:GetGridEntity(gridIndex)

    if gridEntity then
        gridEntity:Destroy()
    end
    
    Isaac.GridSpawn(18, 2, position, true)
end

local function spawnTrapdoor(player, position)
    local room = Game():GetRoom()
    local gridIndex = room:GetGridIndex(room:FindFreePickupSpawnPosition(position, 0))
    
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

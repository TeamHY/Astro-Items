Astro.Collectible.LANIAKEA_SUPERCLUSTER = Isaac.GetItemIdByName("Laniakea Supercluster")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.LANIAKEA_SUPERCLUSTER,
        "라니아케아 초은하단",
        "헤아릴 수 없는 천국",
        "!!! 일회용" ..
        "#사용 시 {{Planetarium}}천체관으로 이동하며 {{Trinket152}}Telescope Lens와 Glitched Machine을 소환합니다.")
end

local flag = false

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        flag = true

        Isaac.ExecuteCommand("goto s.planetarium.0")

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.LANIAKEA_SUPERCLUSTER
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if flag then
            flag = false

            local room = Game():GetRoom()

            Astro:SpawnEntity(Astro.Entity.GlitchedMachine, room:GetCenterPos())
            Astro:SpawnTrinket(TrinketType.TRINKET_TELESCOPE_LENS, room:GetCenterPos())
        end
    end
)

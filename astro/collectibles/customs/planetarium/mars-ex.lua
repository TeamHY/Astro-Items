local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.MARS_EX = Isaac.GetItemIdByName("MARS EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.MARS_EX,
                "초 화성",
                "난폭한 돌진",
                "{{Collectible593}} Mars 효과 발동:" ..
                "#{{IND}} 이동키를 두번 누르면 누른 방향으로 돌진하여 접촉한 적에게 공격력 x4 +8의 피해를 줍니다." ..
                "#{{IND}}{{ArrowGrayRight}} 돌진 중 적 및 장애물에 부딪힐 시 주변의 적에게 10의 {{Burning}}화염 피해를 줍니다." ..
                "#{{IND}}{{TimerSmall}} (쿨타임 3초/{{Collectible130}}{{Collectible181}}1초)" ..
                "#패널티 피격 시 방마다 최대 1번 해당 피해를 무시한 후 즉시 돌진합니다.",
                -- 중첩 시
                "중첩 시 중첩된 수만큼 방당 최대 돌진 횟수 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.MARS_EX,
                "Mars EX", "",
                "{{Collectible593}} Mars effect applied:" ..
                "#{{IND}} Double-tapping a movement key makes Isaac dash" ..
                "#{{IND}}{{Damage}} During a dash, Isaac is invincible and deals 4x his damage +8" ..
                "#{{IND}}{{Timer}} 3 seconds cooldown" ..
                "#{{IND}}{{Burning}} Creates a ring of fire on impact" ..
                "#Taking damage is ignored once per room, then Isaac dash immediately",
                -- Stacks
                "Stackable",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.MARS_EX) then
                local data = player:GetData()

                if data.AstroMarsEX == nil then
                    data.AstroMarsEX = {
                        Count = 0
                    }
                end

                data.AstroMarsEX.Count = player:GetCollectibleNum(Astro.Collectible.MARS_EX)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player:HasCollectible(Astro.Collectible.MARS_EX) then
            local data = player:GetData()

            if data.AstroMarsEX.Count > 0 and damageFlags & (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS) == 0 then
                player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_MARS)
                data.AstroMarsEX.Count = data.AstroMarsEX.Count - 1

                return false
            end
        end
    end,
    EntityType.ENTITY_PLAYER
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_MARS)

        local data = player:GetData()

        if data.AstroMarsEX == nil then
            data.AstroMarsEX = {
                Count = 0
            }
        end

        data.AstroMarsEX.Count = player:GetCollectibleNum(Astro.Collectible.MARS_EX)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MARS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_MARS)
        end
    end,
    Astro.Collectible.MARS_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MARS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_MARS)
        end
    end,
    Astro.Collectible.MARS_EX
)

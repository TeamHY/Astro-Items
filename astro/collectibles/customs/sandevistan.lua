local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SANDEVISTAN = Isaac.GetItemIdByName("Sandevistan")
Astro:AddSoulItem(Astro.Collectible.SANDEVISTAN)

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SANDEVISTAN,
        "산데비스탄",
        "...",
        "적 처치 시 영혼을 흡수합니다. 사용 시 영혼을 소모해 아래의 효과를 얻습니다.#10개 - 유체이탈 효과#30개 - 유체이탈 효과, 순간적으로 높은 공격력과 연사#50개 - 유체이탈 효과, 순간적으로 높은 공격력과 연사, 10초간 무적#최대 100개까지 저장할 수 있습니다."
    )
end

local maxinum = 100

local lowPoint = 10

local middlePoint = 30

local highPoint = 50

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            Astro.Data["sandevistanSouls"] = 0
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.SOUL_COLLECTED,
    ---@param player EntityPlayer
    function(_, player)
        local data = Astro.Data

        Astro.Data["sandevistanSouls"] = Astro.Data["sandevistanSouls"] + 1

        if Astro.Data["sandevistanSouls"] > maxinum then
            Astro.Data["sandevistanSouls"] = maxinum
        end
    end
)

-- ✅액티브 아이템이며, 데이비드의 포켓 아이템입니다
-- ✅몬스터 처치 시 스택이 증가됩니다 (최대100)
-- ✅1단계(10스택) 에서 사용 시 유체이탈 효과가 발동됩니다
-- ✅2단계(30스택) 에서 사용 시 유체이탈 + 위장속옷 효과가 발동됩니다
-- ✅3단계(50스택) 에서 사용 시 유체이탈 + 위장속옷 + 배리어 효과가 발동됩니다
-- ✅쿨타임 수치는 추후 직접 수정할거라 테스트만 하시면 됩니다

-- ❗추후 변경될 수 있는 사항 (아래 요소들인 딸1깍으로 수정 가능하게 짜면 별도로 다시 밸런스 패치 요구할 확률이 많이 줄어듦)
-- ✅1,2,3단계 필요로하는 스택의 개수

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param item CollectibleType
    ---@param rng RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, item, rng, player, useFlags, activeSlot, varData)
        local discharge = true
        local remove = false
        local showAnim = false

        if not Astro.Data["sandevistanSouls"] or Astro.Data["sandevistanSouls"] < lowPoint then
            discharge = false
            return {
                Discharge = discharge,
                Remove = remove,
                ShowAnim = showAnim
            }
        end

        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION, "ASTRO_SANDEVISTAN") then
            discharge = false
            return {
                Discharge = discharge,
                Remove = remove,
                ShowAnim = showAnim
            }
        end
        --[[
     if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION) then
         discharge = false
         goto skipRiraUniform
     end
  ]]
        local clearFlag = false

        local room = Game():GetRoom()
        local level = Game():GetLevel()
        local currentRoomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
        if room:IsClear() then
            clearFlag = true
            if not currentRoomDesc.NoReward then
                currentRoomDesc.NoReward = true
            end
            room:SetClear(false)
        end

        hiddenItemManager:AddForRoom(player, CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION, 150, 1, "ASTRO_SANDEVISTAN")
        player:TakeDamage(
            1,
            DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_INVINCIBLE |
                DamageFlag.DAMAGE_FAKE,
            EntityRef(player),
            60
        )
        player:TakeDamage(
            1,
            DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_INVINCIBLE |
                DamageFlag.DAMAGE_FAKE,
            EntityRef(player),
            60
        )

        Astro:ScheduleForUpdate(
            function()
                local effects = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 10)
                for _, e in ipairs(effects) do
                    if e.Position:DistanceSquared(player.Position) <= 60 ^ 2 then
                        --  wakaba.Log("Forgotten Soul form Rira Uniform found, removing...")
                        e:Remove()
                    end
                end
                local effects2 = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL)
                for _, e in ipairs(effects2) do
                    if e.Position:DistanceSquared(player.Position) <= 60 ^ 2 then
                        --  wakaba.Log("Haemo trail form Rira Uniform found, removing...")
                        e:Remove()
                    end
                end
                if clearFlag then
                    currentRoomDesc.NoReward = false
                end
            end,
            1
        )
        Astro:ScheduleForUpdate(
            function()
                player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION, 2)
            end,
            150
        )
        ::skipRiraUniform::

        if Astro.Data["sandevistanSouls"] >= highPoint then
            player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true)
            player:GetEffects():AddNullEffect(NullItemID.ID_CAMO_BOOST, false, 30)
            Astro.Data["sandevistanSouls"] = Astro.Data["sandevistanSouls"] - highPoint
        elseif Astro.Data["sandevistanSouls"] >= middlePoint then
            player:GetEffects():AddNullEffect(NullItemID.ID_CAMO_BOOST, false, 30)
            Astro.Data["sandevistanSouls"] = Astro.Data["sandevistanSouls"] - middlePoint
        elseif Astro.Data["sandevistanSouls"] >= lowPoint then
            Astro.Data["sandevistanSouls"] = Astro.Data["sandevistanSouls"] - lowPoint
        end

        return {
            Discharge = discharge,
            Remove = remove,
            ShowAnim = showAnim
        }
    end,
    Astro.Collectible.SANDEVISTAN
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.SANDEVISTAN) then
                local souls = Astro.Data["sandevistanSouls"] or 0

                Isaac.RenderText(
                    "x" .. souls,
                    Isaac.WorldToScreen(player.Position).X,
                    Isaac.WorldToScreen(player.Position).Y - 40,
                    1,
                    1,
                    1,
                    1
                )

                break
            end
        end
    end
)

Astro.Collectible.BIRTHRIGHT_MAGGY = Isaac.GetItemIdByName("Maggy's Frame")

---

local MAGGY_FRAME_HITBOX_VARIANT = 3113
local MAGGY_FRAME_COOLDOWN = 20
local MAGGY_FRAME_DAMAGE = 6    -- 피해량은 플레이어 공격력의 n배

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local rgonWarning = REPENTOGON and "" or "#{{Blank}} {{ColorGray}}(이 근접 공격으로는 아이템을 주울 수 없음){{CR}}#"
            local rgonWarningENG = REPENTOGON and "" or "#{{Blank}} {{ColorGray}}(This swing can't pick up the item){{CR}}#"

            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_MAGGY,
                "매기의 액자",
                "치명적인 포옹",
                "적과 접촉시 공격력 x6의 근접 공격이 나갑니다." ..
                rgonWarning ..
                "#{{Card82}} 적을 처치하면 1.5초 후 사라지는 {{Heart}}빨간하트를 드랍합니다.",
                -- 중첩 시
                "중첩 시 근접 공격 피해량 +100%p"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_MAGGY,
                "Maggy's Frame",
                "",
                "On Contact, do a melee swing for 6x damage" ..
                rgonWarningENG ..
                "#{{Card82}} Enemies killed drop half Red Hearts that disappear after 2 seconds",
                -- Stacks
                "Stacks increases melee attack damage by 100%p",
                "en_us"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)

                    if player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE_B and selectedCollectible == Astro.Collectible.BIRTHRIGHT_MAGGY then
                        return {
                            reroll = true,
                            newitem = CollectibleType.COLLECTIBLE_BIRTHRIGHT,
                            modifierName = "Maggy's Frame"
                        }
                    end
                end

                return false
            end
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = player:GetData()

            pData._ASTRO_maggyFrameCooldown = 0
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_MAGGY) then
            local temporacyEffect = player:GetEffects()

            if not temporacyEffect:HasNullEffect(NullItemID.ID_SOUL_MAGDALENE) then
                temporacyEffect:AddNullEffect(NullItemID.ID_SOUL_MAGDALENE)
            end
        end

        local pData = player:GetData()
        if pData._ASTRO_maggyFrameCooldown then
            pData._ASTRO_maggyFrameCooldown = math.max(0, pData._ASTRO_maggyFrameCooldown - 1)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_PLAYER_COLLISION,
    ---@param player EntityPlayer
    ---@param collider Entity
    ---@param low boolean
    function(_, player, collider, low)
        if not player:HasCollectible(Astro.Collectible.BIRTHRIGHT_MAGGY) then return end
        if not collider:IsVulnerableEnemy() or collider.Type == EntityType.ENTITY_FIREPLACE then return end

        local pData = player:GetData()
        if pData._ASTRO_maggyFrameCooldown > 0 then return end
        pData._ASTRO_maggyFrameCooldown = MAGGY_FRAME_COOLDOWN

        local collectibleNum = player:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_MAGGY)
        local getAngle = (collider.Position - player.Position):GetAngleDegrees()
        Astro.KnifeUtil:SpawnSwingEffect(
            player,
            getAngle,
            {
                Damage = player.Damage * (MAGGY_FRAME_DAMAGE - 1 + collectibleNum),
                Radius = 42,
                Flags = DamageFlag.DAMAGE_SPAWN_TEMP_HEART
            }
        )

        local dirVec = player.Position - collider.Position
        dirVec = dirVec:Normalized()
        player:AddVelocity(dirVec * 6)
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE_B then
            player:RemoveCollectible(Astro.Collectible.BIRTHRIGHT_MAGGY)
            player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
        end
    end,
    Astro.Collectible.BIRTHRIGHT_MAGGY
)
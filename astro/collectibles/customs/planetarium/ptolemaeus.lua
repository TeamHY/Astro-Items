Astro.Collectible.PTOLEMAEUS = Isaac.GetItemIdByName("Ptolemaeus")

local radius = 15
local subScale = 0.5
local subDamageMultiplier = 0.5

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.PTOLEMAEUS,
        "프톨레마이오스",
        "천동설",
        "눈물에 눈물 주변을 도는 공격력 x0.5의 눈물이 생깁니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        local tearData = tear:GetData()

        if player ~= nil and player:HasCollectible(Astro.Collectible.PTOLEMAEUS) then
            tearData.Ptolemaeus = {}
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_TEAR_UPDATE,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        local tearData = tear:GetData()

        if player ~= nil and tearData.Ptolemaeus ~= nil then
            if not tearData.Ptolemaeus.IsSub then -- 메인 눈물 업데이트 (서브 눈물 위치 계산)
                if tear.FrameCount == 1 then
                    local subTears = {}

                    for _ = 1, player:GetCollectibleNum(Astro.Collectible.PTOLEMAEUS) do
                        local subTear =
                            player:FireTear(tear.Position, tear.Velocity, false, true, false, tear, subDamageMultiplier)

                        subTear.Scale = tear.Scale * subScale
                        subTear.TearFlags = subTear.TearFlags & ~TearFlags.TEAR_SPLIT & ~TearFlags.TEAR_BONE
                        subTear:GetData().Ptolemaeus = {
                            MainTear = tear,
                            IsSub = true
                        }

                        if tear.TearFlags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO then
                            subTear.TearFlags = subTear.TearFlags | TearFlags.TEAR_LUDOVICO
                            subTear.Height = tear.Height
                        end

                        table.insert(subTears, subTear)
                    end

                    tearData.Ptolemaeus.SubTears = subTears
                    tearData.Ptolemaeus.StartAngle = tear.Velocity:GetAngleDegrees()
                end

                for index, value in ipairs(tearData.Ptolemaeus.SubTears) do
                    local angle =
                        math.rad(
                            tearData.Ptolemaeus.StartAngle + (360 * index / #tearData.Ptolemaeus.SubTears) +
                            (360 * player.ShotSpeed * tear.FrameCount / 30)
                        )

                    if angle > 360 then
                        angle = angle - 360
                    end

                    local x = math.cos(angle) * radius
                    local y = math.sin(angle) * radius

                    if value:Exists() then
                        value.Velocity = tear.Position - value.Position + Vector(x, y)
                    end
                end
            else -- 서브 눈물 업데이트
                if
                    tear.TearFlags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO and
                    not tearData.Ptolemaeus.MainTear:Exists()
                then
                    tear:Remove()
                end
            end
        end
    end
)


------ 코스튬 ------
local COSTUME_VARIANT = 3120

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, COSTUME_VARIANT, 0, player.Position, Vector.Zero, nil):ToEffect()
        effect.Parent = player
        effect:FollowParent(player)
    end,
    Astro.Collectible.PTOLEMAEUS
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.PTOLEMAEUS) then
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, COSTUME_VARIANT, 0, player.Position, Vector.Zero, nil):ToEffect()
                effect.Parent = player
                effect:FollowParent(player)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local parent = effect.Parent

        if parent ~= nil and parent:ToPlayer() then
            local player = parent:ToPlayer()

            if player:HasCollectible(Astro.Collectible.PTOLEMAEUS) then
                local sprite = effect:GetSprite()

                effect.DepthOffset = 1
                effect.Visible = player.Visible
                effect.Color = player:GetColor()
                sprite.Color = player:GetSprite().Color
            else
                effect:Remove()
            end
        end
    end,
    COSTUME_VARIANT
)
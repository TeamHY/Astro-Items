Astro.Collectible.CASEY = Isaac.GetItemIdByName("Casey")

---

local TEARS_TO_SWING = 3    -- 눈물 n발마다 휘두름

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.CASEY,
                "케이시",
                "1루수가 누구야",
                "{{Player16}} 눈물을 " .. TEARS_TO_SWING .. "번 발사할 때마다 공격력 x3의 근접 공격을 발사합니다.",
                -- 중첩 시
                "중첩 시 피해량이 중첩된 수만큼 1.5배씩 곱연산으로 증가"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.CASEY,
                "Casey",
                "",
                "{{Player16}} Isaac shoots a melee swing every " .. TEARS_TO_SWING .. " tears, which deals 3x Isaac's damage",
                -- Stacks
                "Stacks increases the damage of melee swings",
                "en_us"
            )
        end
    end
)

------ 구현 ------
local BAT_SWING_EFFECT = 3113

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = tear.Parent and tear.Parent:ToPlayer()
        if tear.TearIndex % TEARS_TO_SWING ~= 0 then return end
        if not player:HasCollectible(Astro.Collectible.CASEY) then return end
        
        -- TODO: 악마눈 특성상 지형지물에서 눈물쏘면 바로 씹힘 / 자체 히트박스 구현 필요
        local evilEye = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EVIL_EYE, 10, player.Position, Vector.Zero, player):ToEffect()
        local eData = evilEye:GetData()
        evilEye:FollowParent(player)
        evilEye.Visible = false
        eData._ASTRO_batPlayer = player
        eData._ASTRO_batRotation = player:GetFireDirection()
        
        local knife = player:FireKnife(evilEye, 0, false, 4, 1):ToKnife()
        eData._ASTRO_batDamage = knife.CollisionDamage
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_KNIFE_UPDATE,
    function(_, knife)
        if knife.Parent and knife.Parent.Type == 1000 and knife.Parent.Variant == 84 and knife.Parent.SubType == 10 then
            local eData = knife.Parent:GetData()
            local sprite = knife:GetSprite()
            local player = eData._ASTRO_batPlayer

            if eData._ASTRO_batPlayer then
                local playerRange = math.max(1, player.TearRange / 400)
                local caseyNum = player:GetCollectibleNum(Astro.Collectible.CASEY)
                local finalRange = playerRange + ((caseyNum - 1) * 0.1)

                knife.Scale = finalRange
                knife.SpriteScale = Vector(finalRange, finalRange)
                knife.Color = Color(1,0,0,1)
                knife.CollisionDamage = eData._ASTRO_batDamage * (1.5 ^ (caseyNum - 1))

                if knife.FrameCount == 0 and not player:HasCollectible(69) then
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, BAT_SWING_EFFECT, 0, knife.Position, Vector.Zero, player):ToEffect()
                    effect:FollowParent(player)
                    effect.SpriteScale = Vector(finalRange, finalRange)

                    local fxSprite = effect:GetSprite()
                    fxSprite.PlaybackSpeed = 2

                    if eData._ASTRO_batRotation == 3 then
                        fxSprite.Offset = Vector(2, 4)
                        fxSprite:Play("SwingDown", true)
                    elseif eData._ASTRO_batRotation == 1 then
                        fxSprite.Offset = Vector(2, -6)
                        fxSprite:Play("SwingUp", true)
                    elseif eData._ASTRO_batRotation == 0 then
                        fxSprite.Offset = Vector(-5, -10)
                        fxSprite:Play("SwingLeft", true)
                    elseif eData._ASTRO_batRotation == 2 then
                        fxSprite.Offset = Vector(12, -7)
                        fxSprite.Rotation = -90
                        fxSprite:Play("SwingRight", true)
                    end

                    SFXManager():Play(SoundEffect.SOUND_SHELLGAME, 0.25)
                end
            end

            if sprite:IsFinished("Swing") or sprite:IsFinished("Swing2") or sprite:IsFinished("SwingDown") or sprite:IsFinished("SwingDown2") then
                knife.Parent:Remove()
            end
        end
    end,
    4
)
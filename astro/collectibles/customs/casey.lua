Astro.Collectible.CASEY = Isaac.GetItemIdByName("Casey")

---

local TEARS_TO_SWING = 3    -- 눈물 n발마다 휘두름
local CASEY_DAMAGE = 3    -- 플레이어 공격력 n배
local CASEY_STACK_DAMAGE = 1.5    -- 중첩 할 때마다 n배씩 곱연산으로 증가

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local rgonWarning = REPENTOGON and "" or "#{{Blank}} {{ColorGray}}(이 근접 공격으로는 아이템을 주울 수 없음){{CR}}#"
            local rgonWarningENG = REPENTOGON and "" or "#{{Blank}} {{ColorGray}}(This swing can't pick up the item){{CR}}#"

            Astro.EID:AddCollectible(
                Astro.Collectible.CASEY,
                "케이시",
                "1루수가 누구야",
                "눈물을 " .. TEARS_TO_SWING .. "번 발사할 때마다 공격력 x" .. CASEY_DAMAGE .. "의 근접 공격이 나갑니다." ..
                rgonWarning,
                -- 중첩 시
                "중첩 시 피해량이 중첩된 수만큼 " .. CASEY_STACK_DAMAGE .. "배씩 곱연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.CASEY,
                "Casey",
                "",
                "Isaac shoots a melee swing every " .. TEARS_TO_SWING .. " tears, which deals " .. CASEY_DAMAGE .. "x Isaac's damage" ..
                rgonWarningENG,
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

        local caseyNum = player:GetCollectibleNum(Astro.Collectible.CASEY)
        local playerRange = math.max(40, player.TearRange * 0.15)
        local finalRange = playerRange + ((caseyNum - 1) * 2)

        local hitbox = Astro.KnifeUtil:SpawnSwingEffect(
            player,
            player:GetShootingInput():GetAngleDegrees(),
            {
                Damage = player.Damage * CASEY_DAMAGE * (CASEY_STACK_DAMAGE ^ (caseyNum - 1)),
                Radius = finalRange
            },
            {
                Main = "gfx/effects/bat_swinging.png",
                Whoosh = "gfx/effects/bat_swinging.png"
            }
        )
        
        local spriteSize = math.max(1, player.TearRange / 400) + ((caseyNum - 1) * 0.1)
        hitbox.SpriteScale = Vector(spriteSize, spriteSize)
        
        local sfx = SFXManager()
        sfx:Play(SoundEffect.SOUND_SHELLGAME, 0.25)
    end
)
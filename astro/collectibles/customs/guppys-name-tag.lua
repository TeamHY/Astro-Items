Astro.Collectible.GUPPYS_NAME_TAG = Isaac.GetItemIdByName("Guppy's Name Tag")

------

local SURVIVAL_CHANCE = 0.5    -- 발동 확률

local SURVIVAL_COOL = 180    -- 무적 시간 (60당 1초)

------

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_GUPPYS_COLLAR].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible212}}{{ColorYellow}}구피의 목걸이{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible212}} {{ColorYellow}}Guppy's Collar{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.GUPPYS_NAME_TAG, CRAFT_HINT)

            local surviveChance = string.format("%.f", SURVIVAL_CHANCE * 100)

            Astro.EID:AddCollectible(
                Astro.Collectible.GUPPYS_NAME_TAG,
                "구피의 이름표",
                "이 세상에 두려운 건 없어 너와 함께면",
                "사망 시 " .. surviveChance .. "%의 확률로 그 방에서 즉시 부활합니다." ..
                "#확률형 부활류 아이템들의 부활 가능 여부가 체력 HUD에 표시됩니다.",
                -- 중첩 시
                "중첩 시 무적 시간이 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.GUPPYS_NAME_TAG,
                "Guppy's Name Tag", "",
                surviveChance .. "% chance to revive in the same room on death" ..
                "#The revive status of chance-based revive items is displayed on the health HUD",
                -- Stacks
                "Stacks incraese invincibility duration",
                "en_us"
            )
        end
    end
)

local controlCooldown = 0

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()
        local currentHP = player:GetHearts() + player:GetSoulHearts() + player:GetEternalHearts() + player:GetBoneHearts()

        if player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
            currentHP = 0
        end

        if amount >= currentHP then
            if player:HasCollectible(Astro.Collectible.GUPPYS_NAME_TAG) then    
                local collectibleNum = player:GetCollectibleNum(Astro.Collectible.GUPPYS_NAME_TAG)
                local rng = player:GetCollectibleRNG(Astro.Collectible.GUPPYS_NAME_TAG)
                local chance = rng:RandomFloat()

                if chance <= SURVIVAL_CHANCE then
                    local hitSfx = nil

                    if source.Entity and source.Entity.Type == EntityType.ENTITY_FIREPLACE then
                        hitSfx = SoundEffect.SOUND_FIREDEATH_HISS
                    end

                    Astro:FakeDeath(player, SURVIVAL_COOL * collectibleNum, hitSfx, Astro.Collectible.GUPPYS_NAME_TAG)

                    return false
                end
            end
        end
    end,
    EntityType.ENTITY_PLAYER
)

local font = Font()
local font2 = Font()
font:Load("font/pftempestasevencondensed.fnt")
font2:Load(Astro.ModPath .. "resources/font/for translate/luaminioutlined.fnt")

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function()
        local game = Game()
        local hud = game:GetHUD()

        if not hud:IsVisible() then
            return
        end

        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local prediction = player:WillPlayerRevive()

            local maxHearts = player:GetMaxHearts()
            local soulHearts = player:GetSoulHearts()
            local boneHearts = player:GetBoneHearts()
            local validHearts = maxHearts + soulHearts + boneHearts

            if player:HasCollectible(Astro.Collectible.GUPPYS_NAME_TAG) and prediction then
                if game:GetNumPlayers() < 2 then
                    local healthPosX = math.min(12, validHearts)
                    local healthPosY = 10

                    if healthPosX % 2 ~= 0 then
                        healthPosX = healthPosX + 1
                    end

                    if validHearts > 12 then
                        healthPosY = 14
                    end
                    
                    local shakeOffset = game.ScreenShakeOffset
                    local hudOffset = (Options.HUDOffset * Vector(20, 12))
                    local finalPos = Vector(66 + (healthPosX * 6), healthPosY) + hudOffset + shakeOffset

                    font:DrawStringUTF8("(OK)", finalPos.X, finalPos.Y, KColor(1, 1, 1, 1))
                else
                    local finalPos = Astro:ToScreen(player.Position)
                    local string = "(Will be\nrevived)"
                    local xOffset = 4
                    
                    if Options.Language == "kr" then
                        string = "(부활 가능)"
                        xOffset = 0
                    end

                    font2:DrawStringUTF8(string, finalPos.X - 20 + xOffset, finalPos.Y + 2, KColor(1, 1, 1, 0.75))
                end
            end
        end
    end
)
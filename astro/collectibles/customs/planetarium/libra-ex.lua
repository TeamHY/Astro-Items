local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.LIBRA_EX = Isaac.GetItemIdByName("Libra EX")

if EID then
    EID:assignTransformation("collectible", Astro.Collectible.LIBRA_EX, "Chubby")
    
    Astro:AddEIDCollectible(Astro.Collectible.LIBRA_EX, "초 천칭자리", "...", "↑ 모든 세트 +1#처비 세트를 제외하고 중첩이 가능합니다.")
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if collectibleType == Astro.Collectible.LIBRA_EX and Astro:IsFirstAdded(collectibleType) then
            Astro.Data.ChubbySet = Astro.Data.ChubbySet + 1

            if Astro.Data.ChubbySet == 3 then
                SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER)
                Game():GetHUD():ShowItemText("처비!!!", '')
            end
        end
    end
)

local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.LIBRA_EX = Isaac.GetItemIdByName("Libra EX")

if EID then
    EID:assignTransformation("collectible", AstroItems.Collectible.LIBRA_EX, "Chubby")
    
    AstroItems:AddEIDCollectible(AstroItems.Collectible.LIBRA_EX, "초 천칭자리", "...", "모든 세트 파츠들의 소지 카운트를 +1 상승됩니다.#처비 세트를 제외하고 중복이 가능합니다.")
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if collectibleType == AstroItems.Collectible.LIBRA_EX and AstroItems:IsFirstAdded(collectibleType) then
            AstroItems.Data.ChubbySet = AstroItems.Data.ChubbySet + 1

            if AstroItems.Data.ChubbySet == 3 then
                SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER)
                Game():GetHUD():ShowItemText("처비!!!", '')
            end
        end
    end
)

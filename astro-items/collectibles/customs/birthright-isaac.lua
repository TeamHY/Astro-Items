AstroItems.Collectible.BIRTHRIGHT_ISAAC = Isaac.GetItemIdByName("Birthright - Isaac")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.BIRTHRIGHT_ISAAC, "생득권 - 아이작", "...", "방에 입장 시 {{Card81}}Soul of Isaac을 발동합니다.#중접이 가능합니다.")
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()

        if currentRoom:GetFrameCount() <= 0 and currentRoom:IsFirstVisit() and not AstroItems:IsDeathCertificateRoom() then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
            
                if player:HasCollectible(AstroItems.Collectible.BIRTHRIGHT_ISAAC) then
                    for _ = 1, player:GetCollectibleNum(AstroItems.Collectible.BIRTHRIGHT_ISAAC) do
                        player:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                    end
                end
            end
        end
    end
)

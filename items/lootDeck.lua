local helper = include("helper_functions")

-- Spawns a lootcard
local Names = {
    en_us = "Loot Deck",
    spa = "Baraja de Loot"
}
local Name = Names.en_us
local Tag = "lootDeck"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "{{Card}} Grants a Loot Card on use",
    spa = "Genera una carta de Loos al usarlo"
}
local WikiDescription = helper.GenerateEncyclopediaPage("Grants a Loot Card on use.")

local function MC_USE_ITEM(_, type, rng, p)
    local lootCard = helper.GetWeightedLootCardId()
    p:AddCard(lootCard)

    local heldLootcard = helper.GetLootcardById(p:GetCard(0))

    p:AnimateCard(heldLootcard.Id)
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
	Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    callbacks = {
        {
            ModCallbacks.MC_USE_ITEM,
            MC_USE_ITEM,
            Id
        }
    }
}

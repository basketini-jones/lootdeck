local helper = include('helper_functions')

-- Meat Cleaver effect
local Names = {
    en_us = "Jera",
    spa = "Jera"
}
local Name = Names.en_us
local Tag = "jera"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 1
local Descriptions = {
    en_us = "Triggers the {{Collectible631}} Meat Cleaver effect, splitting all room enemies in half with half their respective HP",
    spa = "Activa el efecto del {{Collectible631}} Cuchillo de Carnicero, partiendo a los enemigos a la mitad con la mitad de sus PS respecticos"
}
local WikiDescription = helper.GenerateEncyclopediaPage("On use, triggers the Meat Cleaver effect, which splits all room enemies in half with half of their respective HP.")

local function MC_USE_CARD(_, c, p)
    if #helper.ListEnemiesInRoom(p.Position, true) > 0 then
       helper.SimpleLootCardEffect(p, CollectibleType.COLLECTIBLE_MEAT_CLEAVER)
    else
        helper.FuckYou(p)
    end
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
	Id = Id,
    Weight = Weight,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    callbacks = {
        {
            ModCallbacks.MC_USE_CARD,
            MC_USE_CARD,
            Id
        }
    }
}


local helper = include("helper_functions")
local items = include("items/registry")

local Names = {
    en_us = "Curved Horn",
    spa = "Cuerno Torcido"
}
local Name = Names.en_us
local Tag = "curvedHorn"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 1
local Descriptions = {
    en_us = "Adds a unique passive item on use# Passive: Quadruple damage for the first tear fired in a room",
    spa = "Añade un objeto pasivo tras usarla#Efecto pasivo: Cuadriplica el daño de la primer lágrima lanzada en una habitación"
}
local WikiDescription = helper.GenerateEncyclopediaPage("On use, grants a unique passive item.", "Passive effect: In a room with active enemies, the first tear fired has x4 damage and size.", "- This effect occurs when enemies spawn after entering a room, such as when a spider spawns from a pot.", "- Additional copies of the passive let you fire additional x4 damage tears.")

local function MC_USE_CARD(_, c, p)
	helper.SimpleLootCardItem(p, items.curvedHorn.Id, SoundEffect.SOUND_VAMP_GULP)
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

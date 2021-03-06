local helper = LootDeckAPI
local items = include("items/registry")

-- Gives the Broken Ankh item
local Names = {
    en_us = "Broken Ankh",
    spa = "Anj Roto"
}
local Name = Names.en_us
local Tag = "brokenAnkh"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 1
local Descriptions = {
    en_us = "Adds a unique passive item on use# Passive: On death, 1/6 chance to revive with half a heart#{{Warning}} WARNING: Due to modding API weirdness, reviving with this item will reset your streak and make you unable to continue the run if quit.",
    spa = "Añade un objeto pasivo tras usarla#Efecto pasivo: Al morir, tienes una probabilidad de 1/6 de revivir con medio corazón de alma#{{Warning}} ADVERTENCIA: Por motivos derivados de la API, revivir con esta carta reiniciará tu racha de victorias y será imposible continuar la partida si sales de ella"
}
local HolographicDescriptions = {
    en_us = "Adds {{ColorRainbow}}2 copies of a{{CR}} unique passive item on use# Passive: On death, 1/6 chance to revive with half a heart",
    spa = "Añade {{ColorRainbow}}2 copias de un{{CR}} objeto pasivo tras usarla#Efecto pasivo: Al morir, tienes una probabilidad de 1/6 de revivir con medio corazón de alma"
}
local WikiDescription = helper.GenerateEncyclopediaPage("On use, grants a unique passive item.", "Passive effect: On player death, you have a 1/6 chance of reviving with half a heart.", "- Additional copies of the passive grant an extra revival chance up to 3/6.", "WARNING: Due to modding API weirdness, reviving with this card will reset your streak and make you unable to continue the run if quit.", "Holographic Effect: Grants two copies of the passive.")

-- BUG: When you revive, your streak is still lost, and saving/continuing is disabled. this is because Revive() is bugged and the game still thinks you're dead
-- due to how poorly extra lives are supported in the API, this is probably the best we're getting without massive overcomplications
local function MC_USE_CARD(_, c, p)
	helper.GiveItem(p, items.brokenAnkh.Id, SoundEffect.SOUND_VAMP_GULP)
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
	Id = Id,
    Weight = Weight,
	Descriptions = Descriptions,
    HolographicDescriptions = HolographicDescriptions,
	WikiDescription = WikiDescription,
    Callbacks = {
        {
            ModCallbacks.MC_USE_CARD,
            MC_USE_CARD,
            Id,
            true
        }
    }
}

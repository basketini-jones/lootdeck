local helper = LootDeckAPI

-- Spawns a little battery
local Names = {
    en_us = "Lil Battery",
    spa = "Batería"
}
local Name = Names.en_us
local Tag = "lilBattery"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 2
local Descriptions = {
    en_us = "Spawns a Lil' Battery",
    spa = "Genera una batería"
}
local HolographicDescriptions = {
    en_us = "Spawns {{ColorRainbow}}2{{CR}} Lil' Batteries",
    spa = "Genera {{ColorRainbow}}2{{CR}} baterías"
}
local WikiDescription = helper.GenerateEncyclopediaPage("Spawns a Lil' Battery on use.", "Holographic Effect: Spawns two Lil' Batteries.")

local function MC_USE_CARD(_, c, p)
	helper.SpawnEntity(p, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL)
    lootdeck.sfx:Play(SoundEffect.SOUND_SHELLGAME,1,0)
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

local helper = LootDeckAPI

-- Spawns a penny
local Names = {
    en_us = "A Penny!",
    spa = "¡Un Penny!"
}
local Name = Names.en_us
local Tag = "penny"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 2
local Descriptions = {
    en_us = "Spawns a Penny",
    spa = "Genera un penny"
}
local HolographicDescriptions = {
    en_us = "Spawns {{ColorRainbow}}2{{CR}} Pennies",
    spa = "Genera {{ColorRainbow}}2{{CR}} pennies"
}
local WikiDescription = helper.GenerateEncyclopediaPage("Spawns a Penny on use.", "Holographic Effect: Spawns two Pennies.")

local function MC_USE_CARD(_, c, p)
	helper.SpawnEntity(p, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, 1, nil, SoundEffect.SOUND_CASH_REGISTER, EffectVariant.COIN_PARTICLE, 1)
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

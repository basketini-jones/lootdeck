local helper = include("helper_functions")
local entityVariants = include("entityVariants/registry")

-- Spawns a Devil Hand that "steals" any item and brings it next to the player
local Names = {
    en_us = "Joker",
    spa = "Comodín"
}
local Name = Names.en_us
local Tag = "joker"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 1
local Descriptions = {
	en_us = "Spawns a Devil Hand familiar which steals any item in the room (shop items included) and brings it to the player# If there are no items in the room, the effect fails",
	spa = "Genera una mano del Diablo familiar que robará cualquier objeto de la sala (incluyendo tiendas) y se lo entregará al jugador#Si no hay objetos en la sala, el efecto falla"
}
local WikiDescription = helper.GenerateEncyclopediaPage("Spawns a Devil Hand familiar, which steals any item in the room and moves it next to the player.", "- This includes shop items and devil deals", "- This can steal non-shop items trapped behind obstacles, allowing the player to access them.")

local function MC_USE_CARD(_, c, p)
	local devilHand = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, entityVariants.devilHand.Id, 0, p.Position, Vector.Zero, p)
	devilHand:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	devilHand:GetData().player = p

	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, p)
	poof.Color = Color(0,0,0,1,0,0,0)
    lootdeck.sfx:Play(SoundEffect.SOUND_SATAN_SPIT, 1, 0)
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
            Id,
            true
        }
    }
}

local helper = include('helper_functions')
local entityVariants = include("entityVariants/registry")

-- Spawns 10 "Holy Shield" familiars that block bullets and die after blocking
local Name = "Holy Card"
local Tag = "holyCard"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 1

local function MC_USE_CARD(_, c, p)
	local data = p:GetData()
	data[Tag] = 1
	helper.SimpleLootCardSpawn(p, EntityType.ENTITY_FAMILIAR, entityVariants.holyShield.Id, 0, 10, Vector.Zero, SoundEffect.SOUND_HOLY)
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, p.Position, Vector.Zero, p)
	poof.Color = Color(1,1,1,1,1,1,1)
end

return {
    Name = Name,
    Tag = Tag,
	Id = Id,
    Weight = Weight,
    callbacks = {
        {
            ModCallbacks.MC_USE_CARD,
            MC_USE_CARD,
            Id
        }
    }
}

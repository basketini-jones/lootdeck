local helper = LootDeckAPI

local Name = "Double Dime"
local Tag = "doubleDime"
local Id = Isaac.GetEntityVariantByName(Name)

local function MC_PRE_PICKUP_COLLISION(_, pi, e)
    helper.CustomCoinPrePickupCollision(pi, e, 20, SoundEffect.SOUND_DIMEPICKUP)
end

local function MC_POST_PICKUP_UPDATE(_, pi)
    helper.CustomCoinPickupUpdate(pi, SoundEffect.SOUND_DIMEDROP)
end

return {
    Name = Name,
    Tag = Tag,
	Id = Id,
    Callbacks = {
        {
            ModCallbacks.MC_PRE_PICKUP_COLLISION,
            MC_PRE_PICKUP_COLLISION,
            Id
        },
        {
            ModCallbacks.MC_POST_PICKUP_UPDATE,
            MC_POST_PICKUP_UPDATE,
            Id
        }
    }
}

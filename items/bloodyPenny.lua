local helper = include("helper_functions")

-- Gives a chance for killing an enemy to drop a tarotcard
local Name = "Bloody Penny"
local Tag = "bloodyPenny"
local Id = Isaac.GetItemIdByName(Name)

local function MC_POST_ENTITY_KILL(_, e)
    local game = Game()
    local rng = lootdeck.rng
    local effectNum = 0
    for x=0,game:GetNumPlayers()-1 do
        local p = Isaac.GetPlayer(x)
        effectNum = effectNum + p:GetCollectibleNum(Id)
    end
    local effect = rng:RandomInt(20)

    local threshold = 0
    if effectNum > 0 then threshold = 1 end
    threshold = threshold + (effectNum - 1)
    if threshold >= 5 then threshold = 4 end
    if effect <= threshold then
        local cardId = helper.GetWeightedLootCardId()
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, cardId, e.Position, Vector.FromAngle(rng:RandomInt(360)), nil)
    end
end

return {
    Name = Name,
    Tag = Tag,
	Id = Id,
    callbacks = {
        {
            ModCallbacks.MC_POST_ENTITY_KILL,
            MC_POST_ENTITY_KILL
        }
    }
}

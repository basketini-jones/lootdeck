local helper = include('helper_functions')
local costumes = include("costumes/registry")

local Names = {
    en_us = "XI. Strength",
    spa = "XI. Fuerza"
}
local Name = Names.en_us
local Tag = "strength"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 1
local Descriptions = {
    en_us = "Triggers the {{Collectible437}} D7 effect, respawning all enemies in the room to spawn an extra room reward#{{ArrowUp}} +1.0 Damage up until the end of the floor",
    spa = "Activa el efecto del {{Collectible437}} D7, reviviendo a los enemigos muertos con una recompensa extra#{{ArrowUp}} +1.0 durante todo el piso"
}
local WikiDescription = helper.GenerateEncyclopediaPage("Triggers the D7 effect, which respawns all enemies in the room for a chance at an extra room reward.", "+1 Damage Up for the rest of the floor.")

local function MC_USE_CARD(_, c, p)
	helper.SimpleLootCardEffect(p, CollectibleType.COLLECTIBLE_D7)

    local data = p:GetData()
    local sprite = p:GetSprite()
    if not data.strength then data.strength = 1
    else
        data.strength = data.strength + 1
    end
    for i=1,data.strength or 0 do
        local color = Color(1,1,1,1,data.strength/10,0,0)
        sprite.Color = color
    end
	p:AddNullCostume(costumes.strengthFire)
    p:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    p:EvaluateItems()
    lootdeck.sfx:Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE, 1, 0)
end

local function MC_EVALUATE_CACHE(_, p, f)
    local data = p:GetData()
    if f == CacheFlag.CACHE_DAMAGE then
        if data.strength then
            p.Damage = p.Damage + (data.strength)
        end
    end
end

local function MC_POST_NEW_ROOM()
    helper.ForEachPlayer(function(p, data)
        if data.strength then
			p:TryRemoveNullCostume(costumes.strengthFire)
			p:AddNullCostume(costumes.strengthGlow)
        end
    end)
end

local function MC_POST_NEW_LEVEL()
    helper.ForEachPlayer(function(p, data)
        if data.strength then
            data.strength = nil
            local color = Color(1,1,1,1,0,0,0)
            p.Color = color
            p:TryRemoveNullCostume(costumes.strengthFire)
            p:TryRemoveNullCostume(costumes.strengthGlow)
            p:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            p:EvaluateItems()
        end
    end)
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
        },
        {
            ModCallbacks.MC_EVALUATE_CACHE,
            MC_EVALUATE_CACHE
        },
        {
            ModCallbacks.MC_POST_NEW_ROOM,
            MC_POST_NEW_ROOM
        },
        {
            ModCallbacks.MC_POST_NEW_LEVEL,
            MC_POST_NEW_LEVEL
        }
    }
}

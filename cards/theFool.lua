local helper = include('helper_functions')

-- Teleport 2.0 effect
local Names = {
    en_us = "O. The Fool",
    spa = "O. El Loco"
}
local Name = Names.en_us
local Tag = "theFool"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 1
local Descriptions = {
    en_us = "Triggers the {{Collectible419}} Teleport 2.0 effect, teleporting you to an unvisited room",
    spa = "Activa el efecto de {{Colelctible419}} Teletransporte 2.0, teletrasnportándote a una habitación sin visitar"
}
local WikiDescription = helper.GenerateEncyclopediaPage("On use, triggers the Teleport 2.0 effect, which teleports you to an unvisited room with certain priority given to special rooms.")

local function MC_USE_CARD(_, c, p)
	helper.SimpleLootCardEffect(p, CollectibleType.COLLECTIBLE_TELEPORT_2)
    p:GetData()[Tag] = true
end

local function MC_POST_NEW_ROOM()
    helper.ForEachPlayer(function(p, data)
        local room = Game():GetRoom()
        if data[Tag] then
            for i=0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                local door = room:GetDoor(i)
                if door then
                    door:Open()
                end
            end
            data[Tag] = nil
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
            ModCallbacks.MC_POST_NEW_ROOM,
            MC_POST_NEW_ROOM
        }
    }
}

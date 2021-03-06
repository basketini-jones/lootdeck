local helper = LootDeckAPI

-- Gives massive firerate increase on room entry, quickly decreases over time
local Names = {
    en_us = "Cancer!",
    spa = "¡Cancer!"
}
local Name = Names.en_us
local Tag = "cancer"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "{{ArrowUp}} Massive firerate increase when entering a room with enemies#{{ArrowDown}} The firerate increase quickly diminishes over time",
    spa = "{ArrowUp}} Aumento masivo en potencia de fuego al entrar en una habitación con enemigos#El efecto disminuye rápidamente"
}
local WikiDescription = helper.GenerateEncyclopediaPage("In a room with active enemies, your firerate massively increases, then decreases over time.", "- This effect occurs when enemies spawn after entering a room, such as when a spider spawns from a pot.")

local originalFireDelayTag = string.format("%sOriginalFireDelay", Tag)
local finishedTag = string.format("%sFinished", Tag)
local roomClearedTag = string.format("%sRoomCleared", Tag)
local greedModeWaveTag = string.format("%sGreedModeWave", Tag)

local RUNTIME = 3 * 30
local RATE_MULTIPLIER = 10

local function Initialize(p)
    if helper.AreEnemiesInRoom() then
        local data = helper.GetLootDeckData(p)
        if data[finishedTag] or data[finishedTag] == nil then
            data[originalFireDelayTag] = p.MaxFireDelay
        end
        data[Tag] = RUNTIME
        data[finishedTag] = false
        data[roomClearedTag] = nil
        if Game():IsGreedMode() then
            data[greedModeWaveTag] = 0
        end
        p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        p:EvaluateItems()
    end
end

local function MC_POST_NEW_ROOM()
    helper.ForEachPlayer(function(p)
        local data = helper.GetLootDeckData(p)
        data[Tag] = nil
        data[finishedTag] = nil
        p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        p:EvaluateItems()
        Initialize(p)
    end, Id)
end

local function MC_POST_PEFFECT_UPDATE(_, p)
    helper.TriggerOnRoomEntryPEffectUpdate(p, Id, Initialize, function()
        local data = helper.GetLootDeckData(p)
        if data[Tag] and data[Tag] > 0 then
            data[Tag] = data[Tag] - 1
            p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            p:EvaluateItems()
        end
    end, Tag);
end

local function MC_EVALUATE_CACHE(_, p, f)
    local data = helper.GetLootDeckData(p)
    if f == CacheFlag.CACHE_FIREDELAY then
        if data[Tag] then
            local newDelay = p.MaxFireDelay - ((data[originalFireDelayTag] - (data[originalFireDelayTag] / RATE_MULTIPLIER)) * (data[Tag] / RUNTIME))
            if data[Tag] > 0 then
                p.MaxFireDelay = newDelay
            else
                data[Tag] = nil
                data[finishedTag] = true
            end
        end
    end
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
	Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    Callbacks = {
        {
            ModCallbacks.MC_POST_NEW_ROOM,
            MC_POST_NEW_ROOM
        },
        {
            ModCallbacks.MC_POST_PEFFECT_UPDATE,
            MC_POST_PEFFECT_UPDATE
        },
        {
            ModCallbacks.MC_EVALUATE_CACHE,
            MC_EVALUATE_CACHE
        }
    },
    helpers = {
        Initialize = Initialize
    }
}

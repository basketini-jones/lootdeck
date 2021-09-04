lootdeck = RegisterMod("Loot Deck", 1)

local registry = include("registry")
local cards = include("cards/registry")
local entityVariants = include("entityVariants/registry")
local costumes = include("costumes/registry")

lootdeck.rng = RNG()
lootdeck.sfx = SFXManager()
lootdeck.level = 0
lootdeck.room = 0
lootdeck.f = {
    bloodyPenny = 0,
    oldPennies = 0,
    newPennies = 0,
    rerollEnemy = 0,
    spawnExtraReward = 0,
    spawnGlitchItem = false,
    sunUsed = false,
    removeSun = false,
    floorBossCleared = false,
    newRoom = false,
    foolRoom = false,
    world = nil,
    savedTime = 0,
    showOverlay = false,
    firstEnteredLevel = false,
    blueMap = false,
    compass = false,
    map = false
}

local helper = include("helper_functions")

local game = Game()
local rng = lootdeck.rng
local f = lootdeck.f

for _, card in pairs(cards) do
    if card.callbacks then
        for _, callback in pairs(card.callbacks) do
        lootdeck:AddCallback(table.unpack(callback)) 
        end
    end
end

for _, variant in pairs(entityVariants) do
    if variant.callbacks then
        for _, callback in pairs(variant.callbacks) do
        lootdeck:AddCallback(table.unpack(callback)) 
        end
    end
end

-- set rng seed
lootdeck:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    rng:SetSeed(Game():GetSeeds():GetStartSeed(), 35)
	lootdeck.room = Game():GetRoom()
    lootdeck.f.pennyCount = Isaac.GetPlayer(0):GetNumCoins()
end)

local blackOverlay = Sprite()
blackOverlay:Load("gfx/overlay.anm2")
blackOverlay:ReplaceSpritesheet(0, "gfx/coloroverlays/black_overlay.png")
blackOverlay:LoadGraphics()
blackOverlay:Play("Idle", true)

lootdeck:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if f.showOverlay then
         blackOverlay:RenderLayer(0, Vector.Zero)
     end
end)

lootdeck:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    f.firstEnteredLevel = true
end)

lootdeck:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if f.firstEnteredLevel then
        f.firstEnteredLevel = false
    end
end)

lootdeck:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local level = game:GetLevel()
    local room = level:GetCurrentRoom()
    local roomDesc = level:GetCurrentRoomDesc()

    if roomDesc.Clear and room:GetType() == RoomType.ROOM_BOSS then
        f.floorBossCleared = true
    end

    if f.floorBossCleared and f.sunUsed then
        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW)
    end
end)

lootdeck:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    if f.sunUsed then
        for i=0,game:GetNumPlayers()-1 do
            Isaac.GetPlayer(i):TryRemoveNullCostume(costumes.sun)
        end
    end
    f.sunUsed = false
    f.floorBossCleared = false
end)

lootdeck:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, f)
    local data = p:GetData()
    if not data.redDamage then data.redDamage = 0 end
    -- red pill damage cache evaulator
    if f == CacheFlag.CACHE_DAMAGE then
        if data.redDamage then
            p.Damage = p.Damage + (2 * data.redDamage)
        end
    end
end)

lootdeck:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    -- run on each player for multiplayer support
    for i=0,game:GetNumPlayers()-1 do
        local p = Isaac.GetPlayer(i)
        local data = p:GetData()
        if data.redDamage then
            data.redDamage = nil
            p:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            p:EvaluateItems()
        end
        if data.redHp then
            if (p:GetSubPlayer() == nil) then
                helper.RemoveHeartsOnNewRoomEnter(p, data.redHp)
            else
                helper.RemoveHeartsOnNewRoomEnter(helper.GetPlayerOrSubPlayerByType(p, PlayerType.PLAYER_THEFORGOTTEN), data.redHp)
            end
            data.redHp = nil
        end
        if data.soulHp then
            helper.RemoveHeartsOnNewRoomEnter(helper.GetPlayerOrSubPlayerByType(p, PlayerType.PLAYER_THESOUL), data.soulHp)
            data.soulHp = nil
        end
        if data.curvedHornTear then data.curvedHornTear = 1 end
    end
    if f.bloodyPenny > 0 then f.bloodyPenny = 0 end
end)

local costumes = include("costumes/registry")

-- Fires two tears at once with a demon costume and red tears for the room
local Name = "III. The Empress"
local Tag = "theEmpress"
local Id = Isaac.GetCardIdByName(Name)
local Weight = 1

local function MC_USE_CARD(_, c, p)
    local data = p:GetData()
    local itemConfig = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_20_20)
    p:AddCollectible(CollectibleType.COLLECTIBLE_20_20)
    if not data.empress then data.empress = 1
    else data.empress = data.empress + 1 end
    if data.empress >= p:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) then
        p:RemoveCostume(itemConfig)
    end
    lootdeck.sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A, 1, 0)
    p:AddNullCostume(costumes.empress)
    p:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARCOLOR)
    p:EvaluateItems()
end

local function MC_EVALUATE_CACHE(_, p, f)
    local data = p:GetData()
    if f == CacheFlag.CACHE_DAMAGE then
        if data.empress and p:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) <= data.empress then
            p.Damage = p.Damage * 1.334
        end
    end
	if f == CacheFlag.CACHE_TEARCOLOR then
		if data.empress then
			local color = Color(1,1,1,1,0,0,0)
			color:SetColorize(0.8,0,0,1)
			p.TearColor = color
		end
	end
end

local function MC_POST_NEW_ROOM()
    for i=0,Game():GetNumPlayers()-1 do
        local p = Isaac.GetPlayer(i)
        local data = p:GetData()
        if data.empress then
            for j=1,data.empress do
                p:RemoveCollectible(CollectibleType.COLLECTIBLE_20_20)
            end
            data.empress = nil
            p:TryRemoveNullCostume(costumes.empress)
            p:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARCOLOR)
            p:EvaluateItems()
        end
    end
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
        },
        {
            ModCallbacks.MC_EVALUATE_CACHE,
            MC_EVALUATE_CACHE
        },
        {
            ModCallbacks.MC_POST_NEW_ROOM,
            MC_POST_NEW_ROOM
        }
    }
}

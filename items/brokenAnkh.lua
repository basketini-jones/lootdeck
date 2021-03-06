local helper = LootDeckAPI

-- Gives a chance of reviving in the previous room with half a heart
local Names = {
    en_us = "Broken Ankh",
    spa = "Anj Roto"
}
local Name = Names.en_us
local Tag = "brokenAnkh"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "On death, 1/6 chance to revive with half a heart",
    spa = "Al morir, tienes una probabilidad de 1/6 de revivir con medio corazón de alma"
}
local WikiDescription = helper.GenerateEncyclopediaPage("On player death, you have a 1/6 chance of reviving with half a heart.", "- Additional copies of the passive grant an extra revival chance up to 3/6.")

local ReviveTag = string.format("%sRevive", Tag)

local function PostRevive()
	local sfx = lootdeck.sfx
	helper.ForEachPlayer(function(p, data)
		if data[Tag] and (data[Tag.."PreviousRoomIndex"] == Game():GetLevel():GetCurrentRoomIndex()) then
			if p:GetPlayerType() == PlayerType.PLAYER_KEEPER or p:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
				p:AddHearts(-1)
				p:AddHearts(1)
			end
			p:AnimateCollectible(Id)
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, p.Position, Vector.Zero, nil)
			poof.Color = Color(0,0,0,1,0.5,0.5,0.5)
			sfx:Play(SoundEffect.SOUND_HOLY,1,0)
            data[Tag] = nil
			data[ReviveTag] = nil
			data[Tag.."PreviousRoomIndex"] = nil
		end
	end)
end

local function MC_ENTITY_TAKE_DMG(_, entity, damage)
	local p = entity:ToPlayer()
	if p then
		local data = helper.GetLootDeckData(p)
		local twin = p:GetOtherTwin()
		if (p:HasCollectible(Id) or (twin and twin:HasCollectible(Id))) and damage >= helper.GetTotalHearts(p) then
			data[ReviveTag] = false
			if lootdeck.debug[Tag] or helper.PercentageChance((100/6) * p:GetCollectibleNum(Id), 50) then
				data[Tag] = true
				data[ReviveTag] = true
			end
		end
	end
end

local function MC_POST_NEW_ROOM()
	PostRevive()
end

local function MC_POST_PLAYER_UPDATE(_, p)
  helper.RevivePlayerPostPlayerUpdate(p, Tag, PostRevive)
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
            ModCallbacks.MC_ENTITY_TAKE_DMG,
            MC_ENTITY_TAKE_DMG,
            EntityType.ENTITY_PLAYER
        },
        {
            ModCallbacks.MC_POST_NEW_ROOM,
            MC_POST_NEW_ROOM
        },
        {
            ModCallbacks.MC_POST_PLAYER_UPDATE,
            MC_POST_PLAYER_UPDATE
        }
    }
}

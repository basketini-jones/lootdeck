local H = {}

-- helper function for using FindRandomEnemy with noDupes, resets chosen enemy counter in case of multiple uses of tower card, for example
function H.ClearChosens(pos)
    local entities = Isaac.FindInRadius(pos, 875, EntityPartition.ENEMY)
    for i, entity in pairs(entities) do
        local data = entity:GetData()
        if data.chosen then
            data.chosen = nil
        end
    end
end

function H.ListEnemiesInRoom(pos, ignoreChosen, tag)
	local entities = Isaac.FindInRadius(pos, 1875, EntityPartition.ENEMY)
	local enemies = {}
	local key = 1;
	for i, entity in pairs(entities) do
		if entity:IsVulnerableEnemy() and (ignoreChosen or not entity:GetData().chosen) then
            if not tag or entity:GetData()[tag] then
                enemies[key] = entities[i]
                key = key + 1;
            end
		end
	end
	return enemies
end

function H.ListBossesInRoom(pos)
	local enemies = H.ListEnemiesInRoom(pos, true)
    local bosses = {}

    for _, enemy in pairs(enemies) do
        if enemy:IsBoss() and enemy:IsVulnerableEnemy() then
            table.insert(bosses, enemy)
        end
    end

    return bosses
end

-- function for finding target enemy, then calculating the angle/position the fire will spawn
function H.FindRandomEnemy(pos, noDupes, ignoreChosen, tag)
	local enemies = H.ListEnemiesInRoom(pos, ignoreChosen, tag)
    local chosenEnt = enemies[lootdeck.rng:RandomInt(#enemies)+1]
    if chosenEnt then chosenEnt:GetData().chosen = noDupes end
    return chosenEnt
end

-- function for registering basic loot cards that spawn items
function H.SimpleLootCardSpawn(p, spawnType, spawnVariant, spawnSubtype, uses, position, sound, effect, effectAmount)
    if effect then
        for i=1,(effectAmount or 1) do
            Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, position or p.Position, Vector.FromAngle(lootdeck.rng:RandomInt(360)), p)
        end
    end
    if sound then
        lootdeck.sfx:Play(sound)
    end
    for i = 1,(uses or 1) do
        Isaac.Spawn(spawnType, spawnVariant or 0, spawnSubtype or 0, position or p.Position, Vector.FromAngle(lootdeck.rng:RandomInt(360)), p)
    end
end

function H.StaggerSpawn(key, p, interval, occurences, callback, onEnd, noAutoDecrement)
	local data = p:GetData()
    if data[key] == 1 then
		local timerName = string.format("%sTimer", key)
		local counterName = string.format("%sCounter", key)
		if not data[timerName] then data[timerName] = 0 end
		if not data[counterName] then data[counterName] = occurences end

        data[timerName] = data[timerName] - 1
        if data[timerName] <= 0 then
			callback(p, counterName)
            data[timerName] = interval
			if noAutoDecrement ~= 1 then
				data[counterName] = data[counterName] - 1
			end
            if data[counterName] <= 0 then
                data[key] = nil
				data[timerName] = nil
				data[counterName] = nil
				if onEnd then
					onEnd(p)
				end
            end
        end
    end
end

-- function for registering basic loot cards that copy item effects
function H.SimpleLootCardEffect(p, itemEffect, sound)
    p:UseActiveItem(itemEffect, false)
    if sound then
        lootdeck.sfx:Play(sound,1,0)
    end
end

-- function for registering basic loot cards that give items
function H.SimpleLootCardItem(p, itemID, sound)
    p:AddCollectible(itemID)
    if sound then
        lootdeck.sfx:Play(sound,1,0)
    end
end

-- function to convert tearflags to new BitSet128
function H.NewTearflag(x)
    return x >= 64 and BitSet128(0,1<<(x - 64)) or BitSet128(1<<x,0)
end

-- function to check if player can only use soul/black hearts
function H.IsSoulHeartMarty(p)
    local soulHeartMarties = {
        PlayerType.PLAYER_XXX,
        PlayerType.PLAYER_BLACKJUDAS,
        PlayerType.PLAYER_THELOST,
        PlayerType.PLAYER_THESOUL,
        PlayerType.PLAYER_JUDAS_B,
        PlayerType.PLAYER_XXX_B,
        PlayerType.PLAYER_THELOST_B,
        PlayerType.PLAYER_THESOUL_B,
        PlayerType.PLAYER_BETHANY_B,
    }
    for i,v in ipairs(soulHeartMarties) do
        if p:GetPlayerType() == v then
            return true
        end
    end
    return false
end

-- helper function for GlyphOfBalance(), makes shit less ocopmlicationsed
function H.AreTrinketsOnGround()
    local entities = Isaac.GetRoomEntities()
    for i, entity in pairs(entities) do
        if entity.Type == EntityType.ENTITY_PICKUP
        and entity.Variant == PickupVariant.PICKUP_TRINKET then
            return true
        end
    end
    return false
end

-- function that returns a consumable based on what glyph of balance would drop
function H.GlyphOfBalance(p)
    if p:GetMaxHearts() <= 0 and p:GetSoulHearts() <= 4 then
        return {PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL}
    elseif p:GetHearts() <= 1 then
        return {PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL}
    elseif p:GetNumKeys() <= 0 then
        return {PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL}
    elseif p:GetNumBombs() <= 0 then
        return {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL}
    elseif p:GetHearts() < p:GetMaxHearts() then
        return {PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL}
    elseif p:GetNumCoins() < 15 then
        return {PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY}
    elseif p:GetNumKeys() < 5 then
        return {PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL}
    elseif p:GetNumBombs() < 5 then
        return {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL}
    elseif p:GetTrinket(0) == 0 and not H.AreTrinketsOnGround() then
        return {PickupVariant.PICKUP_TRINKET, 0}
    elseif p:GetHearts() + p:GetSoulHearts() < 12 then
        return {PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL}
    else
        return {(lootdeck.rng:RandomInt(4)+1)*10, 1}
    end
end

function H.RemoveHeartsOnNewRoomEnter(player, hpValue)
    for i=1,hpValue do
		if H.GetPlayerHeartTotal(player) > 2 then
        	player:AddMaxHearts(-2)
		end
    end
end

function H.GetPlayerOrSubPlayerByType(player, type)
    if (player:GetPlayerType() == type) then
        return player
    elseif (player:GetSubPlayer():GetPlayerType() == type) then
        return player:GetSubPlayer()
    end
    return nil
end

function H.GetPlayerHeartTotal(p)
    local heartTotal = p:GetMaxHearts()
    if H.IsSoulHeartMarty(p) then heartTotal = heartTotal + p:GetSoulHearts() end
    if p:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then heartTotal = heartTotal + (p:GetBoneHearts() * 2) end
    return heartTotal
end

function H.FindHealthToAdd(p, hp)
    local heartTotal = H.GetPlayerHeartTotal(p)
    if heartTotal < p:GetHeartLimit() then
        local remainder = math.floor((p:GetHeartLimit() - heartTotal)/2)
        local amountToAdd = math.floor(hp/2)
        if remainder < amountToAdd then amountToAdd = remainder end
		return amountToAdd
    end
    return 0
end

function H.AddTemporaryHealth(p, hp) -- hp is calculated in half hearts
	local data = p:GetData()
    local amountToAdd = H.FindHealthToAdd(p, hp)
    if p:GetPlayerType() == PlayerType.PLAYER_THESOUL then
        if not data.soulHp then data.soulHp = 0 end
        data.soulHp = data.soulHp + amountToAdd
    else
        if not data.redHp then data.redHp = 0 end
        data.redHp = data.redHp + amountToAdd
    end
    p:AddMaxHearts(hp)
    p:AddHearts(hp)
    lootdeck.sfx:Play(SoundEffect.SOUND_VAMP_GULP,1,0)
end

function H.TableContains(table, element)
	for _, value in pairs(table) do
		if value == element then
	    	return true
	    end
	end
	return false
end

function H.TakeSelfDamage(p, dmg, canKill)
	local flags = (DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_NO_PENALTIES)
	if not canKill then flags = flags | DamageFlag.DAMAGE_NOKILL end
	p:TakeDamage(dmg,flags,EntityRef(p),0)
	p:ResetDamageCooldown()
end

function H.IsEntityInTable(table, entity)
	for _,v in pairs(table) do
		if entity.Type == v[1]
		and entity.Variant == v[2] or nil
		and entity.SubType == v[3] or nil then
			return true
		end
	end
	return false
end

function H.HolyMantleEffect(p, damageCooldown)
    lootdeck.sfx:Play(SoundEffect.SOUND_HOLY_MANTLE,1,0)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 11, p.Position, Vector.Zero, p)
    p:SetMinDamageCooldown(damageCooldown or 30)
end

function H.CheckFinalFloorBossKilled()
	local level = Game():GetLevel()
	local labyrinth = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH > 0
	if (lootdeck.f.floorBossCleared == 1 and not labyrinth)
	or (lootdeck.f.floorBossCleared == 2 and labyrinth) then
		return true
	end
	return false
end

function H.LengthOfTable(t)
    local num = 0
    for _ in pairs(t) do
        num = num + 1
    end
    return num
end

function H.FindItemInTableByKey(table, key, value)
    for _, item in pairs(table) do
        if item[key] == value then
            return item
        end
    end
end

function H.RevivePlayerPostPlayerUpdate(p, tag, reviveTag, callback)
    local game = Game()
    local data = p:GetData()
    local sprite = p:GetSprite()
    local level = game:GetLevel()
    local room = level:GetCurrentRoom()
    if (sprite:IsPlaying("Death") and sprite:GetFrame() == 55)
	or (sprite:IsPlaying("LostDeath") and sprite:GetFrame() == 37)
	or (sprite:IsPlaying("ForgottenDeath") and sprite:GetFrame() == 19) then
        if data[reviveTag] then
            if p:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
                p:AddBoneHearts(1)
            end
            p:Revive()
			p:SetMinDamageCooldown(60)
			if p:GetOtherTwin() then
				p:GetOtherTwin():Revive()
				p:GetOtherTwin():SetMinDamageCooldown(60)
			end
            data[tag] = true
            local enterDoor = level.EnterDoor
            local door = room:GetDoor(enterDoor)
            local direction = door and door.Direction or Direction.NO_DIRECTION
            game:StartRoomTransition(level:GetPreviousRoomIndex(),direction,0)
            level.LeaveDoor = enterDoor
            if callback then
                callback()
            end
        end
    end
end

function H.GetWeightedLootCardId()
    local cards = lootcards
    if H.LengthOfTable(cards) > 0 then
        local csum = 0
        local outcome = cards[0]
        for _, card in pairs(cards) do
            local weight = card.Weight
            local r = lootdeck.rng:RandomInt(csum + weight)
            if r >= csum then
                outcome = card
            end
            csum = csum + weight
        end
        return outcome.Id
    end
end

function H.FuckYou(p, type, variant, subtype, uses)
    lootdeck.sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ,1,0)
    if type then
        for i = 1,(uses or 1) do
            Isaac.Spawn(type, variant or 0, subtype or 0, Game():GetRoom():FindFreePickupSpawnPosition(p.Position), Vector.Zero, p)
        end
    end
end

function H.RemoveHitFamiliars(id, hitTag)
    for _,entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_FAMILIAR
        and entity.Variant == id
        and entity:GetData()[hitTag or 'hit'] == true then
            entity:Remove()
        end
    end
end

function H.FeckDechoEdmundMcmillen(player, pickup)
    return not (pickup.Variant == 90 and not (player:NeedsCharge(0) or player:NeedsCharge(1) or player:NeedsCharge(2) or player:NeedsCharge(3)))
    and not (pickup.Variant == 10 and (pickup.SubType == 1 or pickup.SubType == 2 or pickup.SubType == 5 or pickup.SubType == 9) and not player:CanPickRedHearts())
    and not (pickup.Variant == 10 and (pickup.SubType == 3 or pickup.SubType == 8 or pickup.SubType == 10) and not player:CanPickSoulHearts())
    and not (pickup.Variant == 10 and pickup.SubType == 6 and not player:CanPickBlackHearts())
    and not (pickup.Variant == 10 and pickup.SubType == 7 and not player:CanPickGoldenHearts())
    and not (pickup.Variant == 10 and pickup.SubType == 11 and not player:CanPickBoneHearts())
    and not (pickup.Variant == 10 and pickup.SubType == 12 and not player:CanPickRottenHearts())
end

function H.CanBuyPickup(player, pickup)
	if pickup.Price > -6 and pickup.Price ~= 0 and not player:IsHoldingItem() then
        if (pickup.Price == -1 and player:GetMaxHearts() >= 2)
        or (pickup.Price == -2 and player:GetMaxHearts() >= 4)
        or (pickup.Price == -3 and player:GetSoulHearts() >= 6)
        or (pickup.Price == -4 and player:GetMaxHearts() >= 2 and player:GetSoulHearts() >= 4)    -- this devil deal is affordable--and player:GetDamageCooldown() <= 0)
		then
            return true
        elseif pickup.Price > 0 and player:GetNumCoins() >= pickup.Price    -- this shop item is affordable
        and H.FeckDechoEdmundMcmillen(player, pickup) then
            return true
        end
    end
	return false
end

function H.CalculateRefund(price)
	if price == -1 then
		return {
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_PILL,
			Isaac.AddPillEffectToPool(PillEffect.PILLEFFECT_HEALTH_UP),
			1
		}
	end
	if price == -2 then
		return {
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_PILL,
			Isaac.AddPillEffectToPool(PillEffect.PILLEFFECT_HEALTH_UP),
			2
		}
	end
	if price == -3 then
		return {
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_SOUL,
			3
		}
	end
	if price == -4 then
		return {
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_PILL,
			Isaac.AddPillEffectToPool(PillEffect.PILLEFFECT_HEALTH_UP),
			1,
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_SOUL,
			2
		}
	end
	if price == -5 then
		return {
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_BLENDED,
			1
		}
	end
	return {
		EntityType.ENTITY_PICKUP,
		PickupVariant.PICKUP_COIN,
		CoinSubType.COIN_PENNY,
		price
	}
end

function H.AreEnemiesInRoom(room)
    return room:GetAliveEnemiesCount() ~= 0
end

function H.HasActiveItem(p)
    for i=0,3 do
        if p:GetActiveItem(i) ~= 0 then
            return true
        end
    end
    return false
end

return H

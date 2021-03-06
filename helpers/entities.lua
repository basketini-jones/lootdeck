function LootDeckAPI.ClearChosenEnemies(tag)
    local entities = LootDeckAPI.ListEnemiesInRoom(true)
    local count = 0
    for i, entity in pairs(entities) do
        local data = entity:GetData()
        if data[tag] then
            data[tag] = nil
            count = count + 1
        end
    end

    return count
end

local notEnemies = {
    EntityType.ENTITY_BOMBDROP,
    EntityType.ENTITY_SHOPKEEPER,
    EntityType.ENTITY_FIREPLACE,
    EntityType.ENTITY_STONEHEAD,
    EntityType.ENTITY_POKY,
    EntityType.ENTITY_ETERNALFLY,
    EntityType.ENTITY_STONE_EYE,
    EntityType.ENTITY_CONSTANT_STONE_SHOOTER,
    EntityType.ENTITY_BRIMSTONE_HEAD,
    EntityType.ENTITY_WALL_HUGGER,
    EntityType.ENTITY_GAPING_MAW,
    EntityType.ENTITY_BROKEN_GAPING_MAW,
    EntityType.ENTITY_POOP,
    EntityType.ENTITY_MOVABLE_TNT,
    EntityType.ENTITY_QUAKE_GRIMACE,
    EntityType.ENTITY_BOMB_GRIMACE,
    EntityType.ENTITY_SPIKEBALL,
    EntityType.ENTITY_DUSTY_DEATHS_HEAD,
    EntityType.ENTITY_BALL_AND_CHAIN,
    EntityType.ENTITY_GENERIC_PROP,
    EntityType.ENTITY_FROZEN_ENEMY,
}

function LootDeckAPI.ListEnemiesInRoom(ignoreVulnerability, filter)
	local entities = Isaac.GetRoomEntities()
	local enemies = {}
	for _, entity in pairs(entities) do
		if LootDeckAPI.TableContains(PartitionedEntities[EntityPartition.ENEMY], entity.Type) and not LootDeckAPI.TableContains(notEnemies, entity.Type) and (ignoreVulnerability or entity:IsVulnerableEnemy()) and (not filter or filter(entity, entity:GetData())) then
            table.insert(enemies, entity)
		end
	end
	return enemies
end

function LootDeckAPI.ListBossesInRoom(ignoreMiniBosses, filter)
	return LootDeckAPI.ListEnemiesInRoom(true, function(enemy, enemyData)
        return (not filter or filter(enemy, enemyData))
            and enemy:IsBoss()
            and (enemy.Type == EntityType.ENTITY_THE_HAUNT or enemy.Type == EntityType.ENTITY_MASK_OF_INFAMY or enemy:IsVulnerableEnemy())
            and (not ignoreMiniBosses or (ignoreMiniBosses and (enemy.SpawnerType == 0 or enemy.SpawnerType == EntityType.ENTITY_MASK_OF_INFAMY or enemy.SpawnerType == EntityType.ENTITY_THE_HAUNT)))
    end)
end

-- function for finding random enemy in the room
function LootDeckAPI.GetRandomEnemy(rng, tag, filter, ignoreVulnerability)
    if not rng then
        rng = lootdeck.rng
    end
	local enemies = LootDeckAPI.ListEnemiesInRoom(ignoreVulnerability, function(enemy, enemyData)
        return (not filter or filter(enemy, enemyData)) and (not tag or not enemyData[tag])
    end)
    local chosenEnemy = enemies[rng:RandomInt(#enemies) + 1]
    if chosenEnemy and tag then
        chosenEnemy:GetData()[tag] = true
    end
    return chosenEnemy
end

function LootDeckAPI.StaggerSpawn(tag, player, interval, occurences, callback, onEnd, noAutoDecrement)
	local data = LootDeckAPI.GetLootDeckData(player)
    if data[tag] and (type(data[tag]) ~= "number" or data[tag] > 0) then
		local timerTag = tag.."Timer"
		local counterTag = tag.."Counter"
		if not data[timerTag] then data[timerTag] = 0 end
		if not data[counterTag] then data[counterTag] = occurences end

        data[timerTag] = data[timerTag] - 1
        if data[timerTag] <= 0 then
			local previousResult

            for i = 1, data[tag] do
                previousResult = callback(counterTag, previousResult)
            end

            data[timerTag] = interval
			if not noAutoDecrement then
				data[counterTag] = data[counterTag] - 1
			end
            if data[counterTag] <= 0 then
                LootDeckAPI.StopStaggerSpawn(player, tag)
				if onEnd then
					onEnd()
				end
            end
        end
    end
end

function LootDeckAPI.StopStaggerSpawn(player, tag)
    local data = LootDeckAPI.GetLootDeckData(player)

    data[tag] = nil
    data[tag.."Timer"] = nil
    data[tag.."Counter"] = nil
end

function LootDeckAPI.ForEachEntityInRoom(callback, entityType, entityVariant, entitySubType, extraFilters)
    local filters = {
        Type = entityType,
        Variant = entityVariant,
        SubType = entitySubType
    }

    local initialEntities = Isaac.GetRoomEntities()

    for _, entity in ipairs(initialEntities) do
        local shouldReturn = true
        for entityKey, filter in pairs(filters) do
            if not shouldReturn then
                break
            end

            if filter ~= nil then
                if type(filter) == "function" then
                    shouldReturn = filter(entity[entityKey])
                else
                    shouldReturn = entity[entityKey] == filter
                end
            end
        end

        if shouldReturn and extraFilters ~= nil then
            shouldReturn = extraFilters(entity, entity:GetData())
        end

        if shouldReturn then
            callback(entity, entity:GetData())
        end
	  end
end

function LootDeckAPI.RemoveHitFamiliars(hitTag, variant)
    LootDeckAPI.ForEachEntityInRoom(function(entity)
        entity:Remove()
    end, EntityType.ENTITY_FAMILIAR, variant, nil, function(_, entityData)
        return entityData[hitTag] == true
    end)
end

function LootDeckAPI.Spawn(type, variant, subType, position, velocity, spawner, seed)
    local entity
    if seed then
        entity = Game():Spawn(type, variant or 0, position, velocity, spawner, subType or 0, seed)
    else
        entity = Isaac.Spawn(type, variant or 0, subType or 0, position, velocity, spawner)
    end

    if Isaac.GetChallenge() == lootdeckChallenges.gimmeTheLoot.Id then
        entity:GetData()[lootdeckChallenges.gimmeTheLoot.Tag] = true
    end

    return entity
end

-- function for registering basic loot cards that spawn items
function LootDeckAPI.SpawnEntity(player, type, variant, subType, count, position, sfx, effect, effectCount)
    local output = {
        entities = {},
        effects = {}
    }
    if effect then
        for i=1,(effectCount or 1) do
            local newEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, position or player.Position, Vector.FromAngle(lootdeck.rng:RandomInt(360)), player)
            table.insert(output.effects, newEffect)
        end
    end
    if sfx then
        lootdeck.sfx:Play(sfx)
    end
    for i = 1,(count or 1) do
        local entity = LootDeckAPI.Spawn(type, variant or 0, subType or 0, position or player.Position, Vector.FromAngle(lootdeck.rng:RandomInt(360)), player)

        table.insert(output.entities, entity)
    end

    return output
end

function LootDeckAPI.GetEntityByInitSeed(initSeed)
    local entities = Isaac.GetRoomEntities()

    for _, entity in pairs(entities) do
        if tostring(entity.InitSeed) == tostring(initSeed) then
            return entity
        end
    end
end

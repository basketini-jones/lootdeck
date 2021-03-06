local card = lootcardKeys.holyCard

return {
    {
        name = card.Tag.."Use",
        instructions = {
            "Use card",
            "Spawn Horf, let him shoot",
            "Go to new room"
        },
        steps = {
            {
                action = "RESTART",
                id = PlayerType.PLAYER_ISAAC
            },
            {
                action = "GIVE_CARD",
                id = card.Id
            },
            {
                action = "USE_CARD"
            },
            {
                action = "SPAWN",
                type = EntityType.ENTITY_HORF
            },
            {
                action = "WAIT_FOR_SECONDS",
                seconds = 5
            },
            {
                action = "GO_TO_DOOR"
            }
        }
    },
    {
        name = card.Tag.."Charmed",
        instructions = {
            "Use card",
            "Spawn Horf, charm him",
            "Spawn Boil, let him get shot"
        },
        steps = {
            {
                action = "RESTART",
                id = PlayerType.PLAYER_ISAAC
            },
            {
                action = "GIVE_CARD",
                id = card.Id
            },
            {
                action = "USE_CARD"
            },
            {
                action = "SPAWN",
                type = EntityType.ENTITY_HORF,
                position = function(arguments)
                    return Isaac.GetPlayer(arguments.playerIndex or 0).Position
                end
            },
            {
                action = "USE_CARD",
                id = lootcardKeys.theEmperor.Id
            },
            {
                action = "SPAWN",
                type = EntityType.ENTITY_BOIL
            },
            {
                action = "WAIT_FOR_SECONDS",
                seconds = 5
            }
        }
    }
}

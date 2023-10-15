

function bool_to_number(value)
    return value and 1 or 0
end

function table_to_string(value)
    local value = table.ToString(value, "", false)
    return string.sub(value, 2)
end

ConVars = ConVars or {}

local changed = false

ConVars.bool_config = CreateConVar("bool_config", bool_to_number(config.config), FCVAR_PROTECTED, "If true, look config file. If false take config in game and save it", 0, 1)
ConVars.number_max = CreateConVar("number_max", config.max, FCVAR_PROTECTED, "Inventory maximun slots for all player", -1, nil)
ConVars.table_access_staff = CreateConVar("table_access_staff", table_to_string(config.access_staff), FCVAR_PROTECTED, "Which group have acces to Staff Menu Inventory", nil, nil)
ConVars.bool_pickup = CreateConVar("bool_pickup", bool_to_number(config.pickup), FCVAR_PROTECTED, "Sytem pickup", 0, 1)
ConVars.bool_long_time_use = CreateConVar("bool_long_time_use", bool_to_number(config.long_time_use), FCVAR_PROTECTED, "If the player press long time on E, put in inventory", 0, 1)
ConVars.number_long_time_use_timer = CreateConVar("number_long_time_use_timer", config.long_time_use_timer, FCVAR_PROTECTED, "Time to wait when you long press on E to take an item", 0, nil)
ConVars.number_timer_take = CreateConVar("number_timer_take", config.timer_take, FCVAR_PROTECTED, "Time to wait for take an item on Inventory", 0, nil)
ConVars.number_distance = CreateConVar("number_distance", config.distance, FCVAR_PROTECTED, "Distance to take", 0, nil)
ConVars.number_distance_drop = CreateConVar("number_distance_drop", config.distance_drop, FCVAR_PROTECTED, "Distance to drop the item", 0, nil)
ConVars.bool_long_time_take_weapon = CreateConVar("bool_long_time_take_weapon", bool_to_number(config.long_time_take_weapon), FCVAR_PROTECTED, "When you press long time on take button, put the current weapon in inventory", 0, 1)
ConVars.number_timer_take_weapon = CreateConVar("number_timer_take_weapon", config.timer_take_weapon, FCVAR_PROTECTED, "Time to wait for take the current weapon with take button", 0, nil)
ConVars.bool_message = CreateConVar("bool_message", bool_to_number(config.message), FCVAR_PROTECTED, "Send message to players", 0, 1)
ConVars.bool_keep_inventory = CreateConVar("bool_keep_inventory", bool_to_number(config.keep_inventory), FCVAR_PROTECTED, "Players don't lose their inventory", 0, 1)
ConVars.bool_drop_inventory = CreateConVar("bool_drop_inventory", bool_to_number(config.drop_inventory), FCVAR_PROTECTED, "If keep inventory is actived, player drop his inventory", 0, 1)
ConVars.string_model_inventory = CreateConVar("string_model_inventory", config.model_inventory, FCVAR_PROTECTED, "Model3D of the inventory drop", nil, nil)
ConVars.number_height_spawn = CreateConVar("number_height_spawn", config.height_spawn, FCVAR_PROTECTED, "The height of the inventory drop", 0, nil)
ConVars.bool_drop_dispawn = CreateConVar("bool_drop_dispawn", bool_to_number(config.drop_dispawn), FCVAR_PROTECTED, "The inventory drop can dispawn", 0, 1)
ConVars.number_timer_dispawn = CreateConVar("number_timer_dispawn", config.timer_dispawn, FCVAR_PROTECTED, "Time before dispawn of the inventory drop", 0, nil)
ConVars.bool_death_inventory_gravity_gun = CreateConVar("bool_death_inventory_gravity_gun", bool_to_number(config.death_inventory_gravity_gun), FCVAR_PROTECTED, "Players can use Gravity gun on Inventory drop", 0, 1)
ConVars.bool_death_inventory_physic_gun = CreateConVar("bool_death_inventory_physic_gun", bool_to_number(config.death_inventory_physic_gun), FCVAR_PROTECTED, "Players can use Physic gun on Inventory drop", 0, 1)
ConVars.bool_death_inventory_gun_superadmin = CreateConVar("bool_death_inventory_gun_superadmin", bool_to_number(config.death_inventory_gun_superadmin), FCVAR_PROTECTED, "SuperAdmin can use Physic/Gravity gun on Inventory drop", 0, 1)
ConVars.bool_can_take_entity = CreateConVar("bool_can_take_entity", bool_to_number(config.can_take_entity), FCVAR_PROTECTED, "Players can take entity in his inventory", 0, 1)
ConVars.bool_can_take_weapon = CreateConVar("bool_can_take_weapon", bool_to_number(config.can_take_weapon), FCVAR_PROTECTED, "Players can take weapon in his inventory", 0, 1)
ConVars.bool_can_pickup_same_weapon = CreateConVar("bool_can_pickup_same_weapon", bool_to_number(config.can_pickup_same_weapon), FCVAR_PROTECTED, "Players can pickup the same weapon more than once", 0, 1)
ConVars.table_blacklist_weapon = CreateConVar("table_blacklist_weapon", table_to_string(config.blacklist_weapon), FCVAR_PROTECTED, "List Blacklist Weapon, exemple {\"weapon_357\", \"weapon_crossbow\"}", nil, nil)
ConVars.table_blacklist_entity = CreateConVar("table_blacklist_entity", table_to_string(config.blacklist_entity), FCVAR_PROTECTED, "List Blacklist Entity, exemple {\"item_ammo_357\"}", nil, nil)
ConVars.string_model_bank = CreateConVar("string_model_bank", config.model_bank, FCVAR_PROTECTED, "Model3D of the bank item", nil, nil)
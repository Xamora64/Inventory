local DoNothing = false
local config_client = config_client or {}

function changeVar(convarName, value)
    print("convarName: " .. convarName .. ", value: " .. tostring(value))

    if config_client[convarName] == nil then
    elseif config_client[convarName]:GetName() == "DCheckBoxLabel" then 
        config_client[convarName]:SetChecked(value)
    elseif config_client[convarName]:GetName() == "DTextEntry" then
        config_client[convarName]:SetValue(value)
    end

    if GetConVar(convarName) == nil then return end
    if GetConVar(convarName):GetString() != value then 
        DoNothing = true 
    end

    GetConVar(convarName):SetString(value)
end

for name, conVar in pairs(ConVars) do
    cvars.AddChangeCallback(conVar:GetName(), function(convarName, valueOld, valueNew)

        if DoNothing then DoNothing = false return end
        if not IsInGroupStaff(LocalPlayer()) and not LocalPlayer():IsSuperAdmin()
        or (convarName == "table_access_staff" and not LocalPlayer():IsSuperAdmin())
        then
            changeVar(convarName, valueOld)
            return
        end

        --print(convarName .. ": " .. valueOld .. " => " .. valueNew)
        if string.StartsWith(convarName, "number") then
            if tonumber(valueNew) == nil then return changeVar(convarName, valueOld) end

            net.Start("config_number")
            net.WriteTable({convarName, valueNew})
            net.SendToServer()
        elseif string.StartsWith(convarName, "bool") then
            if tobool(valueNew) == nil then return changeVar(convarName, valueOld) end

            net.Start("config_bool")
            net.WriteTable({convarName, valueNew})
            net.SendToServer()
        elseif string.StartsWith(convarName, "string") then
            net.Start("config_string")
            net.WriteTable({convarName, valueNew})
            net.SendToServer()
        elseif string.StartsWith(convarName, "table") then
            net.Start("config_table")
            net.WriteTable({convarName, valueNew})
            net.SendToServer()
        end

    end)    
end

hook.Add("PopulateToolMenu", "Inventory+", function()
    spawnmenu.AddToolMenuOption("Options", "Inventory+", "Inventory+", "Configuration", "", "", function(panel)
        panel:Clear()
        
        panel:SetName("Inventory+ Configuration")
        panel:Help("Only players with a group in 'Staff Access' can edit this configuration and superadmin")

        panel:Help("")
        panel:Help("If true, look config file. If false take config in game and save it")
        config_client.bool_config = panel:CheckBox( "Configuration File", "bool_config" )
        panel:ControlHelp("")
        panel:ControlHelp("Note: Need restart if you want use the config file")
        
        panel:Help("")
        panel:Help("(Note: Only SuperAdmin for this)")
        config_client.table_access_staff = panel:TextEntry( "Staff access group", "table_access_staff" )
        panel:Help("")

        config_client.number_max = panel:TextEntry( "Max Slots Inventory", "number_max" )
        config_client.bool_pickup = panel:CheckBox( "PickUp System", "bool_pickup" )
        config_client.bool_can_pickup_same_weapon = panel:CheckBox( "Players can pickup same weapon", "bool_can_pickup_same_weapon" )
        config_client.bool_long_time_use = panel:CheckBox( "Long time press 'Use Item' button put in inventory", "bool_long_time_use" )
        config_client.number_long_time_use_timer = panel:TextEntry( "Timer (seconds)", "number_long_time_use_timer" )
        config_client.bool_long_time_take_weapon = panel:CheckBox( "Press 'take' button long time put the current weapon", "bool_long_time_take_weapon" )
        panel:Help("in the inventory")
        config_client.bool_message = panel:CheckBox( "Print message for players", "bool_message" )
        panel:Help("")
        panel:ControlHelp("Dead drops inventories")
        config_client.bool_keep_inventory = panel:CheckBox( "Keep inventory", "bool_keep_inventory" )
        config_client.bool_drop_inventory = panel:CheckBox( "Drop inventory", "bool_drop_inventory" )
        config_client.bool_drop_dispawn = panel:CheckBox( "Dead drop dispawn", "bool_drop_dispawn" )
        config_client.number_timer_dispawn = panel:TextEntry( "Timer (seconds)", "number_timer_dispawn" )
        config_client.bool_death_inventory_gravity_gun = panel:CheckBox( "Dead drop can be take by gravity gun", "bool_death_inventory_gravity_gun" )
        config_client.bool_death_inventory_physic_gun = panel:CheckBox( "Dead drop can be take by physic gun", "bool_death_inventory_physic_gun" )
        config_client.bool_death_inventory_gun_superadmin = panel:CheckBox( "Dead drop can be take by grav/phy gun by superadmin", "bool_death_inventory_gun_superadmin" )
        panel:Help("")
        panel:ControlHelp("Can take")
        config_client.bool_can_take_entity = panel:CheckBox( "Players can take entity", "bool_can_take_entity" )
        config_client.bool_can_take_weapon = panel:CheckBox( "Players can take weapon", "bool_can_take_weapon" )
        panel:Help("")
        panel:ControlHelp("Blacklist")
        config_client.table_blacklist_weapon = panel:TextEntry( "Blacklist weapons", "table_blacklist_weapon" )
        config_client.table_blacklist_entity = panel:TextEntry( "Blacklist entities", "table_blacklist_entity" )
    end)
end)

net.Receive("config_number", function ()
    --if not IsInGroupStaff(LocalPlayer()) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local number = tonumber(netTable[2])

    local key = string.sub(name, 8, -1)
    config[key] = number

    local conVar = GetConVar(name)
    if conVar:GetFloat() == number then return end

    DoNothing = true
    conVar:SetFloat(number)
end)

net.Receive("config_bool", function ()
    --if not IsInGroupStaff(LocalPlayer()) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local bool = tobool(netTable[2])

    local key = string.sub(name, 6, -1)
    config[key] = bool

    local conVar = GetConVar(name)
    if conVar:GetBool() == bool then return end

    DoNothing = true
    conVar:SetBool(bool)
end)

net.Receive("config_string", function ()
    --if not IsInGroupStaff(LocalPlayer()) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local str = netTable[2]

    local key = string.sub(name, 8, -1)
    config[key] = str

    local conVar = GetConVar(name)
    if conVar:GetString() == str then return end

    DoNothing = true
    conVar:SetString(str)
end)

net.Receive("config_table", function ()
    --if not IsInGroupStaff(LocalPlayer()) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local tbl = netTable[2]

    print(netTable)
    print(name)
    if name == nil or tbl == nil then return end

    local key = string.sub(name, 7, -1)
    local result = util.JSONToTable(tbl)
    config[key] = result

    local conVar = GetConVar(name)
    if conVar:GetString() == tbl then return end

    DoNothing = true
    conVar:SetString(tbl)
end)

function refreshConfig()
    for name, value in pairs(config) do
        local type = type(value)
        if type == "number" then
            changeVar("number_" .. name, tostring(value))
        elseif type == "boolean" then
            changeVar("bool_" .. name, tostring(bool_to_number(value)))
        elseif type == "string" then
            changeVar("string_" .. name, value)
        elseif type == "table" then
            changeVar("table_" .. name, table_to_string(value))
        end
    end
end

net.Receive("config", function ()
    --if not IsInGroupStaff(LocalPlayer()) then return end
    local netTable = net.ReadTable()
    if netTable == nil then return end
    config = netTable
    refreshConfig()
end)

/*hook.Add("KeyPress", "key_press_use", function(ply, key)
    if (key == KEY_M) then
        if config == nil or type(config) != "table" then return end
        PrintTable(config)
    end
end )*/
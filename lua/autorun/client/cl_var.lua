local DoNothing = false

for name, conVar in pairs(ConVars) do
    cvars.AddChangeCallback(conVar:GetName(), function(convarName, valueOld, valueNew)
        print(valueNew)
        if DoNothing then DoNothing = false return end
        if not IsInGroupStaff(LocalPlayer()) then
            DoNothing = true
            GetConVar(convarName):SetString(valueOld)
            return
        end

        print(convarName .. ": " .. valueOld .. " => " .. valueNew)
        local key = convarName
        if string.StartsWith(convarName, "number") then
            net.Start("config_number")
            net.WriteTable({convarName, valueNew})
            net.SendToServer()
        elseif string.StartsWith(convarName, "bool") then
            net.Start("config_bool")
            net.WriteTable({convarName, valueNew})
            net.SendToServer()
        elseif string.StartsWith(convarName, "string") then
            net.Start("config_string")
            net.WriteTable({convarName, valueNew})
            net.SendToServer()
        elseif string.StartsWith(convarName, "table") then
            key = string.sub(convarName, 7, -1)
            valueNew = string.Replace(valueNew, "{", "[")
            valueNew = string.Replace(valueNew, "}", "]")
            net.Start("config_table")
            net.WriteTable({convarName, valueNew})
            net.SendToServer()
        end
    end)    
end

hook.Add("PopulateToolMenu", "Inventory+_HUDOption", function()
    spawnmenu.AddToolMenuOption("Options", "Inventory+", "Inventory+_HUDOption_Client", "Configuration", "", "", function(panel)
        panel:SetName("Inventory+ Configuration")


        local maxSlots = panel:TextEntry( "Max Slots Inventory", "number_max" )
        local maxSlots = panel:TextEntry( "Staff access group", "table_acces_staff" )
        local pickup = panel:CheckBox( "PickUp System", "bool_pickup" )
        local pickup = panel:CheckBox( "Long time press 'E' put in inventory", "bool_long_time_use" )
        local maxSlots = panel:TextEntry( "Max Slots Inventory", "number_long_time_use_timer" )
        local pickup = panel:CheckBox( "Long time press take button put the current weapon in inventory", "bool_long_time_take_weapon" )
        local pickup = panel:CheckBox( "Print message for players", "bool_message" )
        local pickup = panel:CheckBox( "Keep inventory", "bool_keep_inventory" )
        local pickup = panel:CheckBox( "Drop inventory", "bool_drop_inventory" )
        local pickup = panel:CheckBox( "Dead drop dispawn", "bool_drop_dispawn" )
        local pickup = panel:CheckBox( "Dead drop can be take by gravity gun", "bool_death_inventory_gravity_gun" )
        local pickup = panel:CheckBox( "Dead drop can be take by physic gun", "bool_death_inventory_physic_gun" )
        local pickup = panel:CheckBox( "Dead drop can be take by gravity/physic gun by superadmin", "bool_death_inventory_gun_superadmin" )
        local pickup = panel:CheckBox( "Players can take entity", "bool_can_take_entity" )
        local pickup = panel:CheckBox( "Players can take weapon", "bool_can_take_weapon" )
        local pickup = panel:CheckBox( "Players can pickup same weapon", "bool_can_pickup_same_weapon" )
        local maxSlots = panel:TextEntry( "Staff access group", "table_blacklist_weapon" )
        local maxSlots = panel:TextEntry( "Staff access group", "table_blacklist_entity" )
        local maxSlots = panel:TextEntry( "Staff access group", "string_model_bank" )

    end)
end)

net.Receive("config_number", function ()
    if not IsInGroupStaff(LocalPlayer()) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local number = tonumber(netTable[2])

    local conVar = GetConVar(name)
    if conVar:GetString() == number then return end

    DoNothing = true
    conVar:SetFloat(number)
end)

net.Receive("config_bool", function ()
    if not IsInGroupStaff(LocalPlayer()) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local bool = tobool(netTable[2])

    local conVar = GetConVar(name)
    if conVar:GetString() == bool then return end

    DoNothing = true
    conVar:SetBool(bool)
end)

net.Receive("config_string", function ()
    if not IsInGroupStaff(LocalPlayer()) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local str = netTable[2]

    local conVar = GetConVar(name)
    if conVar:GetString() == str then return end

    DoNothing = true
    conVar:SetString(str)
end)

net.Receive("config_table", function ()
    if not IsInGroupStaff(LocalPlayer()) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local tbl = netTable[2]

    local conVar = GetConVar(name)
    if conVar:GetString() == tbl then return end

    DoNothing = true
    conVar:SetString(tbl)
end)

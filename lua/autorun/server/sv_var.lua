nets = {
    // 
    "config",

    // {name, value}
    "config_string",
    "config_number",
    "config_bool",
    "config_table",

    "config_ask",
}

for _, packet in ipairs(nets) do
    util.AddNetworkString(packet)
end

for name, conVar in pairs(ConVars) do
    cvars.AddChangeCallback(conVar:GetName(), function(convarName, oldValue, valueNew)
        if changed then changed = false return end

        --print("server: " .. convarName .. ": " .. oldValue .. " => " .. valueNew)
        if string.StartsWith(convarName, "number") then
            UpdateConfigPlayers("config_number", {convarName, setConVarNumber(convarName, tonumber(valueNew)), 32})
        elseif string.StartsWith(convarName, "bool") then
            print("0")
            UpdateConfigPlayers("config_bool", {convarName, setConVarBool(convarName, tobool(valueNew))})
        elseif string.StartsWith(convarName, "string") then
            UpdateConfigPlayers("config_string", {convarName, setConVarstring(convarName, valueNew)})
        elseif string.StartsWith(convarName, "table") then
            UpdateConfigPlayers("config_table", {convarName, setConVarstringTable(convarName, valueNew, oldValue)})
        end
    end)    
end

function setConVarNumber(name, nbr)
    local key = string.sub(name, 8, -1)
    local value = tonumber(nbr)
    config[key] = value
    return value
end

function setConVarBool(name, bool)
    local key = string.sub(name, 6, -1)
    local value = tobool(bool)
    config[key] = value
    return value
end

function setConVarstring(name, str)
    local key = string.sub(name, 8, -1)
    config[key] = str
    return str
end

function setConVarstringTable(name, tbl, oldValue)
    local key = string.sub(name, 7, -1)
    local newTbl = tbl
    newTbl = string.Replace(newTbl, "{", "[")
    newTbl = string.Replace(newTbl, "}", "]")
    newTbl = string.Replace(newTbl, "'", "\"")
    local result = util.JSONToTable(newTbl)
    if result ~= nil then
        config[key] = result
        return newTbl
    else
        changed = true
        GetConVar(name):SetString(oldValue)
        return oldValue
    end
end


net.Receive("config_number", function (len, ply)
    if not IsInGroupStaff(ply) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local number = tonumber(netTable[2])

    GetConVar(name):SetFloat(number)
end)

net.Receive("config_bool", function (len, ply)
    if not IsInGroupStaff(ply) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local bool = tobool(netTable[2])

    print("1")
    GetConVar(name):SetBool(bool)
end)

net.Receive("config_string", function (len, ply)
    if not IsInGroupStaff(ply) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local str = netTable[2]

    GetConVar(name):SetString(str)
end)

net.Receive("config_table", function (len, ply)
    if not IsInGroupStaff(ply) then return end
    local netTable = net.ReadTable()
    local name = netTable[1]
    local tbl = netTable[2]

    if name == "table_access_staff" and not ply:IsSuperAdmin() then 
        UpdateConfigPlayers("config_table", {name, GetConVar(name):GetString()})
        return
    end

    GetConVar(name):SetString(tbl)
end)

// sends: {name, value}
function UpdateConfigPlayers(packet, sends)
    if packet == nil or sends == nil then return end

    print("2")
    ConfigSave()

    for _, ply in ipairs(player.GetAll()) do
        if (not config.player_see_config and not IsInGroupStaff(ply)) then return end
        net.Start(packet)
        net.WriteTable(sends)
        net.Send(ply)
    end
end

// sends: {name, value}
function UpdateConfigPlayer(ply)
    if (not config.player_see_config and not IsInGroupStaff(ply)) then return end

    net.Start("config")
    net.WriteTable(config)
    net.Send(ply)
end


net.Receive("config_ask", function (len, ply)
    if not IsInGroupStaff(ply) then return end

    net.Start("config_ask")
    net.WriteTable(config)
end)

hook.Add( "Initialize", "Server Start", function()
	MsgC(Color(50, 0, 180), "~[Loading Inventory Configuration]~\n")
    FirstConfigLoad()
end )

function ConfigSave()
    if not file.Exists("inventory_xamora", "DATA") then file.CreateDir("inventory_xamora") end
    file.Write("inventory_xamora/config.txt", util.TableToJSON(config, true))
end

function FirstConfigLoad()
    local data_config = file.Read("inventory_xamora/config.txt")
    if not data_config then return nil end

    local pre_config = util.JSONToTable(data_config)
    config.config = pre_config.config
    if pre_config.config then return end
    config = util.JSONToTable(data_config)

    return config
end

hook.Add("PlayerInitialSpawn", "InitConfig", function (ply) 
    UpdateConfigPlayer(ply)
end)

hook.Add( "PlayerButtonDown", "key_get_group", function( ply, key )
    
    if key == KEY_O then
        local group = ply:GetUserGroup()
        ply:ChatPrint(group)
    elseif key == KEY_P then
        if (config == nil or type(config) != "table") then return end
        PrintTable(config)
    end

end )
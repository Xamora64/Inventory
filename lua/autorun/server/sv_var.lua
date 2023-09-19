nets = {
    // {name, value}
    "config_string",
    "config_number",
    "config_bool",
    "config_table",
}

for _, packet in ipairs(nets) do
    util.AddNetworkString(packet)
end

for name, conVar in pairs(ConVars) do
    cvars.AddChangeCallback(conVar:GetName(), function(convarName, oldValue, valueNew)
        if changed then changed = false return end

        print("server: " .. convarName .. ": " .. oldValue .. " => " .. valueNew)
        local key = convarName
        if string.StartsWith(convarName, "number") then
            UpdateConfig("config_number", {convarName, setConVarNumber(convarName, tonumber(valueNew)), 32})
        elseif string.StartsWith(convarName, "bool") then
            UpdateConfig("config_bool", {convarName, setConVarBool(convarName, tobool(valueNew))})
        elseif string.StartsWith(convarName, "string") then
            UpdateConfig("config_string", {convarName, setConVarstring(convarName, valueNew)})
        elseif string.StartsWith(convarName, "table") then
            UpdateConfig("config_table", {convarName, setConVarstringTable(convarName, valueNew, oldValue)})
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
    key = string.sub(name, 7, -1)
    tbl = string.Replace(tbl, "{", "[")
    tbl = string.Replace(tbl, "}", "]")
    local result = util.JSONToTable(tbl)
    print(result)
    if result ~= nil then
        config[key] = result
        return result
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

    GetConVar(name):SetString(tbl)
end)

// sends {name, value}
function UpdateConfig(packet, sends)
    for _, ply in ipairs(player.GetAll()) do
        if not IsInGroupStaff(ply) then return end
        net.Start(packet)
        net.WriteTable(sends)
        net.Send(ply)
    end
end
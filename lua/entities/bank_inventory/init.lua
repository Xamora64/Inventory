AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local nets = {
    "bank_open",
    "bank_close",
    "bank_sync",

    "bank_take",
	"bank_put",
}

for k,v in ipairs(nets) do
    util.AddNetworkString(v) 
end

local list_bank = list_bank or {}

function BankInit(ply)
    BankLoad(ply)
    GetBank(ply)
    BankSync(ply)
end

function GetBank(ply)
    local bank = list_bank[ply:SteamID64()]
    if(bank == nil) then list_bank[ply:SteamID64()] = {} end
    return list_bank[ply:SteamID64()]
end

function GetBankID64(ID64)
    local bank = list_bank[ID64]
    if (bank == nil) then list_bank[ID64] = {} end
    return list_bank[ID64]
end

hook.Add("PlayerInitialSpawn", "init_bank_first_spawn", function (ply)
    BankInit(ply)
end)

function BankLoadID(ID64)
    local data = file.Read("inventory_xamora/" .. ID64 .. "/bank.txt")
    if not data then return nil end

    list_bank[ID64] = util.JSONToTable(data)
    return list_bank[ID64]
end

function BankLoad(ply)
    return BankLoadID(ply:SteamID64())
end

function BankSaveID(ID64)
    if not file.Exists("inventory_xamora", "DATA") then file.CreateDir("inventory_xamora") end
    if not file.Exists("inventory_xamora/" .. ID64, "DATA") then file.CreateDir("inventory_xamora/" .. ID64) end
    file.Write("inventory_xamora/" .. ID64 .. "/bank.txt", util.TableToJSON(list_bank[ID64], true))
    
end

function BankSave(ply)
    BankSaveID(ply:SteamID64())
    BankSync(ply)
end

function BankSync(ply)
    net.Start("bank_sync")
    net.WriteTable(GetBank(ply))
    net.Send(ply)
end

function BankOpen(ply)
	if GetBank(ply) == nil then BankInit(ply) end

    net.Start("bank_open")
    net.WriteTable(GetBank(ply))
    net.Send(ply)
end

function BankAdd(ply, item)
    if (config.max_bank >= 0) then 
        if (len_table(GetBank(ply)) >= config.max_bank) then 
            InvLog(ply, "The Bank has too many item(s)")
            return false
        end
    end

    table.insert(GetBank(ply), item)
    InvLog(ply, "Succesfully put item " .. item.classname .. " in the bank")
    BankSave(ply)
    return true
end

function BankRemoveID64(ID64, id)

    BankLoadID(ID64)
    local bank = GetBankID64(ID64)
    local itemRemoved = bank[id]
    bank[id] = nil

    BankSaveID(ID64)
    local ply = player.GetBySteamID64(ID64)
    if ply then
        BankSync(ply)
    end

	return itemRemoved
end

function BankRemove(ply, id)
    local itemRemoved = GetBank(ply)[id]
    GetBank(ply)[id] = nil

    BankSave(ply)
	return itemRemoved
end


function ENT:Initialize()

	self:SetModel(config.model_bank)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

	self:PhysWake()

end

function ENT:Use(ply, caller, use_type, value)
    BankOpen(ply)
end

net.Receive("bank_put", function (len, ply)
    if (config.max_bank >= 0) then 
        if (len_table(GetBank(ply)) >= config.max_bank) then return InvLog(ply, "The Bank has too many item(s)")end
    end

    local id = net.ReadInt(32)
    local item = InvRemoveItem(ply, id)
    BankAdd(ply, item)
end)

net.Receive("bank_take", function (len, ply)
    local id = net.ReadInt(32)
    local item = BankRemove(ply, id)
    InvGive(ply, item)
end)

hook.Add( "PhysgunPickup", "PhysgunPickupCancel", function( ply, ent )
    if ent:GetTable().PrintName == "Bank Inventory" then
		if not ply:IsSuperAdmin() then return false end
		return true
	end
end)

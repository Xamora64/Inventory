AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

list_looked_death = list_looked_death or {}
list_looked_death_ent = list_looked_death_ent or {}

function get_looked_death(ply)
    return list_looked_death[ply:SteamID64()]
end

function init_looked_death(ply)
    list_looked_death = {}
end

function set_looked_death(ply, inv)
    list_looked_death[ply:SteamID64()] = inv
end

function get_looked_death_ent(ply)
    return list_looked_death_ent[ply:SteamID64()]
end

function init_looked_death_ent(ply)
    list_looked_death_ent = {}
end

function set_looked_death_ent(ply, ent)
    list_looked_death_ent[ply:SteamID64()] = ent
end


local nets = {
    "dead_open",
    "dead_take",
    "dead_close",
}

for k,v in ipairs(nets) do
    util.AddNetworkString(v) 
end


function ENT:Initialize()
    self:SetModel(config.model_inventory)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    self:GetPhysicsObject():Wake()


	if not config.drop_dispawn then return end
    timer.Simple(config.timer_dispawn, function()
		if not IsVlid(self) then return end
		self:Remove()
	end)
end

function ENT:GravGunPickupAllowed(ply)
    return config.death_inventory_gravity_gun or (config.death_inventory_gun_superadmin and ply:IsSuperAdmin())
end

function ENT:GravGunPunt(ply)
    return false or (config.death_inventory_gun_superadmin and ply:IsSuperAdmin())
end

hook.Add( "PhysgunPickup", "PhysgunPickupCancel", function( ply, ent )
    if ent:GetTable().PrintName == "Death Inventory" then
		if config.death_inventory_gun_superadmin and ply:IsSuperAdmin() then
			return true
		elseif config.death_inventory_physic_gun then
			return true
		else
			return false
		end
    end
end )

function open_looked_death(ply, inv)
    net.Start("dead_open")
	local send = {
		inv = inv,
		numberItem = GetSizeTable(inv),
	}
    net.WriteTable(send)
    net.Send(ply)
end

function close_looked_death(ply)
    net.Start("dead_close")
    net.Send(ply)
end

function send_message_looked_death(ply, message)
    if not config.message then return end
    ply:ChatPrint(message)
end

function len_table(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function ENT:Use(activator, caller, use_type, value)
	if self.inv == nil then return end
    if len_table(self.inv) <= 0 then self:Remove() send_message_looked_death(activator, "There is no longer any item") return end

    set_looked_death(activator, self.inv)
    set_looked_death_ent(activator, self)

    open_looked_death(activator, self.inv)
end

net.Receive("dead_take", function(len, ply)
    local inv = get_looked_death(ply)
    if inv == nil then return end
    local id = net.ReadInt(32)
    local item = inv[id]
    if not item then return end

    if not InvTakeOnDeath(ply, item) then return end
    inv[id] = nil

    if len_table(inv) <= 0 then
        get_looked_death_ent(ply):Remove() 
        send_message_looked_death(ply, "There is no longer any item")
        close_looked_death(ply)
        for SteamID64, new_inv in pairs(list_looked_death) do
            local new_ply = player.GetBySteamID64(SteamID64)
            if new_ply then close_looked_death(new_ply, inv) end
        end
        return
    end

    for SteamID64, new_inv in pairs(list_looked_death) do
        local new_ply = player.GetBySteamID64(SteamID64)
        if new_ply then open_looked_death(new_ply, inv) end
    end

    open_looked_death(ply, inv)
end)

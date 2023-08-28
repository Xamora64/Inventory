AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local nets = {
    "bank_open",
    "bank_close",

    "bank_take",
	"bank_put",
}

for k,v in ipairs(nets) do
    util.AddNetworkString(v) 
end

function ENT:Initialize()

	self:SetModel( config.model_bank )
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

	self:PhysWake()

end

hook.Add( "PhysgunPickup", "PhysgunPickupCancel", function( ply, ent )
    if ent:GetTable().PrintName == "Bank Inventory" then
		if not ply:IsSuperAdmin() then return false end
		return true
	end
end)

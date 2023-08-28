AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Bank Inventory"
ENT.Category = "Inventory+"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:Initialize()

	-- We do NOT want to execute anything below in this FUNCTION on CLIENT
	if ( CLIENT ) then return end

	-- Use the helibomb model just for the shadow (because it's about the same size)
	self:SetModel( config.model_bank )
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

	self:PhysWake()

end

if ( SERVER ) then return end -- We do NOT want to execute anything below in this FILE on SERVER

function ENT:Draw()
	self:DrawModel()
end

MsgC(Color(50, 0, 180), "~[Loading Inventory]~\n")

inventory = inventory or {}
inventory.Items = {}

if SERVER then
	inventory.UseTypes = {
		weapon = function(itemData, ply)
			if ply:HasWeapon(itemData.classname) then InvLog(ply, "You already have the weapon") return false end
			ply:Give(itemData.classname, true)
			timer.Simple(0.1, function()
				if itemData.extra_ammo_clip1 > 0 then ply:GiveAmmo(itemData.extra_ammo_clip1, itemData.id_ammo_clip1) end
				if itemData.extra_ammo_clip2 > 0 then ply:GiveAmmo(itemData.extra_ammo_clip2, itemData.id_ammo_clip2) end
				if(ply:HasWeapon(itemData.classname)) then
					ply:GetWeapon(itemData.classname):SetClip1(itemData.clip1)
					ply:GetWeapon(itemData.classname):SetClip2(itemData.clip2)
				end
			end)
			return true
		end,
		model = function(itemData, ply)
			ply:SetModel(itemData.model)
			return false
		end,
		entity = function(itemData, ply)
			local ent = ents.Create(itemData.classname)
			ent:SetPos(ply:GetPos() + Vector(0, 0, 20))
			ent:SetAngles(Angle(0, 0, 0))
			ent:Spawn()
			return true
		end,
	}
end

function IsInGroupStaff (ply)
	if ply:IsSuperAdmin() then return true end
	
	local plyGroup = ply:GetUserGroup()
	if config.access_staff == nil then return end

	for _, group in ipairs(config.access_staff) do
		--print("group: " .. group .. " playerGroup: " .. plyGroup)
		if (group == plyGroup) then
			return true
		end
	end
	return false
end

function len_table(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end
local nets = {
    "inv_init",
    "inv_give",
    "inv_use",
    "inv_drop",
    "inv_remove",
    "inv_max",
    "inv_numberItem",
    "inv_sync",
    "key_new",
    "key_sync",
    "key_open",
}

for k,v in ipairs(nets) do
    util.AddNetworkString(v)
end

local list_inv = list_inv or {}

function GetInv(ply)
    local inv = list_inv[ply:SteamID64()]
    if(inv == nil) then list_inv[ply:SteamID64()] = {} end
    return list_inv[ply:SteamID64()]
end

function GetInvID64(ID64)
    local inv = list_inv[ID64]
    if(inv == nil) then list_inv[ID64] = {} end
    return list_inv[ID64]
end

function GetInvs()
    local inv = list_inv
    if(inv == nil) then list_inv = {} end
    return list_inv
end

function InvLog(ply, msg)
    if not config.message then return end

    ply:ChatPrint(msg)
end

function NameSave(ply)
	local ID = ply:SteamID64()
    if not file.Exists("inventory_xamora", "DATA") then file.CreateDir("inventory_xamora") end
    if not file.Exists("inventory_xamora/" .. ID, "DATA") then file.CreateDir("inventory_xamora/" .. ID) end
    file.Write("inventory_xamora/" .. ID .. "/name.txt", ply:Name())
end

function NameLoadID(SteamID64)
    local name = file.Read("inventory_xamora/" .. SteamID64 .. "/name.txt")
    if not name then return nil end

    return name
end

function NameLoadAll()
	local _, directories = file.Find("inventory_xamora/*", "DATA")
	local names = {}

	-- fileName = SteamID64
    for _, fileName in ipairs(directories) do
		local name = file.Read("inventory_xamora/" .. fileName .. "/name.txt")
		if not name then
			names[fileName] = nil
		else
			names[fileName] = name
		end
    end

	return names
end

function InvSave(ply)
    InvSaveID64(ply:SteamID64())
	InvSync(ply)
end

function InvSaveID64(ID64)
    if not file.Exists("inventory_xamora", "DATA") then file.CreateDir("inventory_xamora") end
    if not file.Exists("inventory_xamora/" .. ID64, "DATA") then file.CreateDir("inventory_xamora/" .. ID64) end
    file.Write("inventory_xamora/" .. ID64 .. "/inventory.txt", util.TableToJSON(GetInvID64(ID64), true))
end

function InvLoad(ply)
	return InvLoadID(ply:SteamID64())
end

function InvLoadID(ID64)
    local data_inventory = file.Read("inventory_xamora/" .. ID64 .. "/inventory.txt")
    if not data_inventory then return nil end

    list_inv[ID64] = util.JSONToTable(data_inventory)
    return list_inv[ID64]
end

function InvRemoveIllegalItem(inv, ID64)
	for id, item in pairs(inv) do
		local itemEnt = ents.Create(item.classname)

		if not IsValid(itemEnt) then
			print("Illegal item in Inventory of player: " .. util.SteamIDFrom64(ID64) .. " item_classname: " .. item.classname)
			InvRemoveItemID64(ID64, id)
		else
			itemEnt:Remove()
		end
	end
end

function InvLoadAll()
	local _, directories = file.Find("inventory_xamora/*", "DATA")
	local invs = {}

	-- fileName = SteamID64
    for _, fileName in ipairs(directories) do
		local data_inventory = file.Read("inventory_xamora/" .. fileName .. "/inventory.txt")
		if not data_inventory then
			invs[fileName] = nil
		else
			invs[fileName] = util.JSONToTable(data_inventory)
		end
    end

	return invs
end

local list_key = list_key or {}

function GetKey(ply)
    local key = list_key[ply:SteamID64()]
    if(key == nil) then list_key[ply:SteamID64()] = {key_open = config.key_open, key_take = config.key_take} end
    return list_key[ply:SteamID64()]
end

function KeySave(ply)
	local ID = ply:SteamID64()
    if not file.Exists("inventory_xamora", "DATA") then file.CreateDir("inventory_xamora") end
    if not file.Exists("inventory_xamora/" .. ID, "DATA") then file.CreateDir("inventory_xamora/" .. ID) end
    file.Write("inventory_xamora/" .. ID .. "/key.txt", util.TableToJSON(GetKey(ply), true))
	KeySync(ply)
end

function KeyLoad(ply)
    local data_key = file.Read("inventory_xamora/" .. ply:SteamID64() .. "/key.txt")
    if not data_key then return nil end

    list_key[ply:SteamID64()] = util.JSONToTable(data_key)
    return list_key[ply:SteamID64()]
end

function KeySync(ply)
    net.Start("key_sync")
    net.WriteTable(GetKey(ply))
    net.Send(ply)
end

function KeySet(ply, str, key)
    GetKey(ply)[str] = key
    KeySave(ply)
    KeySync(ply)
end

function InvSync(ply)

	InvRemoveIllegalItem(GetInv(ply), ply:SteamID64())

    net.Start("inv_sync")
    net.WriteTable(GetInv(ply))
    net.Send(ply)

	SyncNumberItem(ply)
end

net.Receive("inv_sync", function(len, ply)
	InvLoad(ply)
    InvSync(ply)
end)

function InvInit(ply)
    local count = 0
    InvLoad(ply)
    GetInv(ply)

    for i in pairs(GetInv(ply)) do count = count + 1 end
    ply.numberItem = 0
    SyncNumberItem(ply)
    InvSync(ply)
    InvSave(ply)
	NameSave(ply)

    KeyLoad(ply)
    GetKey(ply)
    KeySync(ply)
    KeySave(ply)
end

function split (str, sep)
    local new_table = {}
    for v in string.gmatch(str, "([^"..sep.."]+)") do
            table.insert(new_table, v)
    end
    return new_table
end

net.Receive("key_new", function(len, ply)
    local v = split(net.ReadString(), ",")
    KeySet(ply, v[1], tonumber(v[2]))
end)


hook.Add("PlayerInitialSpawn", "init_inv_first_spawn", function (ply)
    InvInit(ply)
end)

net.Receive("inv_init", function(len, ply)
    if not ply:IsSuperAdmin() then return end

    InvInit(ply)
end)


/*hook.Add( "PlayerButtonDown", "keyPrintEntity", function( ply, key )
    if (key ~= KEY_P) then return end

	local trace = ply:GetEyeTrace()
    ply.entity_looked = trace.Entity
	ply.props_looked = trace.SurfaceProps

    if IsValid(ply.entity_looked) then
		ply:ChatPrint("nameEntity: " .. ply.entity_looked:GetName())
		ply:ChatPrint("nameEntity: " .. ply.entity_looked:GetClass())
		if SERVER then ply:ChatPrint("SERVER") end
		if CLIENT then ply:ChatPrint("CLIENT") end
	end
    if ply.props_looked > 0 then
		ply:ChatPrint("nameProp: " .. util.GetSurfacePropName(ply.props_looked))
	end
end)*/

function InvPreTake(ply)
    local distance = ply:GetEyeTrace().Fraction * 100
    ply.entity_looked = ply:GetEyeTrace().Entity

    if not IsValid(ply.entity_looked) or distance > config.distance then return end

    timer.Create("timer_Take", config.timer_take, 1, function()

        local entity_looked_after_wait = ply:GetEyeTrace().Entity

        if(ply.entity_looked ~= entity_looked_after_wait) then return end

		if config.max >= 0 then
			if(ply.numberItem >= config.max) then InvLog(ply, "You have too many item(s)") return false end
		end

        if ply.entity_looked:IsWeapon() and config.can_take_weapon then
            InvTakeWeapon(ply, ply.entity_looked)
        elseif config.can_take_entity then
            InvTakeEntity(ply, ply.entity_looked)
        end

    end)
	return true
end

function SyncNumberItem(ply)
	local numberItem = GetSizeTable(GetInv(ply))
    ply.numberItem = numberItem
    net.Start("inv_numberItem")
    net.WriteInt(numberItem, 32)
    net.Send(ply)
end

-- Get item on death
function InvTakeOnDeath(ply, new_item)

	InvLoad(ply)
	InvSave(ply)

    if config.max >= 0 then
        if(ply.numberItem >= config.max) then InvLog(ply, "You have too many item(s)") return false end
    end
    SyncNumberItem(ply)

    table.insert(GetInv(ply), new_item)
    net.Start("inv_give")
    net.WriteTable(new_item)
    net.Send(ply)
    InvSave(ply)

    InvLog(ply, "Succesfully picked up item " .. new_item.classname)
	return true
end

function InvGive(ply, new_item)

	if config.max >= 0 then
		if(ply.numberItem >= config.max) then InvLog(ply, "You have too many item(s)") return false end
	end

    SyncNumberItem(ply)

    table.insert(GetInv(ply), new_item)
    net.Start("inv_give")
    net.WriteTable(new_item)
    net.Send(ply)
    InvSave(ply)

    InvLog(ply, "Succesfully picked up item " .. new_item.classname)
	return true
end

function InvTakeWeapon(ply, weapon)
    for _, classname in pairs(config.blacklist_weapon) do
        if(weapon:GetClass() == classname) then
            return false
        end
    end

    if config.max >= 0 then
		if(ply.numberItem >= config.max) then InvLog(ply, "You have too many item(s)") return false end
	end

    local clip1 = weapon:Clip1()
    local extra_ammo_clip1 = 0
    local id_ammo_clip1 = weapon:GetPrimaryAmmoType()
    if clip1 > weapon:GetMaxClip1() then 
        extra_ammo_clip1 = clip1 - weapon:GetMaxClip1()
        clip1 = weapon:GetMaxClip1() 
    end 

    local clip2 = weapon:Clip2()
    local extra_ammo_clip2 = 0
    local id_ammo_clip2 = weapon:GetSecondaryAmmoType()
    if clip2 > weapon:GetMaxClip2() then 
        extra_ammo_clip2 = clip2 - weapon:GetMaxClip2()
        clip2 = weapon:GetMaxClip2() 
    end

    local new_item = {
        name = weapon:GetPrintName(),
        classname = weapon:GetClass(),
        model = weapon:GetModel(),
        clip1 = clip1,
        extra_ammo_clip1 = extra_ammo_clip1,
        id_ammo_clip1 = id_ammo_clip1,
        clip2 = clip2,
        extra_ammo_clip2 = extra_ammo_clip2,
        id_ammo_clip2 = id_ammo_clip2,
        type = "weapon",
    }

    weapon:Remove()
    return InvGive(ply, new_item)
end

function InvTakeEntity(ply, entity)

    for _, classname in ipairs(config.blacklist_entity) do
        if(entity:GetClass() == classname) then
            return false
        end
    end

    if config.max >= 0 then
		if(ply.numberItem >= config.max) then InvLog(ply, "You have too many item(s)") return false end
	end

	-- This avoids entity bugging
    if entity.XamoraInventory == nil then
        if entity["OnDieFunctions"] == nil then return end

        local typeEntity = entity["OnDieFunctions"]["GetCountUpdate"]["Args"][2]

        if typeEntity ~= "sents"  then return end
    end

	local name = entity:GetClass()
	if string.len(entity:GetName()) > 0 then
		name = entity:GetName()
	end

    local new_item = {
        name = name,
        classname = entity:GetClass(),
        model = entity:GetModel(),
        type = "entity",
    }


	entity:Remove()
    return InvGive(ply, new_item)
end

function InvGetItem(ply, id)
	return GetInv(ply)[id]
end

function InvHasItem(ply, id)
	if InvGetItem(ply, id) then
		return true
	end
    return false
end

function InvRemoveItem(ply, id)

	local entityRemoved = GetInv(ply)[id]
    GetInv(ply)[id] = nil

    SyncNumberItem(ply)

    net.Start("inv_remove")
    net.WriteInt(id, 32)
    net.Send(ply)
    InvSave(ply)
	return entityRemoved
end

inventory.UseTypes = {
    weapon = function(itemData, ply)
        if ply:HasWeapon(itemData.classname) then InvLog(ply, "You already have the weapon") return false end
        ply:Give(itemData.classname, true)
        if itemData.extra_ammo_clip1 > 0 then ply:GiveAmmo(itemData.extra_ammo_clip1, itemData.id_ammo_clip1) end
        if itemData.extra_ammo_clip2 > 0 then ply:GiveAmmo(itemData.extra_ammo_clip2, itemData.id_ammo_clip2) end
        if(ply:HasWeapon(itemData.classname)) then
            ply:GetWeapon(itemData.classname):SetClip1(itemData.clip1)
            ply:GetWeapon(itemData.classname):SetClip2(itemData.clip2)
        end
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

function InvUse(ply, id)
    if InvHasItem(ply, id) then
        local itemData = InvGetItem(ply, id)
        local shouldRemove = inventory.UseTypes[itemData.type](itemData, ply)
        if shouldRemove then
            InvRemoveItem(ply, id)
            InvSave(ply)
        end
    end
end

net.Receive("inv_use", function(len, ply)
    local id = net.ReadInt(32)
	InvUse(ply, id)
end)

function InvDrop(ply, id)
    if InvHasItem(ply, id) then
        local itemData = InvGetItem(ply, id)
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * config.distance_drop,
            filter = ply,
        })
        local itemEnt = ents.Create(itemData.classname)

        itemEnt.XamoraInventory = true
        itemEnt:SetPos(tr.HitPos)
        itemEnt:SetAngles(Angle(0, 0, 0))
        itemEnt:Spawn()
        InvRemoveItem(ply, id)
        InvSave(ply)
    end
end

net.Receive("inv_drop", function(len, ply)
    local id = net.ReadInt(32)
	InvDrop(ply, id)
end)



hook.Add( "PlayerButtonDown", "key_press_open_take", function( ply, key )
    if (key == GetKey(ply)["key_open"]) then
        net.Start("key_open")
        net.Send(ply)
    elseif (key == GetKey(ply)["key_take"]) then
        ply.time_press_take_weapon = CurTime()
    end
end )


hook.Add( "PlayerButtonUp", "key_release_take_weapon", function( ply, key )
    if (key == GetKey(ply)["key_take"]) then
		if ply.time_press_take_weapon == nil then return end
		if CurTime() - ply.time_press_take_weapon >= config.timer_take_weapon and config.long_time_take_weapon then
			if InvTakeWeapon(ply, ply:GetActiveWeapon()) then
				ply:GetActiveWeapon():Remove()
			end
		else
			InvPreTake(ply)
		end
    end
end )

function InvClear(ply)
    list_inv[ply:SteamID64()] = {}
    ply.numberItem = 0
	InvSave(ply)
end

hook.Add( "PlayerDeath", "PlayerDeathRemoveInventory", function( ply, inflictor, attacker )
    if config.keep_inventory then return end
    if ply.numberItem <= 0 then return end

    local inv = GetInv(ply)
    InvClear(ply)
    if not config.drop_inventory then return end
    local itemEnt = ents.Create("death_inventory")
    itemEnt.inv = inv
    itemEnt:SetPos(Vector(ply:GetPos().x, ply:GetPos().y, ply:GetPos().z + config.height_spawn))
    itemEnt:SetAngles(Angle(0, 0, 0))
    itemEnt:Spawn()

end )

-- Staff Menu function

local staff_nets = {

	-- Receive
		-- Format : "ID64"
		"inv_ask", -- Ask Inventory of one player
		"inv_clear", -- Clear the inventory

		-- Format : ""
		"inv_asks_online", -- Ask Inventory of players connected
		"inv_asks_all", -- Ask Inventory of all players

		-- Format : "IDItem~ID64"
		"inv_staff_remove", -- Remove one item 

	-- Send
		-- Format : Table -> Inv; String -> ID64
		"inv_send", -- Send the inventory of the player
		
		-- Format : Table -> Inv
		"inv_sends_online", -- Send the inventory of players connected
		"inv_sends_all", -- Send the inventory of all players
}

for _, net in ipairs(staff_nets) do
    util.AddNetworkString(net)
end

function CheckPermission(ply)
	if not IsInGroupStaff(ply) then
		print("ERROR: '" .. ply:Name() .. "'[" .. ply:SteamID() .. "] try to get inventory of other player")
		return false
	end
	return true
end

-- "inv_ask"
net.Receive("inv_ask", function(len, ply)
	if not CheckPermission(ply) then
		return
	end
    local ID64 = net.ReadString()
	SendInvPlayer(ply, ID64)
end)

-- "inv_send"
function SendInvPlayer(asker, ID64)
    net.Start("inv_send")
	InvLoadID(ID64)
	local inv = GetInvID64(ID64)
	local send = {
		inv = inv,
		numberItem = GetSizeTable(inv),
		ID64 = ID64,
	}
	net.WriteTable(send)
    net.Send(asker)
end

net.Receive("inv_asks_online", function(len, ply)
	if not CheckPermission(ply) then
		return
	end
	SendInvPlayersOnline(ply)
end)

function SendInvPlayersOnline(asker)
	local invs = {}
	for _, ply in ipairs(player:GetAll()) do
		invs[ply:SteamID64()] = {
			name = ply:Name(),
			inv = GetInv(ply),
			numberItem = GetSizeTable(GetInv(ply)),
		}
	end
	net.Start("inv_sends_online")
	net.WriteTable(invs)
	net.Send(asker)
end

net.Receive("inv_asks_all", function(len, ply)
	if not CheckPermission(ply) then
		return
	end
	SendInvPlayersAll(ply)
end)

function SendInvPlayersAll(asker)
	local invs = InvLoadAll()
	local names = NameLoadAll()

	local sends = {}

	for ID64, inv in pairs(invs) do
		sends[ID64] = {
			name = names[ID64],
			inv = inv,
			numberItem = GetSizeTable(inv),
		}
	end

	net.Start("inv_sends_all")
	net.WriteTable(sends)
	net.Send(asker)
end

-- "inv_staff_remove"
net.Receive("inv_staff_remove", function(len, ply)
	if not CheckPermission(ply) then
		return
	end

	local splitMessage = split(net.ReadString(), "~")
	local IDItem = tonumber(splitMessage[1])
	local ID64 = splitMessage[2]

    print(IDItem)
    print(ID64)

	InvRemoveItemID64(ID64, IDItem)

	SendInvPlayer(ply, ID64)
end)

function InvRemoveItemID64(ID64, IDItem)

	InvLoadID(ID64)
	local inv = GetInvID64(ID64)
	if not inv then return end
	local entityRemoved = inv[IDItem]
	inv[IDItem] = nil

    InvSaveID64(ID64)

	local ply = player.GetBySteamID64(ID64)
	if ply then
		SyncNumberItem(ply)
		net.Start("inv_remove")
		net.WriteInt(ID64, 32)
		net.Send(ply)
        InvSync(ply)
	end

	return entityRemoved
end



-- "inv_clear"
net.Receive("inv_clear", function (len, ply)
	if not CheckPermission(ply) then
		return
	end

	local victim = player.GetBySteamID64(net.ReadString())
	InvClear(victim)
end)

function GetSizeTable(table)
	local size = 0
	for _, _ in pairs(table) do
		size = size + 1
	end
	return size
end

function GiveItemToOtherPlayer(giver, taker, id, notice)

    if config.max >= 0 then
        if taker.numberItem >= config.max then
			if notice then
				InvLog(giver, "He haves too many item(s)")
				InvLog(taker, "You have too many item(s)")
			end
			return false
		end
	end

	local ItemRemoved = InvRemoveItem(giver, id)
	if InvGive(ply, ItemRemoved) then
		print("Error Inventory: in function 'GiveItemToOtherPlayer'")
	end

end
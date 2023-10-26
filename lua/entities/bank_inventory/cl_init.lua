include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

net.Receive("bank_sync", function ()
	LocalPlayer().inv_bank = net.ReadTable()

	if LocalPlayer().inv_bank == nil then return end

	if not IsValid(inventory.Bank) or not IsValid(inventory.InventoryBank) then return end

	inventory.AskSync()
	
	OpenBank()
	OpenInventoryBank()
end)

net.Receive("bank_open", function ()
	LocalPlayer().inv_bank = net.ReadTable()

	if LocalPlayer().inv_bank == nil then return end

	inventory.AskSync()
	
	OpenBank()
	OpenInventoryBank()
end)

function OpenBank()
	local nbr_item = len_table(LocalPlayer().inv_bank)

	if IsValid(inventory.Bank) then inventory.Bank:Remove() end

    local scrw, scrh = ScrW(), ScrH()
	local width = scrw * 0.4
	local height = scrh * 0.6
	local center_x = (scrw - width) / 2
	local center_y = (scrh - height) / 2
	local x, y = 0, 0
	inventory.Bank, x, y = inventory.BackgroundCustom("Bank", nbr_item, config.max_bank, false, center_x + width / 2 + 10, center_y, width, height)
	table.insert(Panels, inventory.Bank)

	inventory.ButtonClose(x - 65, 7, inventory.Bank, function ()
		if IsValid(inventory.Bank) then inventory.Bank:Remove() end
		if IsValid(inventory.InventoryBank) then inventory.InventoryBank:Remove() end
	end) 

	local buttonsItems = {}

	local takeButton = {}
	takeButton["sizeX"] = 60
	takeButton["sizeY"] = 30
	takeButton["addX"] = 0
	takeButton["addY"] = 0
	takeButton["paint"] = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText("Take", "roboto_middle", w / 2, h / 2, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	takeButton["doClick"] = function()
		net.Start("bank_take")
		net.WriteInt(takeButton.idItem, 32)
		net.SendToServer()
	end
	table.insert(buttonsItems, takeButton)

	inventory.Inventory(inventory.Bank, x, y, LocalPlayer().inv_bank, buttonsItems)
end

function OpenInventoryBank()
	if IsValid(inventory.InventoryBank) then inventory.InventoryBank:Remove() end

    local scrw, scrh = ScrW(), ScrH()
	local width = scrw * 0.4
	local height = scrh * 0.6
	local center_x = (scrw - width) / 2
	local center_y = (scrh - height) / 2
	local x, y = 0, 0
	inventory.InventoryBank, x, y = inventory.BackgroundPosSize("Inventory", nil, center_x - width / 2 - 10, center_y, width, height)
	table.insert(Panels, inventory.InventoryBank)

	inventory.ButtonClose(x - 65, 7, inventory.InventoryBank, function ()
		if IsValid(inventory.InventoryBank) then inventory.InventoryBank:Remove() end
		if IsValid(inventory.Bank) then inventory.Bank:Remove() end
	end) 

	local buttonsItems = {}

	local putButton = {}
	putButton["sizeX"] = 60
	putButton["sizeY"] = 30
	putButton["addX"] = 0
	putButton["addY"] = 0
	putButton["paint"] = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText("Put", "roboto_middle", w / 2, h / 2, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	putButton["doClick"] = function()
		net.Start("bank_put")
		net.WriteInt(putButton.idItem, 32)
		net.SendToServer()
	end
	table.insert(buttonsItems, putButton)

	inventory.Inventory(inventory.InventoryBank, x, y, inv, buttonsItems)
end
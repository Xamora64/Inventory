local showOffline = false

-- Format : [ID64] : name, inv, numberItem, bank
local invs = invs or {}
local x = x or 0
local y = y or 0

function inventory.Staff (_x, _y)

	x = _x
	y = _y

	if IsValid(inventory.Menu) then inventory.Close() end
	if IsValid(inventory.panelStaff) then inventory.panelStaff:Close() end
	inventory.panelStaff = vgui.Create("DFrame")
	table.insert(Panels, inventory.panelStaff)

	inventory.ButtonClose(x * 0.4 - 60, 0, inventory.panelStaff, function ()
		if IsValid(inventory.panelStaff) then inventory.panelStaff:Close() end
		if IsValid(inventory.panelStaffInv) then inventory.panelStaffInv:Close() end
		inventory.Open()
	end)

	inventory.panelStaff:SetSize(x * 0.4, y * 1.2)
	inventory.panelStaff:Center()
	inventory.panelStaff:SetTitle("")
	inventory.panelStaff:MakePopup()
	inventory.panelStaff:SetDraggable(true)
	inventory.panelStaff:ShowCloseButton(false)
	inventory.panelStaff.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText("Staff Menu", "roboto_big", 2, 2, Color(255, 255, 255))
		draw.SimpleText("Show offline player", "roboto_middle", 40, 50, Color(255, 255, 255))
	end

	-- Refresh inventory of player
	inventory.ButtonStaffRefresh(inventory.panelStaff, x * 0.4 - 82 - 60, 0)

	-- show offline/online players
	inventory.ButtonStaffShow(inventory.panelStaff)

	inventory.StaffShow()
end

function inventory.ButtonStaffRefresh(parent, x, y, text)
	
	if IsValid(buttonRefresh) then buttonRefresh:Close() end
    local buttonRefresh = vgui.Create("DButton", parent)
    buttonRefresh:SetText("")
    buttonRefresh:SetSize(80, 25)
    buttonRefresh:DockMargin(10, 10, 10 ,10)
    buttonRefresh:SetPos(x, y)
    buttonRefresh.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
		if text == nil then
        	draw.SimpleText("Refresh", "roboto_middle", w / 2, h / 2, Color(240, 240, 240),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText(text, "roboto_big", w / 2, h / 2 - 4, Color(240, 240, 240),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
    end
    buttonRefresh.DoClick = function()
		if showOffline then
			net.Start("inv_asks_all")
			net.SendToServer()
		else
			net.Start("inv_asks_online")
			net.SendToServer()
		end

		inventory.ButtonStaffRefresh(parent, x, y, "⚪")

    end
end

function inventory.ButtonStaffShow(parent)
    local buttonStaffShow = vgui.Create("DButton", parent)

	local color = Color(240, 0, 0, 255)
	if showOffline then
		color = Color(0, 240, 0, 255)
	end

    buttonStaffShow:SetText("")
    buttonStaffShow:SetSize(25, 25)
    buttonStaffShow:DockMargin(10, 10, 10 ,10)
    buttonStaffShow:SetPos(8, 48)
    buttonStaffShow.Paint = function(self, w, h)
        surface.SetDrawColor(color)
        surface.DrawRect(0, 0, w, h)
    end

    buttonStaffShow.DoClick = function()
		showOffline = not showOffline
		if showOffline then
			net.Start("inv_asks_all")
			net.SendToServer()
		else
			net.Start("inv_asks_online")
			net.SendToServer()
		end
		inventory.ButtonStaffShow(parent)
	end
end

-- Current SteamID64 of the staff looking

function inventory.StaffShow()

    local posY_scroll = 80

    local scroll = vgui.Create("DScrollPanel", inventory.panelStaff)
    scroll:SetSize(inventory.panelStaff:GetWide(), inventory.panelStaff:GetTall() - posY_scroll)
    scroll:SetPos(0, scroll:GetY() + posY_scroll)

    local sbar = scroll:GetVBar()
    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255))
    end
    function sbar.btnUp:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
    end	
    function sbar.btnDown:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 255))
    end

	local sizeX = x * 0.4
	local sizeY = 30

	local posY = 0
	local gapY = 1

	for ID64, plyInfo in pairs(invs) do
		local inventoryPlayer = vgui.Create("DPanel", scroll)
        inventoryPlayer:SetSize(sizeX, 30)
        inventoryPlayer:SetPos(0, posY)
        inventoryPlayer:SetText("")

		local buttonBank = vgui.Create("DButton", inventoryPlayer)
		buttonBank:SetSize(50, 22)
        buttonBank:SetPos(sizeX - 70, 5)
        buttonBank:SetText("")

		local buttonInv = vgui.Create("DButton", inventoryPlayer)
		buttonInv:SetSize(150, 22)
        buttonInv:SetPos(sizeX - 225, 5)
        buttonInv:SetText("")

        inventoryPlayer.Paint = function(self, w, h)
			surface.SetDrawColor(100, 100, 100, 200)
            surface.DrawRect(0, 0, w, h)

			local name = plyInfo.name
			if name == nil then name = "Error" end
			if string.len(name) > 15 then
				name = string.sub(name, 0, 14)
				name = name .. "."
			end
			draw.SimpleText(name, "roboto_middle_small", 4, 6, Color(255, 255, 255))
		end

		buttonBank.Paint = function (self, w, h)
			surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, w, h)

			draw.SimpleText("Bank", "roboto_middle_small", 8, 1, Color(255, 255, 255))
		end

		buttonBank.DoClick = function ()
			net.Start("inv_ask")
			net.WriteString(ID64)
			net.SendToServer()
			inventory.StaffBank(plyInfo, ID64)
		end

		buttonInv.Paint = function (self, w, h)
			surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, w, h)

			if config.max > 0 then
				draw.SimpleText("Inventory " .. plyInfo.numberItem .. "/" .. config.max .. " items", "roboto_middle_small", 8, 1, Color(255, 255, 255))
			else
				draw.SimpleText("Inventory " .. plyInfo.numberItem .. " items", "roboto_middle_small", 8, 1, Color(255, 255, 255))
			end
		end

		buttonInv.DoClick = function ()
			net.Start("inv_ask")
			net.WriteString(ID64)
			net.SendToServer()
			inventory.StaffInv(plyInfo, ID64)
		end

		posY = posY + sizeY + gapY
	end
end

function inventory.StaffInv(plyInfo, ID64)

	if IsValid(inventory.panelStaffInv) then inventory.panelStaffInv:Close() end
	inventory.panelStaffInv = inventory.Background("Inventory of " .. plyInfo.name, plyInfo.numberItem)
	table.insert(Panels, inventory.panelStaffInv)

	inventory.ButtonClose(x - 65, 7, inventory.panelStaffInv, function ()
		if IsValid(inventory.panelStaffInv) then inventory.panelStaffInv:Close() end
	end)

	local buttonsItems = {}

	local removeButton = {}
	removeButton["ID64"] = ID64
	removeButton["sizeX"] = 70
	removeButton["sizeY"] = 30
	removeButton["addX"] = 0
	removeButton["addY"] = 0
	removeButton["paint"] = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText("Remove", "roboto_middle_small", w / 2, h / 2, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	removeButton["doClick"] = function()
			net.Start("inv_staff_remove")
			local message = removeButton.idItem .. "~" .. removeButton.ID64
			net.WriteString(message)
			net.SendToServer()
	end
	table.insert(buttonsItems, removeButton)

    local x, y = inventory.panelStaffInv:GetSize()
	inventory.Inventory(inventory.panelStaffInv, x, y, plyInfo.inv, buttonsItems)
end

function inventory.StaffBank(plyInfo, ID64)

	if IsValid(inventory.panelStaffBank) then inventory.panelStaffBank:Close() end
	inventory.panelStaffBank = inventory.BackgroundCustom("Bank of " .. plyInfo.name, len_table(plyInfo.bank), config.max_bank, true)
	table.insert(Panels, inventory.panelStaffBank)

	inventory.ButtonClose(x - 65, 7, inventory.panelStaffBank, function ()
		if IsValid(inventory.panelStaffBank) then inventory.panelStaffBank:Close() end
	end)

	local buttonsItems = {}

	local removeButton = {}
	removeButton["ID64"] = ID64
	removeButton["sizeX"] = 70
	removeButton["sizeY"] = 30
	removeButton["addX"] = 0
	removeButton["addY"] = 0
	removeButton["paint"] = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText("Remove", "roboto_middle_small", w / 2, h / 2, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	removeButton["doClick"] = function()
			net.Start("bank_staff_remove")
			local message = removeButton.idItem .. "~" .. removeButton.ID64
			net.WriteString(message)
			net.SendToServer()
	end
	table.insert(buttonsItems, removeButton)

    local x, y = inventory.panelStaffBank:GetSize()
	inventory.Inventory(inventory.panelStaffBank, x, y, plyInfo.bank, buttonsItems)
end

function StaffRefresh(plyInfo, ID64)
		if IsValid(inventory.panelStaff) then
			inventory.Staff(x, y)
		end

		if plyInfo == nil or ID64 == nil then return end

		if IsValid(inventory.panelStaffInv) then
			inventory.StaffInv(plyInfo, ID64)
		end

		if IsValid(inventory.panelStaffBank) then
			inventory.StaffBank(plyInfo, ID64)
		end
end

function clear(tableToClear)
	for value in pairs(tableToClear) do
		tableToClear[value] = nil
	end
end

net.Receive("inv_sends_online", function()
	local readTable = net.ReadTable()

	if not showOffline then
		clear(invs)
		invs = readTable
		StaffRefresh()
	end
end)

net.Receive("inv_sends_all", function()
	local readTable = net.ReadTable()

	if showOffline then
		clear(invs)
		invs = readTable
		StaffRefresh()
	end
end)

net.Receive("inv_send", function()
	local readTable = net.ReadTable()
	local ID64 = readTable.ID64

	if readTable.bank == invs[ID64].bank and readTable.inv == invs[ID64].inv then return end

	invs[ID64].bank = readTable.bank
	invs[ID64].inv = readTable.inv
	invs[ID64].numberItem = readTable.numberItem
	StaffRefresh(invs[ID64], ID64)
end)

--[[hook.Add("HUDPaint", "HUDPaint_test", function ()
    local scrw, scrh = ScrW(), ScrH()

	draw.RoundedBoxEx(10, scrw / 2, scrh / 2, 100, 100, Color(0, 0, 0, 105))
	local iconTest = Material("assets/test.png")
	surface.SetMaterial(iconTest)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(scrw / 2, scrh / 2, 100, 100)
end)--]]

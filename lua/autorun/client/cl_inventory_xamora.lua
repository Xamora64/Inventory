surface.CreateFont( "roboto_small", {
	font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(4),
} )

surface.CreateFont( "roboto_middle_small", {
	font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(6),
} )

surface.CreateFont( "roboto_middle", {
	font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(8),
} )

surface.CreateFont( "roboto_big", {
	font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(12),
} )

local inv = inv or {}

concommand.Add("inv_init", function(ply)
    local inv = {}
    net.Start("inv_init")
    net.SendToServer()
end)

net.Receive("inv_give", function()
    local new_item = net.ReadTable()
    table.insert(inv, new_item)
end)

net.Receive("inv_remove", function()
    local id = net.ReadInt(32)
    inv[id] = nil 
end)

net.Receive("inv_remove", function()
    local id = net.ReadInt(32)
    inv[id] = nil 
end)

concommand.Add("inv_sync", function()
    net.Start("inv_sync")
    net.SendToServer()
end)

net.Receive("inv_sync", function()
	local readTable = net.ReadTable()
	if readTable == inv then return end

    inv = readTable
    if IsValid(inventory.Menu) then inventory.Open() end
end)

local numberItem = numberItem or 0

net.Receive("inv_numberItem", function ()
	local readInt = net.ReadInt(32)
	if readInt == numberItem then return end
    numberItem = readInt
    if IsValid(inventory.Menu) then inventory.Open() end
end)

local key_open = config.key_open
local key_take = config.key_take
local key_admin = config.key_admin

local keys = keys or {}

net.Receive("key_sync", function()
    local keys = net.ReadTable()
    key_open = keys["key_open"]
    key_take = keys["key_take"]
end)

-- Panels of the inventory
Panels = {}

function inventory.Open()

    local ply = LocalPlayer()

    local plyinv = inv
    if not plyinv then return end
    if IsValid(inventory.Menu) then inventory.Menu:Remove() end

    inventory.Menu = vgui.Create("DFrame")
	inventory.Background(inventory.Menu, "Inventory")

    local x, y = inventory.Menu:GetSize()

	Panels = {}

	inventory.ButtonClose(x - 65, 7, inventory.Menu, inventory.Close)

	inventory.ButtonOption(x, y)

	inventory.ButtonTrade(x, y)

	if IsInGroupStaff(ply) then
		inventory.ButtonStaff(x, y)
	end

	local buttonsItems = {}

	local useButton = {}
	useButton["sizeX"] = 60
	useButton["sizeY"] = 30
	useButton["addX"] = 0
	useButton["addY"] = -16
	useButton["paint"] = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText("Use", "roboto_middle", w / 2, h / 2, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	useButton["doClick"] = function()
		net.Start("inv_use")
		net.WriteInt(useButton.idItem, 32)
		net.SendToServer()
	end
	table.insert(buttonsItems, useButton)

	local dropButton = {}
	dropButton["sizeX"] = 60
	dropButton["sizeY"] = 30
	dropButton["addX"] = 0
	dropButton["addY"] = 16
	dropButton["paint"] = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText("Drop", "roboto_middle", w / 2, h / 2, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	dropButton["doClick"] = function()
		net.Start("inv_drop")
		net.WriteInt(dropButton.idItem, 32)
		net.SendToServer()
	end
	table.insert(buttonsItems, dropButton)

	inventory.Inventory(inventory.Menu, x, y, plyinv, buttonsItems)

end

-- Panel Background, StaffMenu [Boolean], plyInfo for StaffMenu
function inventory.Background(panel, title, customNumberItem)

	local _numberItem = numberItem
	if customNumberItem ~= nil then
		_numberItem = customNumberItem
	end

    local scrw, scrh = ScrW(), ScrH()
    panel:SetSize(scrw * 0.5, scrh * 0.6)
    panel:Center()
    panel:SetTitle("")
	panel:MakePopup()
    panel:SetDraggable(true)
    panel:ShowCloseButton(false)
    panel.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 220)
        surface.DrawRect(0, 0, w, h)
        surface.DrawRect(0, 0, w, 40)
        if config.max >= 0 then 
            draw.SimpleText(title .. " " .. tostring(_numberItem) .. "/" .. tostring(config.max), "roboto_big", 10, 2, Color(255, 255, 255),  TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        else 
            draw.SimpleText(title .. " ", "roboto_big", 10, 2, Color(255, 255, 255),  TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        end
    end
end

-- Panel Parent, x, y, Inventory to print, list of button in item, StaffMenu [Boolean], plyInfo for StaffMenu
function inventory.Inventory(parent, x, y, inv, buttonsItems)


    local posX_scroll = 20
    local posY_scroll = 60

    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:SetSize(parent:GetWide() - posX_scroll * 2, parent:GetTall() - 40 * 2)
    scroll:SetPos(scroll:GetX() + posX_scroll, scroll:GetY() + posY_scroll)

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


    local size = config.size
    if config.relative_item then size = x * (config.relative_size / 10) end
    local number_case_by_line = math.floor(((x * 0.9) / size))  
    local clicked = false
    local x_item = config.x_item
    local y_item = config.y_item
    local gap_x = config.gap_x
    local gap_y = config.gap_y
    local name
    local item_clicked

    local i = 0

    for id, itemData in pairs(inv) do

        i = i + 1
        local itemPanel = vgui.Create("DButton", scroll)
        itemPanel:SetSize(size, size)
        itemPanel:SetPos(x_item, y_item)
        itemPanel:SetText("")
        x_item = x_item + size + gap_x
        if (i % number_case_by_line == 0) then
            y_item = y_item + size + gap_y
            x_item = 0
        end
        itemPanel.Paint = function(self, w, h)
            surface.SetDrawColor(200, 200, 200, 200)
            surface.DrawRect(0, 0, w, 2)
            surface.DrawRect(0, 0, 2, h)
            surface.DrawRect(w - 2, 0, w, h)
            surface.DrawRect(0, h - 2, w, h)
            surface.SetDrawColor(0, 0, 0, 225)
            surface.DrawRect(2, 2, w - 4, h - 4)
        end

        itemPanel.DoClick = function()
            if clicked then 
                if IsValid(name) then name:Remove() end
				for _, button in ipairs(buttonsItems) do
					if IsValid(button.panel) then button.panel:Remove() end
				end
                clicked = false
                if (item_clicked == id) then return end
            end
            item_clicked = id
            clicked = true

            if itemData.name then
                local x, y = itemPanel:GetPos()
                name = vgui.Create("DPanel", itemPanel)
                name:SetText(itemData.name)
                local width = 10 + string.len(itemData.name) * 6
                name:SetSize(width, 20)
                name:Center()
                name.Paint = function(self, w, h)
                    surface.SetDrawColor(255, 255, 255, 10)
                    surface.DrawRect(0, 0, w, h)
                    draw.SimpleText(itemData.name, "roboto_small", w / 2, h / 2, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end


        itemPanel.DoRightClick = function()

            if clicked then
                if IsValid(name) then name:Remove() end
				for _, button in ipairs(buttonsItems) do
					if IsValid(button.panel) then button.panel:Remove() end
				end
                clicked = false
                if (item_clicked == id) then return end
            end
            clicked = true
            item_clicked = id

			for _, button in ipairs(buttonsItems) do
				button.idItem = id
				button.panel = vgui.Create("DButton", itemPanel)
				button.panel:SetSize(button.sizeX, button.sizeY)
				button.panel:Center()
				button.panel:SetPos(button.panel:GetX() + button.addX, button.panel:GetY() + button.addY)
				button.panel:SetText("")
				button.panel.Paint = button.paint
				local doClickOriginal = button.doClick
				button.panel.DoClick = function ()
					doClickOriginal()
					for _, button in ipairs(buttonsItems) do
						if IsValid(button.panel) then button.panel:Remove() end
					end
				end
			end

		end

        local icon = vgui.Create( "DModelPanel", itemPanel)
        icon:SetSize(size, size)
        icon:SetModel(itemData.model)
        icon:SetMouseInputEnabled( false )
        icon.Entity:SetPos(icon.Entity:GetPos() - Vector(2, 1, -1))

        local num = 0.5
        local min, max = icon.Entity:GetRenderBounds()
        icon:SetCamPos(min:Distance(max) * Vector(num, num, num))
        icon:SetLookAt((max + min) / 2)

        function icon:LayoutEntity( Entity ) return end
    end
end

function inventory.ButtonOption(x, y)
    local button_setting = vgui.Create("DButton", inventory.Menu)
    button_setting:SetText("")
    button_setting:SetSize(25, 25)
    button_setting:DockMargin(10, 10, 10 ,10)
    button_setting:SetPos(x - 95, 7)
    button_setting.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("+", "roboto_middle", w / 2, h / 2 - 2, Color(240, 240, 240),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    button_setting.DoClick = function()
		inventory.Option(x, y)
	end

end

function inventory.Option(x, y)
	if IsValid(panel_setting) then panel_setting:Close() end

	panel_setting = vgui.Create("DFrame")

	table.insert(Panels, panel_setting)

	panel_setting:SetSize(x * 0.5, y * 0.7)
	panel_setting:Center()
	panel_setting:SetTitle("")
	panel_setting:MakePopup()
	panel_setting:SetDraggable(true)
	panel_setting:ShowCloseButton(false)
	panel_setting.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText("Keys Menu", "roboto_big", 2, 2, Color(255, 255, 255))
		draw.SimpleText("Key for open inventory", "roboto_middle", 180, 65, Color(255, 255, 255))
		draw.SimpleText("Key for take item in inventory", "roboto_middle", 180, 105, Color(255, 255, 255))
	end
	local button_open = vgui.Create("DBinder", panel_setting)
	button_open:SetSize(150, 30)
	button_open:SetPos(20, 60)
	button_open:SetValue(key_open)
	button_open:SetFont("roboto_middle")
	button_open.Paint = function(self, w, h)
		surface.SetDrawColor(200, 200, 200, 255)
		surface.DrawRect(0, 0, w, h)
	end
	function button_open:OnChange(num)
		key_open = num
		net.Start("key_new")
		net.WriteString("key_open," .. num)
		net.SendToServer()
	end

	local button_take = vgui.Create("DBinder", panel_setting)
	button_take:SetSize(150, 30)
	button_take:SetPos(20, 100)
	button_take:SetValue(key_take)
	button_take:SetFont("roboto_middle")
	button_take.Paint = function(self, w, h)
		surface.SetDrawColor(200, 200, 200, 255)
		surface.DrawRect(0, 0, w, h)
	end
	function button_take:OnChange(num)
		key_take = num
		net.Start("key_new")
		net.WriteString("key_take," .. num)
		net.SendToServer()
	end

	inventory.ButtonClose(x * 0.5 - 60, 0, panel_setting, function ()
		if IsValid(panel_setting) then panel_setting:Close() end
	end)
end

hook.Add("PreRender", "close_on_escape", function()
	if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
		inventory.Close()
	end
end)

function inventory.Close()
	if IsValid(inventory.Menu) then inventory.Menu:Close() end
	if (Panels) then
		for _, panel in ipairs(Panels) do
			if IsValid(panel) then panel:Close() end
		end
	end
end

function inventory.ButtonClose(x, y, parent, functionClose)
    local buttonClose = vgui.Create("DButton", parent)
    buttonClose:SetText("")
    buttonClose:SetSize(60, 25)
    buttonClose:DockMargin(10, 10, 10 ,10)
    buttonClose:SetPos(x, y)
    buttonClose.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("X", "roboto_middle", w / 2, h / 2, Color(240, 240, 240),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    buttonClose.DoClick = function()
		if functionClose then
			functionClose()
		end

    end
end

function inventory.ButtonTrade(x, y)
	local buttonTrade = vgui.Create("DButton", inventory.Menu)
    buttonTrade:SetText("")
    buttonTrade:SetSize(25, 25)
    buttonTrade:DockMargin(10, 10, 10 ,10)
	buttonTrade:SetPos(x - 125, 7)
    buttonTrade.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("->", "roboto_middle_small", w / 2, h / 2 - 6, Color(240, 240, 240),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("<-", "roboto_middle_small", w / 2, h / 2 + 3, Color(240, 240, 240),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    buttonTrade.DoClick = function()

	end
end

function inventory.ButtonStaff(x, y)
	local buttonTrade = vgui.Create("DButton", inventory.Menu)
    buttonTrade:SetText("")
    buttonTrade:SetSize(25, 25)
    buttonTrade:DockMargin(10, 10, 10 ,10)
	buttonTrade:SetPos(x - 155, 7)
    buttonTrade.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("o", "roboto_middle", w / 2, h / 2 - 2, Color(150, 0, 0),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    buttonTrade.DoClick = function()
		net.Start("inv_asks_online")
		net.SendToServer()
		inventory.Staff(x, y)
	end
end

net.Receive("key_open", function()
    net.Start("inv_sync")
    net.SendToServer()
    inventory.Open()
end)

include("shared.lua")


function ENT:Draw()
    self:DrawModel()
end

net.Receive("dead_close", function()
    if IsValid(inventory.Dead) then inventory.Dead:Remove() end
end)

net.Receive("dead_open", function()

	local readTable = net.ReadTable()
	local inv = readTable.inv
	local numberItem = readTable.numberItem

    if IsValid(inventory.Dead) then inventory.Dead:Remove() end
    inventory.Dead = vgui.Create("DFrame")
	table.insert(Panels, inventory.Dead)
	inventory.Background(inventory.Dead, "Inventory of a dead", numberItem)

    local x, y = inventory.Dead:GetSize()

	inventory.ButtonClose(x - 65, 7, inventory.Dead, function ()
		if IsValid(inventory.Dead) then inventory.Dead:Remove() end
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
		net.Start("dead_take")
		net.WriteInt(takeButton.idItem, 32)
		net.SendToServer()
	end
	table.insert(buttonsItems, takeButton)

	inventory.Inventory(inventory.Dead, x, y, inv, buttonsItems)
end)

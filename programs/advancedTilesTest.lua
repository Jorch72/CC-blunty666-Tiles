local tArgs = {...}
local bridge
if type(tArgs[1]) == "string" and peripheral.getType(tArgs[1]) == "openperipheral_bridge" then
	bridge = peripheral.wrap(tArgs[1])
	bridge.clear()
else
	error("could not find bridge on side: "..tostring(tArgs[1]))
end

os.loadAPI("tiles")
os.loadAPI("guiTiles")
os.loadAPI("advancedTiles")

local function makeDraggable(mainTile, dragObject)
	local function drag(obj, button, relX, relY, absX, absY)
		mainTile:SetX(mainTile:GetX() + absX)
		mainTile:SetY(mainTile:GetY() + absY)
	end
	dragObject:SetOnDrag(drag)
end

local function newPlayerHandler(playerUUID, surfaceHandler)
	return function()
		local guiHandler = guiTiles.newGuiHandler(surfaceHandler)

		local bars
		do -- window1
			local window1 = guiTiles.newBasicWindow(surfaceHandler:AddTile(-120, 10, 1), 110, 115)
			local text = window1:AddFancyText(5, 4, 1, "Bars Window", 0x000000, 1)
			local button = window1:AddButton(73, 3, 1, "TEST", 0xff0000, 0xffffff, 0x00ff00, 0x000000)
			button:SetOnClick( function() text:SetText(math.random()) end )
			button:SetOnRelease( function() text:SetText(math.random()) end )
			bars = {
				advancedTiles.addSimpleBoxBar(window1, 5, 15, 5, 100, 20, 0xffffff, 1),
				advancedTiles.addSimpleGradientBoxBar(window1, 5, 40, 5, 100, 20, 0xffffff, 1, 0xff0000, 1, 2),
				advancedTiles.addSimpleFluidBar(window1, 5, 65, 5, 100, 20, "water", 1),
				advancedTiles.addComplexBar(window1, 5, 90, 5, 100, 20, 0x00ff00, 1),
			}
			for _, bar in ipairs(bars) do
				bar:SetClickable(false)
			end
			window1:SetScreenAnchor("RIGHT", "TOP")
			makeDraggable(window1, window1:GetBackground())
			window1:SetDrawn(true)
		end

		local graphs
		do -- window2
			local window2 = guiTiles.newBasicWindow(surfaceHandler:AddTile(-245, -195, 10), 235, 185)
			window2:AddFancyText(5, 4, 1, "Graph Window", 0x000000, 1)
			local slider = window2:AddSlider(220, 180, 1, 175, 10)
			slider:SetRotation(270)
			slider:SetOnChanged( function(percent) window2:SetOpacity(math.ceil(percent*1000)/1000) end )
			graphs = {
				advancedTiles.addBoxBarGraph(window2, 5, 15, 5, 100, 80, 0x0000ff, 0.8, 1),
				advancedTiles.addGradientBoxBarGraph(window2, 5, 100, 5, 100, 80, 0xff0000, 0.8, 1),
				advancedTiles.addFluidBarGraph(window2, 110, 15, 5, 100, 80, "lava", 0.8, 1),
				advancedTiles.addLineGraph(window2, 110, 100, 5, 100, 80, 0x00ff00, 1, 1),
			}
			for _, graph in ipairs(graphs) do
				graph:SetClickable(false)
			end
			window2:SetScreenAnchor("RIGHT", "BOTTOM")
			makeDraggable(window2, window2:GetBackground())
			window2:SetDrawn(true)
		end

		do -- window3
			local window3 = guiTiles.newBasicWindow(surfaceHandler:AddTile(10, -290, 30), 150, 280)
			
			local list, textBox
			
			local function listSelect(index, itemData)
				if itemData then
					textBox:SetText(itemData)
				end
			end
			list = window3:AddList(10, 10, 1, 130, 210, listSelect, {"This", "is a very", "important", "test of", "the new", "guiTiles", "list", "object!!!", "Is it", "Working??? really long list item name"})
			
			local function addItem(button)
				if button == 0 then
					local selected = list:GetSelected()
					if selected then
						list:AddItem(selected + 1, textBox:GetText())
					end
				end
			end
			local addItemButton = window3:AddButton(10, 230, 1, "Add", 0xff0000, 0xffffff, 0x00ff00, 0x000000)
			addItemButton:SetOnRelease(addItem)
			
			local function updateItem(button)
				if button == 0 then
					local selected = list:GetSelected()
					if selected then
						list:SetItem(selected, textBox:GetText())
					end
				end
			end
			local updateItemButton = window3:AddButton(75 - math.ceil((tiles.getStringWidth("Update") + 2)/2), 230, 1, "Update", 0xff0000, 0xffffff, 0x00ff00, 0x000000)
			updateItemButton:SetOnRelease(updateItem)
			
			local function removeItem(button)
				if button == 0 then
					local selected = list:GetSelected()
					if selected then
						list:RemoveItem(selected)
					end
				end
			end
			local removeItemButton = window3:AddButton(140 - tiles.getStringWidth("Remove") - 2, 230, 1, "Remove", 0xff0000, 0xffffff, 0x00ff00, 0x000000)
			removeItemButton:SetOnRelease(removeItem)
			
			local function textEnterFunc(text)
				local selected = list:GetSelected()
				if selected then
					list:SetItem(selected, text)
				end
			end
			textBox = window3:AddTextBox(10, 250, 1, 130, textEnterFunc)
			
			local function clearTextBox(button)
				if button == 0 then
					textBox:SetText("")
				end
			end
			local clearTextBoxButton = window3:AddButton(10, 260, 1, "Clear", 0xff0000, 0xffffff, 0x00ff00, 0x000000)
			clearTextBoxButton:SetOnRelease(clearTextBox)
			
			local currMask, pendingMask = "*", nil
			local function toggleMask(button)
				if button == 0 then
					currMask, pendingMask = pendingMask, currMask
					textBox:SetMask(currMask)
				end
			end
			local toggleMaskButton = window3:AddButton(140 - tiles.getStringWidth("Mask") - 2, 260, 1, "Mask", 0xff0000, 0xffffff, 0x00ff00, 0x000000)
			toggleMaskButton:SetOnRelease(toggleMask)
			
			window3:SetScreenAnchor("LEFT", "BOTTOM")
			makeDraggable(window3, window3:GetBackground())
			window3:SetDrawn(true)
		end
		
		do -- window4
			local function decomp(num)
				return math.floor(num/(2^16)), math.floor((num % 2^16)/(2^8)), num % 2^8
			end
			local function recomb(num1, num2, num3)
				return num1*(2^16) + num2*(2^8) + num3
			end
			local function setBackgroundColour(index, value)
				local rgb = {decomp(guiHandler:GetCaptureBackground())}
				rgb[index] = math.max(0, math.min(255, value))
				guiHandler:SetCaptureBackground(recomb(unpack(rgb)))
			end
			
			local window4 = guiTiles.newBasicWindow(surfaceHandler:AddTile(10, 10, 40), 70, 100)
			local alphaSlider = window4:AddSlider(10, 10, 0, 50, 20)
			alphaSlider:SetOnChanged(function(percent) guiHandler:SetCaptureAlpha(223*percent) end)
			alphaSlider:SetPercent(0)
			window4:AddSlider(10, 30, 0, 50, 20):SetOnChanged(function(percent) setBackgroundColour(1, math.floor(255*percent)) end)
			window4:AddSlider(10, 50, 0, 50, 20):SetOnChanged(function(percent) setBackgroundColour(2, math.floor(255*percent)) end)
			window4:AddSlider(10, 70, 0, 50, 20):SetOnChanged(function(percent) setBackgroundColour(3, math.floor(255*percent)) end)
			window4:AddFancyText(11, 11, 5, "Alpha", 0x000000, 1)
			window4:AddFancyText(11, 31, 5, "Red", 0xff0000, 1)
			window4:AddFancyText(11, 51, 5, "Green", 0x00ff00, 1)
			window4:AddFancyText(11, 71, 5, "Blue", 0x0000ff, 1)

			makeDraggable(window4, window4:GetBackground())
			window4:SetDrawn(true)
		end
		
		local updateLineGraph
		do -- window5
			local window5 = guiTiles.newBasicWindow(surfaceHandler:AddTile(-50, -50, 50), 100, 100)

			local boxPoints = {
				{x = 5, y = 5},
				{x = 5, y = 95},
				{x = 95, y = 95},
				{x = 95, y = 5},
				{x = 5, y = 5},
			}
			local border = window5:AddLineList(0x000000, 1, boxPoints)
			border:SetClickable(false)
			border:SetZ(1)

			local deltas = {-2, -1, 1, 2}
			local points, pointDeltas = {}, {}
			local numPoints = 10
			for i = 1, numPoints do
				points[i] = {x = math.random(5, 95), y = math.random(5, 95)}
				pointDeltas[i] = {x = deltas[math.random(1, 4)], y = deltas[math.random(1, 4)]}
			end
			local lineGraph = window5:AddLineList(0x000000, 1, points)
			lineGraph:SetClickable(false)
			lineGraph:SetZ(1)
			
			updateLineGraph = function()
				local currPoints = lineGraph:GetPoints()
				local newPoints = {}
				for index, point in ipairs(currPoints) do
					local currX = point.x
					local newX = point.x + pointDeltas[index].x
					if math.abs(newX - 50) > 45 then
						newX = math.max(5, math.min(95, newX))
						pointDeltas[index].x = -pointDeltas[index].x
					end
					local currY = point.y
					local newY = point.y + pointDeltas[index].y
					if math.abs(newY - 50) > 45 then
						newY = math.max(5, math.min(95, newY))
						pointDeltas[index].y = -pointDeltas[index].y
					end
					newPoints[index] = {x = newX, y = newY}
				end
				lineGraph:SetPoints(newPoints)
			end

			window5:SetScreenAnchor("MIDDLE", "MIDDLE")
			makeDraggable(window5, window5:GetBackground())
			window5:SetDrawn(true)
		end

		do -- main
			local i = 0
			local function update()
				local value = (2 + math.sin((2*math.pi*i/100) + 5) + math.cos(6*math.pi*i/100))/4
				for _, graph in ipairs(graphs) do
					graph:Update(value)
				end
				i = (i + 1) % 100
			end

			local time = os.clock()
			for i = 1, 100 do
				update()
			end
			print("Graphs generated in ", os.clock() - time, " seconds")

			local timer1, timer2 = os.startTimer(1), os.startTimer(0.05)
			while true do
				local event = {os.pullEvent()}
				guiHandler:HandleEvent(event)
				if event[1] == "timer" then
					if event[2] == timer1 then
						local percent = math.random()
						for _, bar in ipairs(bars) do
							bar:SetPercent(percent)
						end
						update()
						timer1 = os.startTimer(1)
					elseif event[2] == timer2 then
						updateLineGraph()
						timer2 = os.startTimer(0.05)
					end
				end
			end
		end
	end
end

local handler = tiles.newMultiSurfaceHandler(bridge, newPlayerHandler)

handler:Run()

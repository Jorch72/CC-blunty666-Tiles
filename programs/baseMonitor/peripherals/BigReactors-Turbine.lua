local remotePeripherals = (...)

local function round(val, decimal)
	if decimal then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

return {
	width = 170,
	height = 200,
	add = function(name, window)
		local speedBar = advancedTiles.addComplexBar(window, 10, 100, 0, 60, 30, 0x00ff00, 1)
		speedBar:SetRotation(270)
		speedBar:GetBackground():SetClickable(false)
		window:AddText(10, 31, "Speed", 0x000000)

		local inputBar = advancedTiles.addSimpleFluidBar(window, 50, 100, 0, 60, 30, "steam", 1)
		inputBar:SetRotation(270)
		inputBar:GetBackground():SetClickable(false)
		window:AddText(50, 21, "Input", 0x000000)
		window:AddText(50, 31, "Fluid", 0x000000)

		local outputBar = advancedTiles.addSimpleFluidBar(window, 90, 100, 0, 60, 30, "water", 1)
		outputBar:SetRotation(270)
		outputBar:GetBackground():SetClickable(false)
		window:AddText(90, 21, "Output", 0x000000)
		window:AddText(90, 31, "Fluid", 0x000000)

		local energyBar = advancedTiles.addComplexBar(window, 130, 100, 0, 60, 30, 0xff0000, 1)
		energyBar:SetRotation(270)
		energyBar:GetBackground():SetClickable(false)
		window:AddText(130, 31, "RF", 0x000000)

		local object = {
			windowID = window:GetUserdata()[2],
			displays = {
				speedBar = speedBar,
				inputBar = inputBar,
				outputBar = outputBar,
				energyBar = energyBar,
				statusText = window:AddText(10, 121, "Status: Offline", 0xff0000),
				engagedText = window:AddText(10, 136, "Coils: Disengaged", 0xff0000),
				rfText = window:AddText(10, 151, "Energy Output: 0 RF/t", 0x000000),
				steamText = window:AddText(10, 166, "Steam Usage: 0 mB/t", 0x000000),
				efficiencyText = window:AddText(10, 181, "Efficiency: 0%", 0x000000),
			},
			isActive = false,
			isEngaged = false,
			inputType = false,
			outputType = false,
		}

		return object
	end,
	update = function(name, object)
		local data = remotePeripherals:GetMainData(name)
		if data then
			local speedPercent = 0
			local curSpeed = data.getRotorSpeed
			local maxSpeed = 2000
			if type(curSpeed) == "number" and type(maxSpeed) == "number" then
				speedPercent = curSpeed/maxSpeed
			end
			object.displays.speedBar:SetPercent(speedPercent)

			local inputPercent = 0
			if type(data.getInputAmount) == "number" and type(data.getFluidAmountMax) == "number" then
				inputPercent = data.getInputAmount/data.getFluidAmountMax
			end
			object.displays.inputBar:SetPercent(inputPercent)
			if object.inputType ~= data.getInputType then
				object.inputType = data.getInputType
				object.displays.inputBar:GetBar():SetFluid(object.inputType)
			end

			local outputPercent = 0
			if type(data.getOutputAmount) == "number" and type(data.getFluidAmountMax) == "number" then
				outputPercent = data.getOutputAmount/data.getFluidAmountMax
			end
			object.displays.outputBar:SetPercent(outputPercent)
			if object.outputType ~= data.getOutputType then
				object.outputType = data.getOutputType
				object.displays.outputBar:GetBar():SetFluid(object.outputType)
			end

			local energyPercent = 0
			local curEnergy = data.getEnergyStored
			local maxEnergy = 1000000
			if type(curEnergy) == "number" and type(maxEnergy) == "number" then
				energyPercent = curEnergy/maxEnergy
			end
			object.displays.energyBar:SetPercent(energyPercent)

			if data.getActive ~= object.isActive then
				object.isActive = data.getActive
				if data.getActive == true then
					object.displays.statusText:SetText("Status: Online")
					object.displays.statusText:SetColor(0x00ff00)
				elseif data.getActive == false then
					object.displays.statusText:SetText("Status: Offline")
					object.displays.statusText:SetColor(0xff0000)
				end
			end

			if data.getInductorEngaged ~= object.isEngaged then
				object.isEngaged = data.getInductorEngaged
				if data.getInductorEngaged == true then
					object.displays.engagedText:SetText("Coils: Engaged")
					object.displays.engagedText:SetColor(0x00ff00)
				elseif data.getInductorEngaged == false then
					object.displays.engagedText:SetText("Coils: Disengaged")
					object.displays.engagedText:SetColor(0xff0000)
				end
			end

			if type(data.getEnergyProducedLastTick) == "number" then
				object.displays.rfText:SetText("Energy Output: "..tostring(round(data.getEnergyProducedLastTick)).." RF/t")
			end

			if type(data.getFluidFlowRate) == "number" then
				object.displays.steamText:SetText("Steam Usage: "..tostring(round(data.getFluidFlowRate)).." mB/t")
			end

			if type(data.getBladeEfficiency) == "number" then
				object.displays.efficiencyText:SetText("Efficiency: "..tostring(data.getBladeEfficiency).."%")
			end
		end
	end,
}

-- Author: R0bl0x10501050

local validClassNames = {
	['.*Frame'] = {100, 100},
	['Text.*'] = {200, 50},
	['Image.*'] = {100, 100},
	['Video.*'] = {100, 100},
	['UI.*'] = {false, false}
}

local Robin = {
	Components = {},
	Events = {
		MouseEnter = "EVENT:MouseEnter",
		MouseLeave = "EVENT:MouseLeave",
		MouseButton1Click = "EVENT:MouseButton1Click",
		MouseButton1Up = "EVENT:MouseButton1Up",
		MouseButton1Down = "EVENT:MouseButton1Down",
		MouseButton2Click = "EVENT:MouseButton2Click",
		MouseButton2Up = "EVENT:MouseButton2Up",
		MouseButton2Down = "EVENT:MouseButton2Down"
	}
}
setmetatable(Robin.Components, {
	__newindex = function()
		error("[Robin] - Cannot add Components at runtime!", 0)
	end,
	__index = function(t, k)
		local s = false
		for k2, v in pairs(validClassNames) do
			if string.match(k, k2) then
				s = v
				break
			end
		end
		if s ~= false then
			return function(params)
				if s[1] ~= false then
					params['defaultSizes'] = s
				end
				params['_class'] = k
				return params
			end
		else
			error("[Robin] - Class '"..k.."' is not a valid UI object!", 0)
		end
	end,
})

function Robin.mount(gui: GuiBase2d, instData)
	local function createInstanceFromData(data)
		local inst = Instance.new(data['_class'])
		for k, v in pairs(data) do
			if k == "_class" or k == "defaultSizes" then continue end
			if k == "Children" then
				for _, v2 in ipairs(v) do
					local childInst = createInstanceFromData(v2)
					childInst.Parent = inst
				end
				continue
			end
			if string.match(k, "EVENT:.*") then
				pcall(function()
					inst[string.match(k, "EVENT:(.*)")]:Connect(v)
				end)
			else
				local s, _ = pcall(function()
					inst[k] = v
				end)
				if not s then
					warn("[Robin] - No property named '"..k.."' on Instance of type '"..data['_class'].."'")
				end
			end
		end
		if inst.Size.X.Scale == 0 and inst.Size.X.Offset and inst.Size.Y.Scale == 0 and inst.Size.Y.Offset == 0 then
			if data["defaultSizes"] then
				inst.Size = UDim2.fromOffset(data["defaultSizes"][1], data["defaultSizes"][2])
			else
				warn("[Robin] - No size given!")
			end
		end
		return inst
	end
	
	local parentInst = createInstanceFromData(instData)
	parentInst.Parent = gui
end

return Robin

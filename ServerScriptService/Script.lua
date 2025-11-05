-- @ScriptType: Script
local p_indicator = script.point

function makeCyclePoints(area: Part): {number}
	local cyclePoints = {}
	local parts = {}
	
	-- Get vertices
	local part_CFrame = area.CFrame
	local sx, sy, sz = area.Size.X, area.Size.Y, area.Size.Z
	local max, min = 0, 0
	local factor = 32
	local increment = 4
	local surface_level = script:GetAttribute('surface_level')
	
	-- (From NavMesh attempt)
	--part_CFrame*CFrame.new(part_size.X/2, part_size.Y/2,part_size.Z/2) ----> Front Top Right
	--part_CFrame*CFrame.new(part_size.X/2, -part_size.Y/2,-part_size.Z/2) ----> Front Bottom Left
	--part_CFrame*CFrame.new(part_size.X/2, part_size.Y/2,-part_size.Z/2) ----> Front Bottom Right
	--part_CFrame*CFrame.new(-part_size.X/2, part_size.Y/2,-part_size.Z/2) ----> Front Top Left

	--part_CFrame*CFrame.new(-part_size.X/2, part_size.Y/2,part_size.Z/2) ----> Back Top Right
	--part_CFrame*CFrame.new(-part_size.X/2, -part_size.Y/2,part_size.Z/2) ----> Back Bottom Right
	--part_CFrame*CFrame.new(-part_size.X/2, -part_size.Y/2,-part_size.Z/2) ----> Back Top Left
	--part_CFrame*CFrame.new(part_size.X/2, -part_size.Y/2,part_size.Z/2) ----> Back Bottom Left
	
	for x=0, sx, increment do
		for y=0, sy, increment do
			for z=0, sz, increment do
				local index = x + (y-1) * sx + (z-1) * sx * sy
				local value = math.clamp(math.noise(x/sx,y/sy,z/sz), -1, 1) * factor
				--if value < surface_level then continue end
				cyclePoints[index] = value
				max, min = math.max(max,value), math.min(min,value)
			end
		end
	end
	
	for x=0, sx, increment do
		for y=0, sy, increment do
			for z=0, sz, increment do
				local value = math.clamp(math.noise(x/sx,y/sy,z/sz), -1, 1)
				if (value * factor) < surface_level then continue end
				local temp = p_indicator:Clone()
				local n = math.map(value, -1, 1, 0, 1)
				temp.Position = Vector3.new(x,y,z) + area.Position - area.Size/2
				temp.Color = Color3.new(n, n, n)
				temp.Parent = workspace
				table.insert(parts, temp)
			end
		end
	end
	
	local nr = NumberRange.new(min, max)
	script:SetAttribute("range", NumberRange.new(min, max))
	return cyclePoints, nr, parts
end

local surfaceLevel = 0
local target_space = workspace.Part
local points, range, parts = makeCyclePoints(target_space)
print(points, range)

local t = 0

game:GetService("RunService").Heartbeat:Connect(function(dt)
	t += dt
	
	if t < .5 then return end
	t=0
	for _, v in parts do v:Destroy() end
	points, range, parts = makeCyclePoints(target_space)
end)
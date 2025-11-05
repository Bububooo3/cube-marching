-- @ScriptType: Script
function getCyclePoints(area: Part): {number}
	local cyclePoints = {}
	
	-- Get vertices
	local part_CFrame = area.CFrame
	local sx, sy, sz = area.Size.X, area.Size.Y, area.Size.Z
	local max, min = 0, 0
	local factor = 32
	
	-- (From NavMesh attempt)
	--part_CFrame*CFrame.new(part_size.X/2, part_size.Y/2,part_size.Z/2) ----> Front Top Right
	--part_CFrame*CFrame.new(part_size.X/2, -part_size.Y/2,-part_size.Z/2) ----> Front Bottom Left
	--part_CFrame*CFrame.new(part_size.X/2, part_size.Y/2,-part_size.Z/2) ----> Front Bottom Right
	--part_CFrame*CFrame.new(-part_size.X/2, part_size.Y/2,-part_size.Z/2) ----> Front Top Left

	--part_CFrame*CFrame.new(-part_size.X/2, part_size.Y/2,part_size.Z/2) ----> Back Top Right
	--part_CFrame*CFrame.new(-part_size.X/2, -part_size.Y/2,part_size.Z/2) ----> Back Bottom Right
	--part_CFrame*CFrame.new(-part_size.X/2, -part_size.Y/2,-part_size.Z/2) ----> Back Top Left
	--part_CFrame*CFrame.new(part_size.X/2, -part_size.Y/2,part_size.Z/2) ----> Back Bottom Left
	
	for x=0, sx do
		for y=0, sy do
			for z=0, sz do
				local index = x + (y-1) * sx + (z-1) * sx * sy
				local value = math.clamp(math.noise(x/sx,y/sy,z/sz), -1, 1) * factor
				cyclePoints[index] = value
				max, min = math.max(max,value), math.min(min,value)
			end
		end
	end
	
	return cyclePoints, NumberRange.new(min, max)
end

local surfaceLevel = 0
local points, range = getCyclePoints(workspace.Part)
print(points, range)
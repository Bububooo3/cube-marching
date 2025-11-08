-- @ScriptType: Script
-- Here we see Roblox's sandboxing in full swing (ty Roblox)

-------------------
-- || GLOBALS || --
-------------------
local p_indicator = script.point
local cubeIndex = 0
local lookup, tri_table = {}, require(script:WaitForChild("triTable"))
local AssetService = game:GetService("AssetService")

-------------------
--|| FUNCTIONS ||--
-------------------
function makeCyclePoints(area: Part): {number}
	-- Get vertices
	local part_CFrame = area.CFrame
	local sx, sy, sz = area.Size.X, area.Size.Y, area.Size.Z
	local factor = 32
	local increment = sx --> Just get cube vertices
	local surface_level = script:GetAttribute('surface_level') or 1
	local vertex = 0
	
	for x=0, sx, increment do
		for y=0, sy, increment do
			for z=0, sz, increment do
				lookup[vertex+20] = math.clamp(math.noise(x/sx,y/sy,z/sz), -1, 1) * factor --> Starts @ k=0
				lookup[vertex+30] = Vector3.new(x,y,z)
				vertex += 1
			end
		end
	end

	-- Convert to standard order
	lookup[0] = lookup[21]
	lookup[1] = lookup[24]
	lookup[2] = lookup[25]
	lookup[3] = lookup[20]
	lookup[4] = lookup[23]
	lookup[5] = lookup[27]
	lookup[6] = lookup[26]
	lookup[7] = lookup[22]
	
	lookup[10] = lookup[31]
	lookup[12] = lookup[34]
	lookup[11] = lookup[35]
	lookup[13] = lookup[30]
	lookup[14] = lookup[33]
	lookup[15] = lookup[37]
	lookup[16] = lookup[36]
	lookup[17] = lookup[32]

	-- Triangulation Table (Get triangle vertices)
	for i=0, 7, 1 do
		cubeIndex = (lookup[i] >= surface_level) and bit32.bor(cubeIndex, 2^i) or cubeIndex
	end

	local triangleEdges = tri_table[cubeIndex]
	local tPoints: {Vector3} = {}
	local tInd = 0
	
	for _, v: number in triangleEdges do
		tInd += 1
		
		--[[
			0 btwn 2, 6
			1 btwn 6, 5
			2 btwn 1, 5
			3 btwn 1, 2
			4 btwn 4, 8
			5 btwn 8, 7
			6 btwn 3, 7
			7 btwn 3, 4
			8 btwn 2, 4
			9 btwn 6, 8
			10 btwn 5, 7
			11 btwn 1, 3
		]]
		
		-- Make triangles w/ midpoint
		if v==0 then
			tPoints[tInd] = (lookup[2]+lookup[6])/2
		elseif v==1 then
			tPoints[tInd] = (lookup[5]+lookup[6])/2
		elseif v==2 then
			tPoints[tInd] = (lookup[1]+lookup[5])/2
		elseif v==3 then
			tPoints[tInd] = (lookup[2]+lookup[1])/2
		elseif v==4 then
			tPoints[tInd] = (lookup[4]+lookup[8])/2
		elseif v==5 then
			tPoints[tInd] = (lookup[7]+lookup[8])/2
		elseif v==6 then
			tPoints[tInd] = (lookup[3]+lookup[7])/2
		elseif v==7 then
			tPoints[tInd] = (lookup[3]+lookup[4])/2
		elseif v==8 then
			tPoints[tInd] = (lookup[2]+lookup[4])/2
		elseif v==9 then
			tPoints[tInd] = (lookup[8]+lookup[6])/2
		elseif v==10 then
			tPoints[tInd] = (lookup[5]+lookup[7])/2
		elseif v==11 then
			tPoints[tInd] = (lookup[1]+lookup[3])/2
		end
		
		if tInd == 3 then
			-- Draw triangle from 3 positions		
			table.clear(tPoints)
			tInd = 0
		end
	end
	
	return true
end

-------------------
-- || RUNTIME || --
-------------------
local surfaceLevel = 0
local target_space = workspace.Part
local t = 0

game:GetService("RunService").Heartbeat:Connect(function(dt)
	t += dt
	
	if t < .5 then return end
	t=0
	makeCyclePoints(target_space)
end)

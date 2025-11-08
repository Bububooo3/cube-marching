-- @ScriptType: Script
-- Here we see Roblox's sandboxing in full swing (ty Roblox)

-------------------
-- || GLOBALS || --
-------------------
local cubeIndex = 0
local lookup, tri_table = {}, require(script:WaitForChild("triTable"))
local AssetService = game:GetService("AssetService")
local max, min = 0,0

-------------------
--|| FUNCTIONS ||--
-------------------
function makeCyclePoints(area: Part): {number}
	-- Get vertices
	local part_CFrame = area.CFrame
	local sx, sy, sz = area.Size.X, area.Size.Y, area.Size.Z
	local factor = 3200
	local increment = sx --> Just get cube vertices
	local surface_level = script:GetAttribute('surface_level') or 1
	local vertex = 0
	
	for x=0, sx, increment do
		for y=0, sy, increment do
			for z=0, sz, increment do
				local v = math.clamp(math.noise(area.Position.X*0.132,area.Position.Y*0.132,area.Position.Z*0.134 + os.clock()-math.floor(os.clock())), -1, 1) * factor
				print(v)
				lookup[vertex+20] =  v --> Starts @ k=0
				lookup[vertex+30] = Vector3.new(x,y,z)
				max, min = math.max(max, v), math.min(min, v)
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
		cubeIndex = (lookup[i] >= surface_level) and bit32.bor(cubeIndex, 2^i) or 2
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
			tPoints[tInd] = (lookup[10]+lookup[15])/2
		elseif v==1 then
			tPoints[tInd] = (lookup[14]+lookup[15])/2
		elseif v==2 then
			tPoints[tInd] = (lookup[10]+lookup[14])/2
		elseif v==3 then
			tPoints[tInd] = (lookup[11]+lookup[10])/2
		elseif v==4 then
			tPoints[tInd] = (lookup[13]+lookup[17])/2
		elseif v==5 then
			tPoints[tInd] = (lookup[16]+lookup[17])/2
		elseif v==6 then
			tPoints[tInd] = (lookup[12]+lookup[16])/2
		elseif v==7 then
			tPoints[tInd] = (lookup[12]+lookup[13])/2
		elseif v==8 then
			tPoints[tInd] = (lookup[11]+lookup[13])/2
		elseif v==9 then
			tPoints[tInd] = (lookup[17]+lookup[15])/2
		elseif v==10 then
			tPoints[tInd] = (lookup[14]+lookup[16])/2
		elseif v==11 then
			tPoints[tInd] = (lookup[10]+lookup[12])/2
		end
		if tInd == 3 then
			-- Draw triangle from 3 vertex positions
			local mPart = script.MeshPart:Clone()
			mPart.Anchored = true
			mPart.CanCollide = false
			mPart.Size = area.Size
			mPart.Position = area.Position
			
			local tMesh = AssetService:CreateEditableMesh()
			local v1 = tMesh:AddVertex(tPoints[1])
			local v2 = tMesh:AddVertex(tPoints[2])
			local v3 = tMesh:AddVertex(tPoints[3])
			
			tMesh:AddTriangle(v1,v2,v3)
			local obj = AssetService:CreateMeshPartAsync(Content.fromObject(tMesh))
			
			mPart.Parent = workspace.Triangles
			mPart:ApplyMesh(obj)
			
			table.clear(tPoints)
			tInd = 0
		end
	end
	
	script:SetAttribute("range", NumberRange.new(min, max))
	return true
end

-------------------
-- || RUNTIME || --
-------------------
local psl = -1
local target_space = workspace.Part
local s = target_space.Position
local t = 0

game:GetService("RunService").Heartbeat:Connect(function(dt)
	t += dt
	if psl == script:GetAttribute("surface") then return end
	if t < .5 then return end
	for _, v in workspace.Triangles:GetChildren() do v:Destroy() end
	psl = script:GetAttribute("surface")
	t=0
	for x=0, 100 do
		for y=0, 100 do
			for z=0, 100 do
				target_space.Position = s + Vector3.new(x,y,z)
				makeCyclePoints(target_space)
			end
		end
	end	
end)

--!optimize 2



-------------------
-- || GLOBALS || --
-------------------
local tConstants = require(script:WaitForChild("tConstants"))
local cPoints, ePoints, vPoints = tConstants.cornerTable, tConstants.edgeTable, tConstants.vertexTable
local AssetService = game:GetService("AssetService")
local max, min = 0,0
local vPositions, tIndices, vCache = {}, {}, {} -- right here in your own backyard!


-------------------
--|| FUNCTIONS ||--
-------------------
-- Lerp the edge, brotato
function lerpEdge(p1: Vector3, p2: Vector3, v1: number, v2: number, surface_level: number): Vector3
	if (v1==v2) then return p1 end ----> They're the same value so dv is 0 & we can't divide by that so return midpoint aka (p1+p2)/2
	
	local Dv = v2 - v1 ----> Difference in values (pretend its an uppercase delta)
	local t = math.clamp((surface_level - v1)/Dv, 0, 1)
	--^ we include surface_level as a parm instead of getting attribute so if it changes mid fxn we're consistent
	
	return p1:Lerp(p2, t)
	--^ aka p1 + (p2 - p1) * t aka getting point on edge btwn p1 and p2 to return as middle for a vertex point but its not 50/50
end


-- Make some triangles, mikebrosowski
function makeCyclePoints(area: Part): {number}
	-- Necessities
	local cubeIndex = 0 ----> Literally forgot this somehow 😢
	local tVal, tPos = {}, {}

	-- Changeables
	local factor = 3200
	local surface_level = script:GetAttribute('surface') or 1

	-- Get vertices & values the smart way ✌
	for i = 0, 7 do
		local offset = cPoints[i]
		local pWorld = area.Position + offset ----> Straight to the corner from pivot (which should be center of cube right)
		local v = math.clamp(math.noise(pWorld.X * 0.132, pWorld.Y * 0.132, pWorld.Z * 0.134 + os.clock() - math.floor(os.clock())), -1, 1) * factor

		tPos[i], tVal[i] = pWorld, v

		max, min = math.max(max, v), math.min(min, v)
	end

	-- Triangulation Table
	-- (Get triangle vertices using bitmask that shows which positions have valid values and can be used as triangle key in base 10 🤓)
	for i = 0, 7 do
		cubeIndex = (tVal[i] >= surface_level) and bit32.bor(cubeIndex, bit32.lshift(1, i)) or cubeIndex
	end

	--[[ 
	It's right this time btw
		0  btwn 0 and 1
		1  btwn 1 and 2
		2  btwn 2 and 3
		3  btwn 3 and 0
		4  btwn 4 and 5
		5  btwn 5 and 6
		6  btwn 6 and 7
		7  btwn 7 and 4
		8  btwn 0 and 4
		9  btwn 1 and 5
		10 btwn 2 and 6
		11 btwn 3 and 7
	]]
	
	-- Get all intersection points all at once for organization purposes
	local eVertices = {};
	for i = 0, 11 do
		local c1, c2 = ePoints[i][1], ePoints[i][2]
		eVertices[i] = lerpEdge(tPos[c1], tPos[c2], tVal[c1], tVal[c2], surface_level)
	end
	
	local tI = 0  ---> What vertex r we on?
	local tPoints = {} ---> Triangle data stored temporarily
	
	for _, eVal in vPoints[cubeIndex] do
		if eVal == -1 then break end --> Termination character thing
		
		table.insert(tPoints, eVertices[eVal])
		tPoints[tI] = eVertices[eVal]
		tI += 1
		
		if tI == 2 then
			tI = 0
			-- much faster mesh generation (single instead of 1 per triangle)			
			local i1 = #vPositions
			local i2, i3 = i1+1, i1+2
			
			vPositions[i1] = eVertices[tPoints[0]]
			vPositions[i2] = eVertices[tPoints[1]]
			vPositions[i3] = eVertices[tPoints[2]]
			
			table.insert(tIndices, i1)
			table.insert(tIndices, i2)
			table.insert(tIndices, i3)			
			table.clear(tPoints)
		end
	end
	
	local data = AssetService:CreateEditableMesh()
	
	for i, v in (vPositions) do data:AddVertex(v) end
	
	for i=0, #tIndices-1, 3 do
		data:AddTriangle(tIndices[i], tIndices[i+1], tIndices[i+2])
	end
	
	local mPart = script.MeshPart:Clone()
	local new = AssetService:CreateMeshPartAsync(Content.fromObject(data))
	mPart:ApplyMesh(new)
	mPart.Parent = workspace.Triangles
	
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

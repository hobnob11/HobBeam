--adds entries to the helper
--createHBeam(index, vector startPos, vector endPos, width, string material, textureScale, vector4 color)
E2Helper.Descriptions["createHBeam(nvvnsnxv4)"] = "Creates a beam using the drawBeam function, made by hobnob :D"
--setHBeamPos(index, vector startPos, vector endPos)
E2Helper.Descriptions["setHBeamPos(nvv)"] = "Sets the position of the Hob Beam! "
--e2function void killHBeam(index)
E2Helper.Descriptions["killHBeam(n)"] = "Kills the beam with given index"
--e2function void setHBeamColor(index, vector4 color)
E2Helper.Descriptions["setHBeamColor(nxv4)"] = "Sets the colour of the beam with given index"

print("HOB CLIENTSIDE INIT")
local HBeamTable = {}
--now I need to somehow "hook" myself onto my own net message 

--it would be far to easy if copying this over worked
local void function PushToCST(Changes,e2id)
	if Changes ~= nil then

		-- Make sure the e2 is in the gTable
		if HBeamTable[e2id] == nil then HBeamTable[e2id] = {} end

		-- Loop through the change tables
		for I = 0 , #Changes do
			-- Make sure it's not an empty table
			if Changes[I] ~= nil then
				-- Check that the E2 and index exist.
				if Changes[I]["ownerE2"]~=nil or Changes[I]["index"]~=nil then
					-- Grab the index, for use
					local index = Changes[I]["index"]
					-- Make sure the index is within the e2 in the gTable
					if HBeamTable[e2id][index] == nil then HBeamTable[e2id][index] = {} end

					-- Loop through the change table to add 
					for Key,Value in pairs(Changes[I]) do  
						-- Add it.
						HBeamTable[e2id][index][Key] = Value
					end
				end
			end
		end
	end
end
net.Receive("HobNetMsg", function(len) 
	local Queue = {}
	local QueueLength = net.ReadUInt(10)
	local e2id = nil 
	for i=1,QueueLength do
		Queue[i] = {}
		local ENUM = net.ReadUInt(2)
		e2id = net.ReadUInt(16)
		Queue[i]["ownerE2"] = e2id
		
		if ENUM == 0 then 
			--CreateBeam - ALL THE THINGS
			Queue[i]["index"] = net.ReadUInt(8)
			Queue[i]["startPos"] = net.ReadVector()
			Queue[i]["endPos"] = net.ReadVector()
			Queue[i]["width"] = net.ReadUInt(10)
			Queue[i]["material"] = net.ReadString()
			Queue[i]["textureScale"] = net.ReadUInt(3)
			Queue[i]["color"] = net.ReadColor()
		elseif ENUM == 1 then
			--SetBeamPos
			Queue[i]["index"] = net.ReadUInt(8)
			Queue[i]["startPos"] = net.ReadVector()
			Queue[i]["endPos"] = net.ReadVector()
		elseif ENUM == 2 then
			Queue[i]["index"] = net.ReadUInt(8)
			Queue[i]["color"] = net.ReadColor()
		end
	end
	PushToCST(Queue,e2id)
end)
net.Receive("HobKillMsg", function(len)
	local KillAll = net.ReadBool()
	local e2id
	local index 
	if KillAll then 
		e2id = net.ReadUInt(16)
		if e2id~=nil then HBeamTable[e2id] = nil end
	else
		e2id = net.ReadUInt(16)
		index = net.ReadUInt(12)
		if index~=nil then HBeamTable[e2id][index] = nil end
	end
end)

hook.Add("PreDrawTranslucentRenderables","HobBeamHook",function()
		for k,E2 in pairs(HBeamTable) do
				if #E2>0 then
						for I = 1 , #E2 do
								local Vec1 = E2[I]["startPos"]
								local Vec2 = E2[I]["endPos"]
								local Num1 = E2[I]["width"]
								local Str1 = E2[I]["material"]
								local Num2 = E2[I]["textureScale"]
								local Col1 = E2[I]["color"]
								local Beam = Material( Str1 )  
								render.SetColorMaterial(Col1)
								render.SetMaterial( Beam )
								--TODO: Steal steeveos code and reverse engineer it into here.
								render.DrawBeam( Vec1 , Vec2 , Num1, Num2, Num2, Col1 )
						end
				end
		end
end)

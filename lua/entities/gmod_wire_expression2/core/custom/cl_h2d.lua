--adds entries to the helper
--createH2DBeam(index, vector startPos, vector endPos, width, string material, textureScale, vector4 color)
E2Helper.Descriptions["createH2DBeam(nvvnsnxv4)"] = "Creates a beam using the drawBeam function, made by hobnob :D"
--setH2DBeamPos(index, vector startPos, vector endPos)
E2Helper.Descriptions["setH2DBeamPos(nvv)"] = "Sets the position of the H2D Beam! "
--e2function void killH2DBeam(index)
E2Helper.Descriptions["killH2DBeam(n)"] = "Kills the beam with given index"
--e2function void setH2DBeamColor(index, vector4 color)
E2Helper.Descriptions["setH2DBeamColor(nxv4)"] = "Sets the colour of the beam with given index"

print("H2D CLIENTSIDE INIT")
local H2DBeamTable = {}

--identical to PushToSST - meaning the tables on both sides are identical too
local void function PushToCST(Changes,e2id)
	if Changes ~= nil then
		-- Make sure the e2 is in the gTable
		if H2DBeamTable[e2id] == nil then H2DBeamTable[e2id] = {} end
		-- Loop through the change tables
		for I = 0 , #Changes do
			-- Make sure it's not an empty table
			if Changes[I] ~= nil then
				-- Check that the E2 and index exist.
				if Changes[I]["ownerE2"]~=nil or Changes[I]["index"]~=nil then
					-- Grab the index, for use
					local index = Changes[I]["index"]
					-- Make sure the index is within the e2 in the gTable
					if H2DBeamTable[e2id][index] == nil then H2DBeamTable[e2id][index] = {} end

					-- Loop through the change table to add 
					for Key,Value in pairs(Changes[I]) do  
						-- Add it.
						H2DBeamTable[e2id][index][Key] = Value
					end
				end
			end
		end
	end
end

--Uses ENUM : 1 - CreateBeam
--          : 2 - Set Pos
--          : 3 - Set Color
--Recives all of the data from the server (an almost identical mirror of NetMessage())

net.Receive("H2DNetMsg", function(len) 
	local Queue = {}
	local QueueLength = net.ReadUInt(10)
	local e2id = nil 
	for i=1,QueueLength do
		Queue[i] = {}
		local ENUM = net.ReadUInt(2)
		e2id = net.ReadUInt(16)
		Queue[i]["ownerE2"] = e2id
		
		if ENUM == 0 then 
			--CreateBeam -
			Queue[i]["index"] = net.ReadUInt(8)
			Queue[i]["startPos"] = net.ReadVector()
			Queue[i]["endPos"] = net.ReadVector()
			Queue[i]["width"] = net.ReadUInt(10)
			Queue[i]["material"] = net.ReadString()
			Queue[i]["textureScale"] = net.ReadDouble(3)
			Queue[i]["color"] = net.ReadColor()
		elseif ENUM == 1 then
			--SetBeamPos
			Queue[i]["index"] = net.ReadUInt(8)
			Queue[i]["startPos"] = net.ReadVector()
			Queue[i]["endPos"] = net.ReadVector()
		elseif ENUM == 2 then
			--SetBeamColor
			Queue[i]["index"] = net.ReadUInt(8)
			Queue[i]["color"] = net.ReadColor()
		end
	end
	PushToCST(Queue,e2id)
end)

--Receives the kill message, if bool is true then kills all beams on the e2
net.Receive("H2DKillMsg", function(len)
	local KillAll = net.ReadBool()
	local e2id
	local index 
	if KillAll then 
		e2id = net.ReadUInt(16)
		if e2id~=nil then H2DBeamTable[e2id] = nil end
	else
		e2id = net.ReadUInt(16)
		index = net.ReadUInt(12)
		if index~=nil then H2DBeamTable[e2id][index] = nil end
	end
end)

--Actualy renders the beam, this runs through the entire beam table every time the client renders something (so fps)
hook.Add("PreDrawTranslucentRenderables","H2DBeamHook",function()
		for k,E2 in pairs(H2DBeamTable) do
				if #E2>0 then
						for I = 1 , #E2 do
								local Vec1 = E2[I]["startPos"]
								local Vec2 = E2[I]["endPos"]
								local Num1 = E2[I]["width"]
								local Str1 = E2[I]["material"]
								local Num2 = E2[I]["textureScale"]
								local Col1 = E2[I]["color"]
								local Beam = Material( Str1 ) 
								local Cent = Beam:Width() * 0.5
								
								render.SetColorMaterial(Col1)
								render.SetMaterial( Beam )
								render.DrawBeam( Vec1 , Vec2 , Num1, Cent -Num2,Cent+ Num2, Col1 )
						end
				end
		end
end)

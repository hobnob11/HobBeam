--adds entries to the helper
--createHBeam(index, vector startPos, vector endPos, width, string material, textureScale, vector4 color)
E2Helper.Descriptions["createHBeam(nvvnsnxv4)"] = "Creates a beam using the drawBeam function, made by hobnob :D"
--setHBeamPos(index, vector startPos, vector endPos)
E2Helper.Descriptions["setHBeamPos(nvv)"] = "Sets the position of the Hob Beam! "

print("HOB CLIENTSIDE INIT")
local HBeamTable = {}
--now I need to somehow "hook" myself onto my own net message 

--it would be far to easy if copying this over worked
local void function PushToCST(Changes,e2)
	if Changes ~= nil then

		-- Make sure the e2 is in the gTable
		if HBeamTable[e2] == nil then HBeamTable[e2] = {} end

		-- Loop through the change tables
		for I = 0 , #Changes do
			-- Make sure it's not an empty table
			if Changes[I] ~= nil then
				-- Check that the E2 and index exist.
				if Changes[I]["ownerE2"]~=nil or Changes[I]["index"]~=nil then
					-- Grab the index, for use
					local index = Changes[I]["index"]
					-- Make sure the index is within the e2 in the gTable
					if HBeamTable[e2][index] == nil then HBeamTable[e2][index] = {} end

					-- Loop through the change table to add 
					for Key,Value in pairs(Changes[I]) do  
						-- Add it.
						HBeamTable[e2][index][Key] = Value
					end
				end
			end
		end
	end
end
net.Receive("HobNetMsg", function(len) 
	local Queue = {}
	local QueueLength = net.ReadUInt(10)
	for i=1,QueueLength do
		local ENUM = net.ReadUInt(2)
		Queue["ownerE2"] = net.ReadEntity()
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
			Queue[i]["index"] = net.ReadUInt(8)
			Queue[i]["startPos"] = net.ReadVector()
			Queue[i]["endPos"] = net.ReadVector()
		end
	end
	--PushToCST(Queue,?
	
	--TODO: REWRITE HANDELING OF DATA
end)

hook.Add("PreDrawTranslucentRenderables","HobBeamHook",function()
	if #HBeamTable>0 then
		for I = 1 , #HBeamTable do
			local Vec1 = HBeamTable[I]["startPos"]
			local Vec2 = HBeamTable[I]["endPos"]
			local Num1 = HBeamTable[I]["width"]
			local Str1 = HBeamTable[I]["material"]
			local Num2 = HBeamTable[I]["textureScale"]
			local Col1 = HBeamTable[I]["color"]
			local Beam = Material( Str1 )	
			render.SetMaterial( Beam )
			render.DrawBeam( Vec1 , Vec2 , Num1, Num2, Num2, Col1 )
		end
	end
end)

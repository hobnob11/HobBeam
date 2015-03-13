--adds entries to the helper
--createHBeam(index, vector startPos, vector endPos, width, string material, textureScale, vector4 color)
E2Helper.Descriptions["createHBeam(nvvnsnxv4)"] = "Creates a beam using the drawBeam function, made by hobnob :D"
--setHBeamPos(index, vector startPos, vector endPos)
E2Helper.Descriptions["setHBeamPos(nvv)"] = "Sets the position of the Hob Beam! "

print("HOB CLIENTSIDE INIT")
local HBeamTable = {}
--now I need to somehow "hook" myself onto my own net message 

--it would be far to easy if copying this over worked
local void function PushToSST(Changes)
	--loop for every change table 
	for I = 0 , #Changes do
		--make sure the beam being changed is valid
		if not Changes[I]["ownerE2"]==nil or Changes[I]["index"]==nil then
			--i have checked to make sure it is a valid beam, now i just have to put the new information in the global tabl
			for Key,Value in pairs(Changes[I]) do
		-- Global Table   e2SpecificTable    IndexedBeamTable  Var  
				HBeamTable[self.entity()][Changes[I]["index"]][Key] =Changes[I][Key]
			end
		end
	end
end

net.Receive("HobNetMsg", function(len) 
	local Queue = {}
	Queue = net.ReadTable()
	--TODO: REWRITE HANDELING OF DATA
	PushToSST(Queue)
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

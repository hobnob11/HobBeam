--adds entries to the helper
--createHBeam(index, vector startPos, vector endPos, width, string material, textureScale, vector4 color)
E2Helper.Descriptions["createHBeam(nvvnsnxv4)"] = "Creates a beam using the drawBeam function, made by hobnob :D"
--setHBeamPos(index, vector startPos, vector endPos)
E2Helper.Descriptions["setHBeamPos(nvv)"] = "Sets the position of the Hob Beam! "

local HBeamTable = {}
--now I need to somehow "hook" myself onto my own net message 

net.Receive("HobNetMsg", function(len) 
	local Queue = {}
	Queue = net.ReadTable()
	for I = 1 , #Queue do 
		local index = Queue[I]["index"]
		for Key , Value in pairs(Queue[I]) do
			HBeamTable[index][Key] = Value
		end
	end
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

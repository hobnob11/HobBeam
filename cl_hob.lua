--E2Helper.Descriptions["drawHBeam(vvnsnxv4)"] = "Creates a beam using the drawBeam function, made by hobnob :D"
local HobTable = {}
--now I need to somehow "hook" myself onto my own net message 

net.Receive("HobNetMsg", function(len) 
	HobTable = net.ReadTable()
	if #HobTable>0 then
	else
	end
end)

hook.Add("PreDrawTranslucentRenderables","HobBeamHook",function()
	if #HobTable>0 then
		for I = 1 , #HobTable do
			local Vec1 = HobTable[I]["startPos"]
			local Vec2 = HobTable[I]["endPos"]
			local Num1 = HobTable[I]["width"]
			local Str1 = HobTable[I]["material"]
			local Num2 = HobTable[I]["textureScale"]
			local Col1 = HobTable[I]["color"]
			local Beam = Material( Str1 )	
			render.SetMaterial( Beam )
			render.DrawBeam( Vec1 , Vec2 , Num1, Num2, Num2, Col1 )
		end
	end
end)

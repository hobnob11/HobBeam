E2Lib.RegisterExtension("hob",true) -- makes the extension, false means its not a default wiremod extension

e2function void drawHBeam(vector startPos, vector endPos, width, string material, textureScale, vector4 color)
	--queue the information for the client somehow
	local Table2 = {}
	Table2["startPos"]=Vector(startPos[1],startPos[2],startPos[3])
	Table2["endPos"]=Vector(endPos[1],endPos[2],endPos[3])
	Table2["width"]=width
	Table2["material"]=material
	Table2["textureScale"]=textureScale
	Table2["color"]=Color(color[1],color[2],color[3],color[4])
	self.data.HobTable[#self.data.HobTable+1]=Table2
	self.data.Pending = true
end


--------------------------------------------------------
-- Callbacks
--------------------------------------------------------
--Creates a net message and then sends it

-- i assume that both this code is actually ran and also that it only needs to be run once
-- i could have a grave mis-understanding of how net messages work...
util.AddNetworkString("HobNetMsg")

--gets the queue of information to be sent to the client, puts it in HobNetMsg and sends it
--probably...
local function NetMessage(self)
	net.Start("HobNetMsg")
	net.WriteTable(self.data.HobTable)
	net.Broadcast()
end

registerCallback("postexecute",function(self)
	if(self.data.Pending) then 
		NetMessage(self)
		self.data.Pending = false
		self.data.HobTable = {}
	end
end)

registerCallback("construct",function(self)
self.data.HobTable = {} --the table of all the things to be sent
self.data.Pending = false -- Set to true whenever new information is added to the table queue
end)
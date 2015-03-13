E2Lib.RegisterExtension("hob",true) -- makes the extension, true to load by defualt
util.AddNetworkString("HobNetMsg")
--Putting this here should make a global table to store all beams on the server?
local HBeamTable = {}

-- i assume that both this code is actually ran and also that it only needs to be run once
-- i could have a grave mis-understanding of how net messages work...
util.AddNetworkString("HobNetMsg")

print("HOB SERVERSIDE INIT")
--push to ServerSideTable

local void function PushToSST(Changes)
	--loop for every change table 
	for I = 0 , #Changes do
		--make sure the beam being changed is valid
		if Changes[I]["ownerE2"]~=nil or Changes[I]["index"]~=nil then
			--i have checked to make sure it is a valid beam, now i just have to put the new information in the global tabl
			for Key,Value in pairs(Changes[I]) do
		-- Global Table   e2SpecificTable    IndexedBeamTable  Var  
				HBeamTable[self.entity()][Changes[I]["index"]][Key] =Changes[I][Key]
			end
		end
	end
end

e2function void createHBeam(index, vector startPos, vector endPos, width, string material, textureScale, vector4 color)
	--queue the information for the client somehow
	local Table2 = {}
	Table2["ownerE2"]=self.entity()
	Table2["index"]=index
	Table2["ENUM"]=0
	Table2["startPos"]=Vector(startPos[1],startPos[2],startPos[3])
	Table2["endPos"]=Vector(endPos[1],endPos[2],endPos[3])
	Table2["width"]=width
	Table2["material"]=material
	Table2["textureScale"]=textureScale
	Table2["color"]=Color(color[1],color[2],color[3],color[4])
	self.data.Queue[#self.data.Queue+1]=Table2
	self.data.Pending = true
	
end

e2function void setHBeamPos(index, vector startPos, vector endPos)
	local Table2 = {}
	Table2["ownerE2"]=self.entity()
	Table2["index"]=index
	Table2["ENUM"]=1
	Table2["startPos"]=Vector(startPos[1],startPos[2],startPos[3])
	Table2["endPos"] = Vector(endPos[1],endPos[2],endPos[3])
	self.data.Queue[#self.data.Queue+1]=Table2
	self.data.Pending = true 
end


--------------------------------------------------------
-- Callbacks
--------------------------------------------------------
--Creates a net message and then sends it

--gets the queue of information to be sent to the client, puts it in HobNetMsg and sends it
--probably...

--
-- Gets the queue of information to be sent to the client, puts it in HobNetMsg and sends it
--
--divran magic go!
local function NetMessage(self)
	net.Start("HobNetMsg")
	local Queue = self.data.Queue
	for i=1,#Queue do
		local ENUM = Queue[i]["ENUM"]
		if ENUM == 0 then 
			--CreateBeam - ALL THE THINGS
			net.WriteUInit(ENUM,2)
			net.WriteEntity(Queue[I]["ownerE2"])
			net.WriteUInit(math.Clamp(Queue[I]["index"],0,255),8)
			net.WriteVector(Queue[I]["startPos"])
			net.WriteVector(Queue[I]["endPos"])
			net.WriteUInt(math.Clamp(Queue[I]["width"],0,1023),10)
			net.WriteString(Queue[I]["material"])
			net.WriteUInt(math.Clamp(Queue[I]["textureScale"],0,8),3)
			net.WriteColor(Queue[I]["color"])
		elseif ENUM == 1 then
			net.WriteUInit(ENUM,2)
			net.WriteEntity(Queue[I]["ownerE2"])
			net.WriteUInit(math.Clamp(Queue[I]["index"],0,255),8)
			net.WriteVector(Queue[I]["startPos"])
			net.WriteVector(Queue[I]["endPos"])
		end
	end
	net.Broadcast()
end

--local function NetMessage(self)
--	net.Start("HobNetMsg")
--	net.WriteTable(self.data.Queue)
--	net.Broadcast()
--end
	
		

registerCallback("postexecute",function(self)
	if(self.data.Pending) then 
		PushToSST(self.data.Queue)
		NetMessage(self)
		self.data.Pending = false
		self.data.Queue = {}
	end
end)

registerCallback("construct",function(self)
self.data.Queue = {} --the table of all the things to be sent
self.data.Pending = false -- Set to true whenever new information is added to the table queue
end)

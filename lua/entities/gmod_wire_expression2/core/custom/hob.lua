E2Lib.RegisterExtension("hob",true) -- makes the extension, true to load by defualt
util.AddNetworkString("HobNetMsg")
--utl.AddNetworkString("HobKillMsg")
--Putting this here should make a global table to store all beams on the server?
local HBeamTable = {}

-- i assume that both this code is actually ran and also that it only needs to be run once
-- i could have a grave mis-understanding of how net messages work...
util.AddNetworkString("HobKillMsg")

--    |----------------------------------------------------------| -this table is confusing as shit so here goes
--    |                       HBeamTable{}                       | This table is global to all e2's for everyone on the server
--    |----------------------------------------------------------| it contains a table of all of the e2's that have created beams
--    |  ["ownerE2"]=1   |   ["ownerE2"]=2   |   ["ownerE2"]=3   |-these tables are stored using the related e2 entity index's as keys 
--    |------------------|-------------------|-------------------| and contain all of the information for the beams that that e2 has created 
--    |    ["index"]=1   |    ["index"]=1    |    ["index"]=1    |
--    |    ["index"]=2   |    ["index"]=2    |    ["index"]=2    | -The individual beams are stored as tables with the beams index as the key.
--    |    ["index"]=3   |    ["index"]=3    |    ["index"]=3    | the individual args (startPos,color etc..) are stored in this table with a 
--    |    ["index"]=4   |    ["index"]=4    |    ["index"]=4    | string of the name of the arg as the key. 



--push to ServerSideTable

local void function PushToSST(Changes,e2id)
	if Changes ~= nil then

		-- Make sure the e2 is in the gTable
		if HBeamTable[e2id] == nil then HBeamTable[e2id] = {} end

		-- Loop through the change tables
		for i = 0 , #Changes do
			-- Make sure it's not an empty table
			if Changes[i] ~= nil then
				-- Check that the E2 and index exist.
				if Changes[i]["ownerE2"]~=nil or Changes[i]["index"]~=nil then
					-- Grab the index, for use
					local index = Changes[i]["index"]
					-- Make sure the index is within the e2 in the gTable
					if HBeamTable[e2id][index] == nil then HBeamTable[e2id][index] = {} end

					-- Loop through the change table to add 
					for Key,Value in pairs(Changes[i]) do  
						-- Add it.
						HBeamTable[e2id][index][Key] = Value
					end
				end
			end
		end
	end
end
__e2setcost(30)
e2function void createHBeam(index, vector startPos, vector endPos, width, string material, textureScale, vector4 color)
	--queue the information for the client somehow
	local Table2 = {}
	Table2["ownerE2"]=self.entity:EntIndex()
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
__e2setcost(10)
e2function void setHBeamPos(index, vector startPos, vector endPos)
	local Table2 = {}
	Table2["ownerE2"]=self.entity:EntIndex()
	Table2["index"]=index
	Table2["ENUM"]=1
	Table2["startPos"]=Vector(startPos[1],startPos[2],startPos[3])
	Table2["endPos"] = Vector(endPos[1],endPos[2],endPos[3])
	self.data.Queue[#self.data.Queue+1]=Table2
	self.data.Pending = true 
end
__e2setcost(5)
e2function void setHBeamColor(index, vector4 color)
	local Table2 = {}
	Table2["ownerE2"]=self.entity:EntIndex()
	Table2["index"]=index
	Table2["ENUM"]=2
	Table2["color"]=Color(color[1],color[2],color[3],color[4])
	self.data.Queue[#self.data.Queue+1]=Table2
	self.data.Pending = true
end
	
__e2setcost(2)
e2function void killHBeam(index)
	local e2id = self.entity:EntIndex()
	net.Start("HobKillMsg")
	net.WriteBool(false)
	net.WriteUInt(e2id,16)
	net.WriteUInt(index,12)
	net.Broadcast()
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
	local QueueLength = #self.data.Queue
	net.WriteUInt(QueueLength,10)
	for i=1,QueueLength do
		local ENUM = Queue[i]["ENUM"]
		if ENUM == 0 then 
			--CreateBeam - ALL THE THINGS
			net.WriteUInt(ENUM,2)
			net.WriteUInt(self.entity:EntIndex(),16)
			net.WriteUInt(math.Clamp(Queue[i]["index"],0,255),8)
			net.WriteVector(Queue[i]["startPos"])
			net.WriteVector(Queue[i]["endPos"])
			net.WriteUInt(math.Clamp(Queue[i]["width"],0,1023),10)
			net.WriteString(Queue[i]["material"])
			net.WriteUInt(math.Clamp(Queue[i]["textureScale"],0,8),3)
			net.WriteColor(Queue[i]["color"])
		elseif ENUM == 1 then
		--setBeamPos 
			net.WriteUInt(ENUM,2)
			net.WriteUInt(self.entity:EntIndex(),16)
			net.WriteUInt(math.Clamp(Queue[i]["index"],0,255),8)
			net.WriteVector(Queue[i]["startPos"])
			net.WriteVector(Queue[i]["endPos"])
		elseif ENUM == 2 then 
		--setBeamColor
			net.WriteUInt(ENUM,2)
			net.WriteUInt(self.entity:EntIndex(),16)
			net.WriteUInt(math.Clamp(Queue[i]["index"],0,255),8)
			net.WriteColor(Queue[i]["color"])
		end
	end
	net.Broadcast()
end

registerCallback("destruct",function(self)
	net.Start("HobKillMsg")
	net.WriteBool(true)
	net.WriteUInt(self.entity:EntIndex(),16)
	net.Broadcast()
end)

registerCallback("postexecute",function(self)
	if(self.data.Pending) then 
		PushToSST(self.data.Queue,self.entity:EntIndex())
		NetMessage(self)
		self.data.Pending = false
		self.data.Queue = {}
	end
end)

registerCallback("construct",function(self)
self.data.Queue = {} --the table of all the things to be sent
self.data.Pending = false -- Set to true whenever new information is added to the table queue
end)

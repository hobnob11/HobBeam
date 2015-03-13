E2Lib.RegisterExtension("hob",true) -- makes the extension, true to load by defualt
util.AddNetworkString("HobNetMsg")
--Putting this here should make a global table to store all beams on the server?
local HBeamTable = {}

-- i assume that both this code is actually ran and also that it only needs to be run once
-- i could have a grave mis-understanding of how net messages work...
util.AddNetworkString("HobNetMsg")

--    |----------------------------------------------------------| -this table is confusing as shit so here goes
--    |                       HBeamTable{}                       | This table is global to all e2's for everyone on the server
--    |----------------------------------------------------------| it contains a table of all of the e2's that have created beams
--    |  ["ownerE2"]=1   |   ["ownerE2"]=2   |   ["ownerE2"]=3   |-these tables are stored using the related e2 entities as keys 
--    |------------------|-------------------|-------------------| and contain all of the information for the beams that that e2 has created 
--    |    ["index"]=1   |    ["index"]=1    |    ["index"]=1    |
--    |    ["index"]=2   |    ["index"]=2    |    ["index"]=2    | -The individual beams are stored as tables with the beams index as the key.
--    |    ["index"]=3   |    ["index"]=3    |    ["index"]=3    | the individual args (startPos,color etc..) are stored in this table with a 
--    |    ["index"]=4   |    ["index"]=4    |    ["index"]=4    | string of the name of the arg as the key. 


print("HOB SERVERSIDE INIT")
--push to ServerSideTable

local void function PushToSST(Changes,e2)
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
	local QueueLength = #self.data.Queue
	net.WriteUInt(QueueLength,10)
	for i=1,QueueLength do
		local ENUM = Queue[i]["ENUM"]
		if ENUM == 0 then 
			--CreateBeam - ALL THE THINGS
			net.WriteUInt(ENUM,2)
			net.WriteEntity(Queue[I]["ownerE2"])
			net.WriteUInt(math.Clamp(Queue[I]["index"],0,255),8)
			net.WriteVector(Queue[I]["startPos"])
			net.WriteVector(Queue[I]["endPos"])
			net.WriteUInt(math.Clamp(Queue[I]["width"],0,1023),10)
			net.WriteString(Queue[I]["material"])
			net.WriteUInt(math.Clamp(Queue[I]["textureScale"],0,8),3)
			net.WriteColor(Queue[I]["color"])
		elseif ENUM == 1 then
			net.WriteUInt(ENUM,2)
			net.WriteEntity(Queue[I]["ownerE2"])
			net.WriteUInt(math.Clamp(Queue[I]["index"],0,255),8)
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
		PushToSST(self.data.Queue,self.entity)
		NetMessage(self)
		self.data.Pending = false
		self.data.Queue = {}
	end
end)

registerCallback("construct",function(self)
self.data.Queue = {} --the table of all the things to be sent
self.data.Pending = false -- Set to true whenever new information is added to the table queue
end)

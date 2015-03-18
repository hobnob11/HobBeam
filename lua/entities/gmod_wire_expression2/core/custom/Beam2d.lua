E2Lib.RegisterExtension("2DBeam",true) -- makes the extension, true to load by defualt
util.AddNetworkString("2DNetMsg")
util.AddNetworkString("2DKillMsg")
print("2D SERVERSIDE INIT")
--Global to all e2's table containing all beams 
local Beam2DTable = {}

--push to ServerSideTable
local void function PushToSST(Changes,e2id)
	if Changes ~= nil then

		-- Make sure the e2 is in the gTable
		if Beam2DTable[e2id] == nil then Beam2DTable[e2id] = {} end

		-- Loop through the change tables
		for i = 0 , #Changes do
			-- Make sure it's not an empty table
			if Changes[i] ~= nil then
				-- Check that the E2 and index exist.
				if Changes[i]["ownerE2"]~=nil or Changes[i]["index"]~=nil then
					-- Grab the index, for use
					local index = Changes[i]["index"]
					-- Make sure the index is within the e2 in the gTable
					if Beam2DTable[e2id][index] == nil then Beam2DTable[e2id][index] = {} end

					-- Loop through the change table to add 
					for Key,Value in pairs(Changes[i]) do  
						-- Add it.
						Beam2DTable[e2id][index][Key] = Value
					end
				end
			end
		end
	end
end
__e2setcost(30)
e2function void create2DBeam(index, vector startPos, vector endPos, width, string material, textureScale, vector4 color)
	--puts the data in a new entry in the queue
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
e2function void set2DBeamPos(index, vector startPos, vector endPos)
	--puts the data in a new entry in the queue
	local Table2 = {}
	Table2["ownerE2"]=self.entity:EntIndex()
	Table2["index"]=index
	Table2["ENUM"]=1
	if(Beam2DTable[self.entity:EntIndex()]["parent"])then
		local entity = Beam2DTable[self.entity:EntIndex()]["pEntity"]
		Table2["offset1"] = entity:WorldToLocal(startPos)
		Table2{"offset2"] = entity:WorldToLocal(endPos)
	else
		Table2["startPos"]=Vector(startPos[1],startPos[2],startPos[3])
		Table2["endPos"] = Vector(endPos[1],endPos[2],endPos[3])
	end
	self.data.Queue[#self.data.Queue+1]=Table2
	self.data.Pending = true 
end
__e2setcost(5)
e2function void set2DBeamColor(index, vector4 color)
	--puts the data in a new entry in the queue
	local Table2 = {}
	Table2["ownerE2"]=self.entity:EntIndex()
	Table2["index"]=index
	Table2["ENUM"]=2
	Table2["color"]=Color(color[1],color[2],color[3],color[4])
	self.data.Queue[#self.data.Queue+1]=Table2
	self.data.Pending = true
end
	
__e2setcost(2)
e2function void kill2DBeam(index)
	--sends a kill message for the relevant id
	local e2id = self.entity:EntIndex()
	net.Start("2DKillMsg")
	net.WriteBool(false)
	net.WriteUInt(e2id,16)
	net.WriteUInt(index,12)
	net.Broadcast()
end

_e2setcost(10)
e2function void parent2DBeam(index,entity entity)
	--turns on the "parented" bool and gives a entity to parent too.
	--calculates and stores the offset from the beam to the entity
	local Offset1 = entity:WorldToLocal(Beam2DTable[self.entity:EntIndex()][index]["startPos"])
	local Offset2 = entity:WorldToLocal(Beam2DTable[self.entity:EntIndex()][index]["endPos"])
	local Table2 = {}
	Table2["ownerE2"]=self.entity:EntIndex()
	Table2["index"]=index
	Table2["ENUM"]=3
	Table2["parent"]=true
	Table2["pEntity"]=entity
	Table2["offset1"]=Offset1
	Table2["offset2"]=Offset2
	self.data.Queue[#self.data.Queue+1]=Table2
	self.data.Pending = true 
end
--Uses ENUM : 0 - CreateBeam
--          : 1 - Set Pos
--          : 2 - Set Color
--          : 3 - parent 
--Sends the change table to all clients
local function NetMessage(self)
	net.Start("2DNetMsg")
	local Queue = self.data.Queue
	local QueueLength = #self.data.Queue
	net.WriteUInt(QueueLength,10)
	for i=1,QueueLength do
		local ENUM = Queue[i]["ENUM"]
		if ENUM == 0 then 
			--CreateBeam 
			net.WriteUInt(ENUM,2)
			net.WriteUInt(self.entity:EntIndex(),16)
			net.WriteUInt(math.Clamp(Queue[i]["index"],0,255),8)
			net.WriteVector(Queue[i]["startPos"])
			net.WriteVector(Queue[i]["endPos"])
			net.WriteUInt(math.Clamp(Queue[i]["width"],0,1023),10)
			net.WriteString(Queue[i]["material"])
			net.WriteDouble(math.Clamp(Queue[i]["textureScale"],0,8),3)
			net.WriteColor(Queue[i]["color"])
		elseif ENUM == 1 then
		--setBeamPos 
			net.WriteUInt(ENUM,2)
			net.WriteUInt(self.entity:EntIndex(),16)
			net.WriteUInt(math.Clamp(Queue[i]["index"],0,255),8)
			net.WriteBool(Queue[i]["parent"]
			if(Queue[i]["parent"])then
				net.WriteVector(Queue[i]["offset1"])
				net.WriteVector(Queue[i]["offset2"])
			else
				net.WriteVector(Queue[i]["startPos"])
				net.WriteVector(Queue[i]["endPos"])
			end
		elseif ENUM == 2 then 
		--setBeamColor
			net.WriteUInt(ENUM,2)
			net.WriteUInt(self.entity:EntIndex(),16)
			net.WriteUInt(math.Clamp(Queue[i]["index"],0,255),8)
			net.WriteColor(Queue[i]["color"])
		elseif ENUM == 3 then
		--parent
			net.WriteUInt(ENUM,2)
			net.WriteUInt(self.entity:EntIndex(),16)
			net.WriteUInt(math.Clamp(Queue[i]["index"],0,255),8)
			net.WriteBool(Queue[i]["parent"])
			net.WriteEntity(Queue[i]["pEntity"])
			net.WriteVector(Queue[i]["offset1"])
			net.WriteVector(Queue[i]["offset2"])
		end
	end
	net.Broadcast()
end
--Run on e2 death
registerCallback("destruct",function(self)
	net.Start("2DKillMsg")
	net.WriteBool(true)
	net.WriteUInt(self.entity:EntIndex(),16)
	net.Broadcast()
end)
--run after every execution / cycle of the e2 code
registerCallback("postexecute",function(self)
	if(self.data.Pending) then 
		PushToSST(self.data.Queue,self.entity:EntIndex())
		NetMessage(self)
		self.data.Pending = false
		self.data.Queue = {}
	end
end)
--run when a e2 is created
registerCallback("construct",function(self)
self.data.Queue = {} --the change table of all data
self.data.Pending = false -- Set to true whenever new information is added to the table queue
end)


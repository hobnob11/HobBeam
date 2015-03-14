-- Small library loader! Therefore no GPL Header (but it's GPLed)
StarGate = StarGate or {};
StarGate.CAP = true; -- for some scripts

--################# Loads the libraries @aVoN
function StarGate.Load()
	-- Init always comes at first!
	include("stargate/init.lua");
	AddCSLuaFile("stargate/init.lua")
	include("stargate/tracelines.lua")
	AddCSLuaFile("stargate/tracelines.lua")
	if(SERVER) then
		AddCSLuaFile("autorun/stargate.lua"); -- Ourself of course!
	end
end
StarGate.Load();

/*
	Stargate Lib for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
--################# DEFINES #################
StarGate.Hook = StarGate.Hook or {};
-- CreateConVar("gmod_stargate_version",StarGate.CURRENT_VERSION); -- Which version?

function StarGate.CheckModule(type)
	return true;
end

--################# Init @aVoN
function StarGate.Init()
	-- Resource Distribution Installed?
	-- fix for client/server energy will be later @ AlexALX
	if(/*(CLIENT and file.Exists("stargate/client/energy.lua","LUA") or SERVER and*/ StarGate.CheckModule("energy") and (Environments or #file.Find("weapons/gmod_tool/environments_tool_base.lua","LUA") == 1 or Dev_Link or rd3_dev_link or #file.Find("weapons/gmod_tool/stools/dev_link.lua","LUA") == 1 or #file.Find("weapons/gmod_tool/stools/rd3_dev_link.lua","LUA") == 1)) then //Thanks to mercess2911: http://www.facepunch.com/showpost.php?p=15508150&postcount=10070
		StarGate.HasResourceDistribution = true;
	else
		StarGate.HasResourceDistribution = false;
	end
	-- Wire?
	if(WireAddon or #file.Find("weapons/gmod_tool/stools/wire.lua","LUA") == 1) then
		StarGate.HasWire = true;
		if (file.IsDir("expression2","DATA") and not file.IsDir("expression2/cap_shared","DATA")) then
			file.CreateDir("expression2/cap_shared");
		end
		if (file.IsDir("starfall","DATA") and not file.IsDir("starfall/cap_shared","DATA")) then
			file.CreateDir("starfall/cap_shared");
		end
	else
		StarGate.HasWire = false;
	end
end
StarGate.Init(); -- Call the Init

E2Lib.RegisterExtension("H3DBeam",true) -- makes the extension, true to load by defualt
--global vars

--instanced vars
print("H3D SERVERSIDE INIT")
registerCallback("construct",function(self)
--self.data.var

end)

e2function entity createH3DBeam(index)
	
	self.Entity = self.entity
	local FiringPos = self.Entity:GetPos() + self.Entity:GetUp()*70;
	self.Target = self.Entity:GetPos() + self.Entity:GetUp()*200;
	local ShootDir = (self.Target - FiringPos):GetNormal();	
	
	local ent = ents.Create("energy_beam2");
		ent.Owner = self.Entity;
		ent:SetPos(FiringPos);
		ent:Spawn();
		ent:Activate();
		ent:SetOwner(self.Entity);
		ent:Setup(FiringPos, ShootDir, 1200, 1.5, "Asgard");

	local glow = EffectData();
		glow:SetEntity(self.Entity);
		glow:SetStart(Vector(0,0,70));
		glow:SetAngles(Angle(120,175,255));
		glow:SetScale(30);
		glow:SetMagnitude(1.5);
	util.Effect("energy_glow", glow);
	
end

registerCallback("postexecute",function(self)



end)

registerCallback("destruct",function(self)

end)
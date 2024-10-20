AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local TraceHull = util.TraceHull
local min, Clamp = math.min, math.Clamp
local tableInsert = table.insert

ACF.SonarTimeCompression = 0.15 --Multiplier for speed of sound. 0.33 means sound takes ~3x the time to travel to the target. Generally sonar travels at ~1500 m/s

function ENT:Initialize()

	--TODO:
	--Add layer function based on limiting ray and add output
	--Passive sonar
	--Active intercept
	--Torpedo detection
	--Add soundreplacer and wire input sound swapping
	--Change beamforming to double sonar range
	--Later:
	--Add sidelobes to active sonar. Later.
	--Improve CalcAngle function with trig to reduce cost.

	self.ThinkDelay			= 0.1
	self.StatusUpdateDelay	= 0.5
	self.LastStatusUpdate	= CurTime()
	self.Active				= false

	self.WaterZHeight = 0

	self.MaximumDistance	= self.MaximumDistance or 0
	self.BaseMaximumDistance = self.MaximumDistance
	self.PowerScale			= self.PowerScale or 1
	self.WashoutFactor		= self.WashoutFactor or 1
	self.NoiseMul			= self.NoiseMul or 1

	self.ActiveTransmitting = false
	self.PulseDuration = 6
	self.BeamAngle = 0
	self.BeamWidth = 270
	self.WashOut = 0 --Washout factor. Ranges from 0 to 1.

	self.NextPing = 0
	self.SonarYaw = 0

	self.Inputs	= WireLib.CreateInputs( self, {
		"Active (Whether to listen for passive sonar.)",
		"ActiveSonar (Whether to transmit active sonar instead of using passive.)",
		"ActiveAngle (World bearing to point the sonar beam at.)",
		"PulseDuration (Length in sec of pulse. Longer = more accurate. 4 sec needed to get spd. 0.5s Min, 10s Max)",
		"ActiveBeamwidth (Width of the beam of the sonar in degrees. Max 270, Min 27.)"
	})

	self.Outputs = WireLib.CreateOutputs( self, {
		"Detected (Returns 1 if at least one target was detected with sonar)",
		"Bearing (Returns an array of the angles of sonar targets) [ARRAY]",
		"Depth (Returns an array of the depths of active sonar targets) [ARRAY]",
		"Distance (Returns an array of the horizontal distance to sonar targets) [ARRAY]",
		"Velocity (Returns an array of the vector velocity of each sonar target) [ARRAY]",
		"Owner (Returns an array of the owners of sonar tracks) [ARRAY]",
		"ID (Returns an array of unique IDs for each target that can be used to track a specific contraption) [ARRAY]",
		"SonoDetected (Returns 1 if an active ping was detected)",
		"SonoAngle (Returns an array of the world angle of detected sonar pings) [ARRAY]",
		"TorpDetected (Returns 1 if a torpedo was detected)",
		"TorpPosition (Returns the vector position of any detected torpedoes) [ARRAY]",
		"Washout (Returns the level of washout from speed. At 1 the sonar becomes unusable.)"
	})

	self.OutputData = {
		Detected		= 0,
		Bearing			= {},
		Depth			= {},
		Distance		= {},
		Owner			= {},
		Velocity		= {},
		ID				= {},
		SonoDetected	= 0,
		SonoAngle		= {},
		TorpDetected	= 0,
		TorpPosition	= {},
		Washout	= 0
	}

	--List of target info we have. Used to compile into outputs or keep a record of transients of a track. Periodically cleaned after contact is lost for more than so much time.
	self.SonoUpdated = false
	self.SonarPositions = {}
	self.SonarVelocity = {}
	self.SonarOwners = {}
	self.SonarLastTracked = {}


	self:SetActive(false)

	self.NextLegalCheck     = ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal              = true
	self.LegalIssues        = ""

	self.TargetDetected		= false

	self:UpdateOverlayText()

end

function MakeACE_Sonar(Owner, Pos, Angle, Id)

	--print("Test")

	if not Owner:CheckLimit("_acf_missileradar") then return false end

	Id = Id or "Small-Sonar"
	--print(Id)

	local radar = ACF.Weapons.Radars[Id]
	if not radar then return false end

	local Sonar = ents.Create("ace_sonar")

	if IsValid(Sonar) then

		Sonar:SetAngles(Angle)
		Sonar:SetPos(Pos)

		Sonar.Model				= radar.model
		Sonar.Weight			= radar.weight
		Sonar.ACFName			= radar.name
		Sonar.ACEPoints			= radar.acepoints or 0.9

		Sonar.SeekSensitivity	= radar.SeekSensitivity

		local BaseDist =	39.37 * 300 --Base distance of sonar for a large sonar.
		Sonar.MaximumDistance	= BaseDist * (radar.powerscale or 1)
		Sonar.PowerScale		= radar.powerscale or 1
		Sonar.WashoutFactor		= radar.washoutfactor or 1
		Sonar.NoiseMul			= radar.noisemul or 1

		Sonar.Id				= Id
		Sonar.Class				= radar.class

		Sonar:Spawn()

		Sonar:CPPISetOwner(Owner)

		Sonar:SetNWNetwork()
		Sonar:SetModelEasy(radar.model)
		Sonar:UpdateOverlayText()

		Owner:AddCount( "_acf_missileradar", Sonar )
		Owner:AddCleanup( "acfmenu", Sonar )

		return Sonar
	end

	return false
end
list.Set( "ACFCvars", "ace_sonar", {"id"} )
duplicator.RegisterEntityClass("ace_sonar", MakeACE_Sonar, "Pos", "Angle", "Id" )

function ENT:SetNWNetwork()
	self:SetNWString( "WireName", self.ACFName )
end

function ENT:SetModelEasy(mdl)

	self:SetModel( mdl )
	self.Model = mdl

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(self.Weight)
	end

end

function ENT:TriggerInput( inp, value )
	if inp == "Active" then
		self:SetActive((value ~= 0) and self.Legal)
	elseif inp == "ActiveSonar" then
		if value > 0 then
			self.ActiveTransmitting = true
		else
			self.ActiveTransmitting = false
		end
	elseif inp == "ActiveAngle" then
		self.BeamAngle = math.NormalizeAngle(value)
	elseif inp == "PulseDuration" then
		self.PulseDuration = Clamp(value, 0.5 , 10)
	elseif inp == "ActiveBeamwidth" then
		self.BeamWidth = math.Round(Clamp(value,27,270),1)
		self.MaximumDistance = self.BaseMaximumDistance / (value / 243 + (8 / 9)) --Doubles at max angle. Computed intercept for 27,1 and 270,2
	elseif inp == "Cone" then
		if value > 0 then

			self.Cone = Clamp(value / 2, self.MinViewCone ,self.MaxViewCone )

			SetConeParameter( self )

			--You are not going from a wide to narrow beam in half a second deal with it.
			local curTime = CurTime()
			self:NextThink(curTime + 10)
		else
			self.Cone = self.ICone
		end

		self:UpdateOverlayText()
	end
end

function ENT:SetActive(active)

	self.Active = active

	--if active  then

	--else
	if not active  then

		WireLib.TriggerOutput( self, "Detected"	, 0 )
		WireLib.TriggerOutput( self, "Bearing", {} )
		WireLib.TriggerOutput( self, "Depth", {} )
		WireLib.TriggerOutput( self, "Distance", {} )
		WireLib.TriggerOutput( self, "Owner", {} )
		WireLib.TriggerOutput( self, "ID", {} )
		WireLib.TriggerOutput( self, "SonoDetected"	, 0 )
		WireLib.TriggerOutput( self, "SonoAngle", {} )
		WireLib.TriggerOutput( self, "TorpDetected"	, 0 )
		WireLib.TriggerOutput( self, "TorpPosition", {} )
		WireLib.TriggerOutput( self, "Washout"	, 0 )


		self.OutputData.Detected = 0
		self.OutputData.Bearing = {}
		self.OutputData.Depth = {}
		self.OutputData.Distance = {}
		self.OutputData.Owner = {}
		self.OutputData.ID = {}
		self.OutputData.SonoDetected = 0
		self.OutputData.SonoAngle = {}
		self.OutputData.TorpDetected = 0
		self.OutputData.TorpPosition = {}
		self.OutputData.Washout = 0

	end

end

local LOSTraceData = {
	mask = MASK_SOLID_BRUSHONLY,
	mins = vector_origin,
	maxs = vector_origin,
}

function ENT:SONARDevDisplayAngles(Duration)

		if GetConVar( "developer" ):GetBool() ~= 0 then --Is there a faster way to do this?

		local DebugColor = Color(255, 135, 0)

		local OffsetAng = 135 - self.BeamWidth * 0.5 --0.5 of the max angle limit. In this case 270

		local LocalYaw = math.NormalizeAngle(self.BeamAngle - self.SonarYaw)

		local BeamAng = math.Clamp(LocalYaw, -OffsetAng , OffsetAng)

		BeamAng = math.NormalizeAngle(BeamAng + self.SonarYaw)

		local BeamWidth = self.BeamWidth * 0.5

		local Ang1 = BeamAng - BeamWidth
		local Ang2 = BeamAng + BeamWidth

		local SelfPos = self:WorldSpaceCenter()
		local Voffset1 = Vector(self.MaximumDistance,0,-1000)
		--local Voffset2 = Vector(self.MaximumDistance,0,1000)

		debugoverlay.Line(SelfPos, SelfPos + Angle(0,BeamAng,0):Forward() * 500, Duration, Color(0, 0, 255), true)
		--debugoverlay.Line(SelfPos, SelfPos + Angle(0,Ang1,0):Forward() * self.MaximumDistance, Duration, DebugColor)
		--debugoverlay.Line(SelfPos, SelfPos + Angle(0,Ang2,0):Forward() * self.MaximumDistance, Duration, DebugColor)

		debugoverlay.BoxAngles(SelfPos, vector_origin, Voffset1, Angle(0,Ang1,0), Duration, Color(DebugColor.r, DebugColor.g, DebugColor.b, 255))
		debugoverlay.BoxAngles(SelfPos, vector_origin, Voffset1, Angle(0,Ang2,0), Duration, Color(DebugColor.r, DebugColor.g, DebugColor.b, 255))

		--debugoverlay.BoxAngles(SelfPos, vector_origin, Voffset2, Angle(0,Ang1,0), Duration, Color(DebugColor.r, DebugColor.g, DebugColor.b, 5))
		--debugoverlay.BoxAngles(SelfPos, vector_origin, Voffset2, Angle(0,Ang2,0), Duration, Color(DebugColor.r, DebugColor.g, DebugColor.b, 5))

		end
end

function ENT:DoSonarFunctions()

	if self:WaterLevel() ~= 3 then return end

	self.SonarYaw = self:GetAngles().yaw
	self:SONARDevDisplayAngles(0.15)

	--Put on a 2 second timer
	self:GetWaterHeight()

	if self.ActiveTransmitting and ACF.CurTime > self.NextPing then
			self:activeSonar()
			self.NextPing = ACF.CurTime + self.PulseDuration
	end

end

function ENT:SONARIsInCone(TarAng)

	local BeamTest = self.BeamWidth * 0.5 --0.5 of the max angle limit. In this case 270
	local LocalYaw = math.NormalizeAngle(TarAng - self.BeamAngle)

	--print("BeamWidth: " .. BeamTest)
	--print("LocalYaw: " .. math.Round(LocalYaw,0))

	if math.abs(LocalYaw) < BeamTest then
		return true
	end

	return false
end

function ENT:GetWaterHeight()

	local SelfPos = self:WorldSpaceCenter()

	local WaterTr = { }
	WaterTr.start = SelfPos + Vector(0,0, 50000)
	WaterTr.endpos = SelfPos - Vector(0,0, 50000)
	WaterTr.mask = MASK_WATER
	local Water = util.TraceLine( WaterTr )

	if Water.Hit then
		self.WaterZHeight = Water.HitPos.z
	else
		self.WaterZHeight = self:GetPos().z --If all else fails use our depth.
	end

end

function SONARCalculateAngle(StartPos, FinalPos)
	local PosDiff = FinalPos - StartPos
	local AngleFromTarget = PosDiff:Angle()

	return AngleFromTarget
end

function SONARCalculateDepth(Position, WaterZ)
	local Depth = -min(Position.z - WaterZ, 0)

	return Depth
end

function ENT:activeSonar()

	local ActiveSound = "acf_extra/ACE/sensors/Sonar/Medium.wav"
	local ActivePitch = 140


	if not IsValid(self) then return end
	local SelfPos = self:WorldSpaceCenter()

	--EmitSound("acf_extra/ACE/sensors/Sonar/coldwaters.wav", SelfPos, 0, CHAN_WEAPON, 1, 400 * self.PowerScale, 0, 100 ) --Formerly 107
	self:EmitSound(ActiveSound, 100 * self.PowerScale, ActivePitch, 1, CHAN_WEAPON )

	local SpeedOfSound = 1540 * 39.37 * ACF.SonarTimeCompression

	--self:SONARDevDisplayAngles(Color(255, 135, 0), self.PulseDuration)

	----------------------------------------
	--Sounds and Player liquification part--
	----------------------------------------

	for _, ply in pairs (player.GetAll()) do

		if ply:WaterLevel() == 0 then continue end
		if ply:InVehicle() then continue end
		local plyPos = ply:GetPos()
		local AngToTarg = SONARCalculateAngle(SelfPos, plyPos)

		if not self:SONARIsInCone(AngToTarg.yaw) then continue end

		local Dist = (plyPos-SelfPos):Length()

		if Dist < self.MaximumDistance * 2 then --Close enough to hear the sonar

			timer.Simple( Dist / SpeedOfSound, function()

				LOSTraceData.start = SelfPos
				LOSTraceData.endpos = plyPos
				local LOSTrace = TraceHull(LOSTraceData)

				local Ratio = 1 - (Dist / self.MaximumDistance)

				if not LOSTrace.Hit and Dist < self.MaximumDistance and not ply:HasGodMode() and ply:Alive() then
						local Damage = math.Round(100 * Ratio,0)
						if Damage > 50 then
							ply:EmitSound("npc/antlion_guard/antlion_guard_shellcrack" .. math.random(1,2) .. ".wav", 100, 40, 1, CHAN_AUTO )
						elseif Damage > 5 then
							ply:EmitSound("npc/stalker/stalker_pain" .. math.random(1,3) .. ".wav", 100, 100, 1, CHAN_AUTO )
						end
						ply:TakeDamage(Damage)
				end

				ply:EmitSound(ActiveSound, 300 * Ratio, ActivePitch, 1, CHAN_WEAPON )
			end)
		end

	end

	----------------------------------------
	-----Contraption Detection Handling-----
	----------------------------------------

	local SelfContraption = self:GetContraption()


	for Contraption in pairs(CFW.Contraptions) do
		local Base = Contraption:GetACEBaseplate()

		--print("TestSonar")

		if Contraption == SelfContraption or not IsValid(Base) then continue end

		local BasePos = Base:GetPos()
		local AngToTarg = SONARCalculateAngle(SelfPos, BasePos)

		if not self:SONARIsInCone(AngToTarg.yaw) then continue end

		if BasePos.z > self.WaterZHeight + 200 then continue end --Target must be within 5m of the water.

		local Dist = (BasePos-SelfPos):Length()

		--TestIfLayerObscured function


		--print("ContraptionEnt")

		local TravelTime = Dist / SpeedOfSound


		--Function to calculate DB lost from ratio energy lost. Clamped to 50DB minimum

		--debugoverlay.Line(SelfPos, BasePos, self.PulseDuration, Color(255, 0, 0), true)

		if Dist < self.MaximumDistance * 2 then --Target can hear our sonar

			local Ratio = math.max(1 - (Dist / self.MaximumDistance),0.4)

			timer.Simple( TravelTime, function()
				if not IsValid(Base) then return end
				debugoverlay.Line(SelfPos, BasePos, TravelTime, Color(255, 0, 183), true)
				Base:EmitSound(ActiveSound, 100, ActivePitch, 1 * Ratio, CHAN_WEAPON )
			end)

		end

		if Dist < self.MaximumDistance then --We can hear the sonar return

			local Ratio = math.max(1 - (2 * Dist / self.MaximumDistance),0.4)

			timer.Simple( TravelTime * 2, function()
				debugoverlay.Line(SelfPos, BasePos, TravelTime, Color(43, 0, 255), true)
				if not IsValid(self) then return end
				self:EmitSound(ActiveSound, 100, ActivePitch * 1, 1 * Ratio, CHAN_AUTO )
			end)

			timer.Simple( TravelTime * 2 + self.PulseDuration, function() --Needs to process full pulse

				if not IsValid(Base) then return end
				debugoverlay.Line(SelfPos, BasePos, TravelTime, Color(0, 255, 38), true)

				local ID = ACE_GetContraptionIndex(Contraption)
				local Owner = Base:CPPIGetOwner()


				self.SonarPositions[ID] = BasePos
				self.SonarVelocity[ID] = Base:GetVelocity()
				self.SonarOwners[ID] = Owner:Nick()
				self.SonarLastTracked[ID] = ACF.CurTime

				self.SonoUpdated = true --Let the sonar know to update the outputs

			end)

		end

	end
end

function ENT:CleanupSonarTracks(CleanupDelay) --Step the track forward by velocity? Or let player do that?

	local TimeAfter = ACF.CurTime - CleanupDelay
	local ShouldLoop = true

	while ShouldLoop do
		ShouldLoop = false

		for ID in pairs(self.SonarLastTracked) do
			local LastTracked = self.SonarLastTracked[ID]

			if TimeAfter > LastTracked then --Remove old track
				--print("Sonar cleaned up old contact ID: " .. ID)
				table.remove(self.SonarPositions,ID)
				table.remove(self.SonarVelocity,ID)
				table.remove(self.SonarOwners,ID)
				table.remove(self.SonarLastTracked,ID)

				self.SonoUpdated = true --Let the sonar know to update the outputs

				ShouldLoop = true
				break
			end

		end

	end

end

function ENT:UpdateSonarTracks() --Step the track forward by velocity? Or let player do that?

	--Don't update the outputs if there's nothing to update.
	if not self.SonoUpdated then return end
	self.SonoUpdated = false

	local SelfPos = self:WorldSpaceCenter()

	local SonoBearings = {}
	local SonoDepths = {}
	local SonoDistances = {}
	local SonoVelocities = {}
	local SonoID = {}
	local SonoOwner = {}
	local Distances = {} --Not an output

	local SpreadDistribution = Vector(1,1,0.25) --Scales the noise vector
	local NoZVector = Vector(1,1,0)

	--Compiles the track lists to the table

	if self.WashOut < 1 then --The sonar only works as long as it isn't washed out.
		for ID in pairs(self.SonarPositions) do
			--print(ID)

			local InaccMul = 1
			local BaseInacc = VectorRand() * 39.37
			--self.WashOut
			local SPos = self.SonarPositions[ID]
			local SVel = vector_origin --For passive sonar and when the sonar pulse isn't long enough
			local Dist = 0
			local SOwn = self.SonarOwners[ID]

			if self.ActiveTransmitting and self.PulseDuration > 4 then
				SVel = self.SonarVelocity[ID]
			end

			--Min pulse duration is 0.5
			--Max pulse duration is 10
			--Multiplier ranges from 40x to 2x
			local PulseLengthErrorMul = 20 / self.PulseDuration

			local WashOutErrorMul = 1 + self.WashOut * 2

			InaccMul = InaccMul * self.NoiseMul * SpreadDistribution * PulseLengthErrorMul * WashOutErrorMul

			--Max errormul = 20x PL * 2x WO = 40x
			--Max Error = 1m * 40x = 40m
			OutputPosition = SPos + BaseInacc * InaccMul
			OutputDistance = OutputPosition:Distance(SelfPos) --/ 39.3701

			local Bearing = SONARCalculateAngle(SelfPos, OutputPosition).yaw
			local Depth = SONARCalculateDepth(OutputPosition, self.WaterZHeight)
			if self.ActiveTransmitting and self.PulseDuration > 0.5 then
				Dist = ((SelfPos - OutputPosition) * NoZVector):Length()
			end
			--print("SonoBearing: " .. math.Round(Bearing / 39.37,1))
			--print("SonoDepth: " .. math.Round(Depth / 39.37,2))
			--print("SonoDist: " .. math.Round(Dist / 39.37,2))
			debugoverlay.Cross(OutputPosition,35,self.PulseDuration,Color( 183, 0, 255), true)

			local InsertionIndex = ACE_GetBinaryInsertIndex(Distances, OutputDistance)
			tableInsert(SonoBearings, InsertionIndex, Bearing)
			tableInsert(SonoDepths, InsertionIndex, Depth)
			tableInsert(SonoDistances, InsertionIndex, Dist)
			tableInsert(SonoVelocities, InsertionIndex, SVel)
			tableInsert(SonoID, InsertionIndex, ID)
			tableInsert(SonoOwner, InsertionIndex, SOwn)

		end
	end


	--Updates the wire outputs using the tables
	if table.Count( SonoID ) > 0 then

		WireLib.TriggerOutput( self, "Detected"	, 1 )
		WireLib.TriggerOutput( self, "Bearing", SonoBearings )
		WireLib.TriggerOutput( self, "Depth", SonoDepths )
		WireLib.TriggerOutput( self, "Distance", SonoDistances )
		WireLib.TriggerOutput( self, "Velocity", SonoVelocities )
		WireLib.TriggerOutput( self, "ID", SonoID )
		WireLib.TriggerOutput( self, "Owner", SonoOwner ) --SonoVelocities


		self.OutputData.Detected = 0
		self.OutputData.Bearing = SonoBearings
		self.OutputData.Depth = SonoDepths
		self.OutputData.Distance = SonoDistances
		self.OutputData.Velocity = SonoVelocities
		self.OutputData.ID = SonoID
		self.OutputData.Owner = SonoOwner

	else
		WireLib.TriggerOutput( self, "Detected"	, 0 )
		WireLib.TriggerOutput( self, "Bearing", {} )
		WireLib.TriggerOutput( self, "Depth", {} )
		WireLib.TriggerOutput( self, "Distance", {} )
		WireLib.TriggerOutput( self, "Velocity", {} )
		WireLib.TriggerOutput( self, "ID", {} )
		WireLib.TriggerOutput( self, "Owner", {} )

		self.OutputData.Detected = 0
		self.OutputData.Bearing = {}
		self.OutputData.Depth = {}
		self.OutputData.Distance = {}
		self.OutputData.Velocity = {}
		self.OutputData.ID = {}
		self.OutputData.Owner = {}
	end

end


function ENT:UpdateStatus()
	self.Status = self.Active and "On" or "Off"
end

function ENT:Think()

	local curTime = ACF.CurTime

	-- Legal check system
	if ACF.CurTime > self.NextLegalCheck then

		self.Legal, self.LegalIssues = ACF_CheckLegal(self, self.Model, math.Round(self.Weight,2), nil, true, true)
		self.NextLegalCheck = ACF.Legal.NextCheck(self.legal)

		if not self.Legal then
			self.Active = false
			self:SetActive(false)
		end

	end

	if self.Active and self.Legal then
		self:DoSonarFunctions()
		self:CleanupSonarTracks(self.PulseDuration + 0.5) --Wait the duration of an active pulse before cleaning up contacts.
		self:UpdateSonarTracks()
	end

	if (self.LastStatusUpdate + self.StatusUpdateDelay) < curTime then
		self:UpdateStatus()
		self.LastStatusUpdate = curTime
	end

	self:UpdateOverlayText()

	self:NextThink(curTime + self.ThinkDelay)
	return true
end

function ENT:UpdateOverlayText()
	local status	= self.Status or "Off"
	local detected  = status ~= "Off" and self.TargetDetected or false
	local range		= self.BaseMaximumDistance or 0
	local range2	= self.MaximumDistance or 0

	local txt = "Status: " .. status


	txt = txt .. "\n\nCurrent Range: " .. math.Round(range2 / 39.37 * 2 , 2) .. " m" 

	txt = txt .. "\n\nMax Omnidirectional Range: " .. math.Round(range / 39.37 , 2) .. " m" 
	txt = txt .. "\nMax Directional Range: " .. math.Round(range / 39.37 * 2 , 2) .. " m" 

	if detected then
		txt = txt .. "\n\nTarget Detected!"
	end

	if not self.Legal then
		txt = txt .. "\n\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
	end

	self:SetOverlayText(txt)
end



local function GetParticleMul()
	return math.max( tonumber( LocalPlayer():GetInfo("acf_cl_particlemul") ) or 1, 1)
end

--[[---------------------------------------------------------
	Initializes the effect. The data is a table of data
	which was passed from the server.
]]-----------------------------------------------------------

function EFFECT:Init( data )

	local Gun = data:GetEntity()
	if not IsValid(Gun) then return end

	if not Gun.Parent then
		Gun.Parent = ACF_GetPhysicalParent(Gun) or Gun
	--	print(Gun.Parent)
	end

	self.GunVelocity = Vector()

	if IsValid(Gun.Parent) then
		self.GunVelocity = Gun.Parent:GetVelocity()
	else
		self.GunVelocity = Gun:GetVelocity()
	end

	--print(self.GunVelocity:Length())

	local Propellant   = data:GetScale()
	local ReloadTime   = data:GetMagnitude()

	local Sound        = Gun:GetNWString( "Sound", "" )
	local SoundPitch   = Gun:GetNWInt( "SoundPitch", 100 )
	local Class        = Gun:GetNWString( "Class", "C" )
	local Caliber      = Gun:GetNWInt( "Caliber", 1 ) * 10
	local MuzzleEffect = Gun:GetNWString( "Muzzleflash", "50cal_muzzleflash_noscale" )

	--This tends to fail
	local ClassData	= ACF.Classes.GunClass[Class]
	local Attachment	= "muzzle"

	if ClassData then

		local longbarrel	= ClassData.longbarrel or nil

		if longbarrel ~= nil and Gun:GetBodygroup( longbarrel.index ) == longbarrel.submodel then
			Attachment = longbarrel.newpos
		end

	end

	if not IsValidSound( Sound ) then
		Sound = ClassData.sound
	end

	if Propellant > 0 then

		ACE_SGunFire( Gun, Sound, SoundPitch, Propellant )

		local Muzzle = Gun:GetAttachment( Gun:LookupAttachment(Attachment)) or { Pos = Gun:GetPos(), Ang = Gun:GetAngles() }

		--ParticleEffect( MuzzleEffect , Muzzle.Pos, Muzzle.Ang, Gun )

		if Gun:WaterLevel() ~= 3 then

			self.Origin 		= Muzzle.Pos
			self.DirVec        = Muzzle.Ang:Forward()
--			self.Radius 		= (Propellant * 1.35)
			self.Radius 		= (Caliber / 8)
			self.Emitter       = ParticleEmitter( self.Origin )
			self.ParticleMul   = GetParticleMul()

			ACF_RenderLight(Gun:EntIndex(), Caliber * 75, Color(255, 128, 48), Muzzle.Pos + self.DirVec * (Caliber / 5))


			local GroundTr = { }
			GroundTr.start = self.Origin + Vector(0,0,1) * self.Radius
			GroundTr.endpos = self.Origin - Vector(0,0,1) * self.Radius * 15
			GroundTr.mask = MASK_NPCWORLDSTATIC
			local Ground = util.TraceLine( GroundTr )


			local Mat = Ground.MatType or 0
			MatVal = ACE_GetMaterialName( Mat )

			if Ground.HitNonWorld then --Overide with ACE prop material
				Mat = Mat
				--self.HitNorm = -self.HitNorm
				--self.DirVec = -self.DirVec
				local TEnt = Ground.Entity
					--I guess the material is serverside only ATM? TEnt.ACF.Material doesn't return anything valid.
					--TODO: Add clienside way to get ACF Material
					MatVal = "Metal"
			end

			local Mat = Ground.MatType or 0
			local Material = ACE_GetMaterialName( Mat )
			local SmokeColor = ACE.DustMaterialColor[MatVal] or ACE.DustMaterialColor["Concrete"] --Enabling lighting on particles produced some yucky results when gravity pulled particles below the map.
			local SMKColor = Color( SmokeColor.r, SmokeColor.g, SmokeColor.b, 150 ) --Used to prevent it from overwriting the global smokecolor :/
			local AmbLight = render.GetLightColor( self.Origin ) * 2 + render.GetAmbientLightColor()
			SMKColor.r = math.floor(SMKColor.r * math.Clamp( AmbLight.x, 0, 1 )*0.9)
			SMKColor.g = math.floor(SMKColor.g * math.Clamp( AmbLight.y, 0, 1 )*0.9)
			SMKColor.b = math.floor(SMKColor.b * math.Clamp( AmbLight.z, 0, 1 )*0.9)

			self.HitNormal = Ground.HitNormal


			if MuzzleEffect == "RAC" then
				self:Shockwave( Ground, SMKColor )
				self:MuzzleSmokeRAC( Ground, Color( 150, 150, 150, 100 ) )
			else
				self:Shockwave( Ground, SMKColor )
				self:MuzzleSmoke( Ground, Color( 150, 150, 150, 100 ) )
			end


		end

		local PlayerDist = (LocalPlayer():GetPos() - self.Origin):Length() / 80 + 0.001 --Divide by 0 is death

		if PlayerDist < self.Radius*4 and not LocalPlayer():HasGodMode() then
			local Amp          = math.min(Propellant * 1.5 / math.max(PlayerDist,5),40)
			--local Amp          = math.min(self.Radius / 1.5 / math.max(PlayerDist,5),40)
			util.ScreenShake( self.Origin, 50 * Amp, 1.5 / Amp, math.min(Amp  * 2,self.Radius/20), 0 , true)
		end



		if Gun.Animate then
			Gun:Animate( Class, ReloadTime, false )
		end
	else
		if Gun.Animate then
			Gun:Animate( Class, ReloadTime, true )
		end
	end


end


--[[---------------------------------------------------------
	THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	return false
end

--[[---------------------------------------------------------
	Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end




function EFFECT:Shockwave( Ground, SmokeColor )

	if not self.Emitter then return end

	local PMul       = self.ParticleMul
	local Radius     = (1-Ground.Fraction) * self.Radius * 1
	local Density    = Radius * 6
	local Angle      = Ground.HitNormal:Angle()

	for _ = 0, Density * PMul do

		Angle:RotateAroundAxis(Angle:Forward(), 360 / Density)
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1,9), Ground.HitPos )

		if Smoke then
			Smoke:SetVelocity( ShootVector * 350 * Radius * math.Rand(0.3, 1) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime(  0.35 * Radius/4 )
			Smoke:SetStartAlpha( 125 )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 5 * Radius )
			Smoke:SetEndSize( 35 * Radius )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )
			Smoke:SetAirResistance( 100 )
			Smoke:SetGravity(Vector(0, 0, 500))
			local SMKColor = math.random( 0 , 20 )
			Smoke:SetColor( SmokeColor.r + SMKColor, SmokeColor.g + SMKColor, SmokeColor.b + SMKColor )
		end
	end


end

function EFFECT:MuzzleSmokeRAC( Ground, SmokeColor )

	if not self.Emitter then return end

	local PMul       = self.ParticleMul
	local size    = self.Radius * 1

	local Angle      = self.DirVec:Angle()


	local AdjOrigin = self.Origin + self.DirVec * -1 * size
	for _ = 0, size * PMul / 3 do

		Angle:RotateAroundAxis(Angle:Forward(), 360 / size * 3 * math.Rand(0.8, 1.0))
		local ShootVector = Angle:Right()
		local Smoke = self.Emitter:Add( "particles/smokey", AdjOrigin)

		if Smoke then
			Smoke:SetVelocity( ShootVector * 45 * size + self.DirVec * 30 * size * math.Rand(0.8, 1.0) + self.GunVelocity * 1.5 )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime(  1.75 * size/4 )
			Smoke:SetStartAlpha( 25 )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 1 * size )
			Smoke:SetEndSize( 15 * size )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )
			Smoke:SetAirResistance( 250 )
			Smoke:SetGravity(Vector(0, 0, 0))
			local SMKColor = math.random( 0 , 20 )
			Smoke:SetColor( SmokeColor.r + SMKColor, SmokeColor.g + SMKColor, SmokeColor.b + SMKColor )
		end
	end


	local ParticleCount = math.ceil( math.Clamp( size / 3 , 5, 150 ) * PMul )

	AdjOrigin = self.Origin + self.DirVec * -6 * size

	local DustSpeed = 1
	for i = 1, ParticleCount do
		local Dust = self.Emitter:Add("particles/smokey", AdjOrigin + self.DirVec * size * (-10 + 25 * (i/ParticleCount)) )

		if Dust then
			Dust:SetVelocity(self.DirVec * DustSpeed * size * 15 + self.GunVelocity * 1.5)
			DustSpeed = DustSpeed + (2) * (i/ParticleCount)
			Dust:SetLifeTime(0)
			Dust:SetDieTime(1 * (size / 3))
			Dust:SetStartAlpha(25 * (i/ParticleCount))
			Dust:SetEndAlpha(0)
			Dust:SetStartSize(1 * size)
			Dust:SetEndSize(8 * (3 + DustSpeed/7.5) * size * (i/ParticleCount))
			Dust:SetRoll(math.Rand(150, 360))
			Dust:SetRollDelta(math.Rand(-0.2, 0.2))
			Dust:SetAirResistance(200)
			Dust:SetGravity(Vector(0, 0, -100))
			Dust:SetColor(SmokeColor.r, SmokeColor.g, SmokeColor.b)
		end
	end

	local Dust = self.Emitter:Add("effects/muzzleflash".. math.random(1,4), self.Origin - self.DirVec * size * 10 )

	if Dust then
		Dust:SetVelocity(self.DirVec * size * 55 + self.GunVelocity)
		Dust:SetLifeTime(0)
		Dust:SetDieTime(0.2 * (size / 3))
		Dust:SetStartAlpha(255)
		Dust:SetEndAlpha(255)
		Dust:SetStartSize(0.5 * size)
		Dust:SetEndSize(7 * size)
		Dust:SetRoll(math.Rand(150, 360))
		Dust:SetRollDelta(math.Rand(-0.2, 0.2))
		Dust:SetAirResistance( 0 )
		Dust:SetGravity(Vector(0, 0, 0))
		Dust:SetLighting( false )
		local Length = 25 * size
		Dust:SetStartLength( Length )
		Dust:SetEndLength( Length*1 )
	end

	local Dust = self.Emitter:Add("effects/muzzleflash".. math.random(1,4), self.Origin  )

	if Dust then
		Dust:SetVelocity(self.DirVec * size * 35 + self.GunVelocity)
		Dust:SetLifeTime(0)
		Dust:SetDieTime(0.15 * (size / 3))
		Dust:SetStartAlpha(200)
		Dust:SetEndAlpha(15)
		Dust:SetStartSize(1 * size)
		Dust:SetEndSize(10 * size)
		Dust:SetRoll(math.Rand(150, 360))
		Dust:SetRollDelta(math.Rand(-0.2, 0.2))
		Dust:SetAirResistance( 0 )
		Dust:SetGravity(Vector(0, 0, 0))
		Dust:SetLighting( false )
	end

	local Dust = self.Emitter:Add("sprites/orangeflare1", self.Origin  )

	if Dust then
		Dust:SetVelocity(self.DirVec * size * 15 + self.GunVelocity)
		Dust:SetLifeTime(0)
		Dust:SetDieTime(0.1 * (size / 3))
		Dust:SetStartAlpha(60)
		Dust:SetEndAlpha(0)
		Dust:SetStartSize(2 * size)
		Dust:SetEndSize(3 * size)
		Dust:SetRoll(math.Rand(150, 360))
		Dust:SetRollDelta(math.Rand(-0.2, 0.2))
		Dust:SetAirResistance( 0 )
		Dust:SetGravity(Vector(0, 0, 0))
		Dust:SetLighting( false )
	end

	local Dust = self.Emitter:Add("effects/ar2_altfire1b", self.Origin  )

	if Dust then
		Dust:SetVelocity(self.DirVec * size * 10 + self.GunVelocity)
		Dust:SetLifeTime(0)
		Dust:SetDieTime(0.1 * (size / 3))
		Dust:SetStartAlpha(100)
		Dust:SetEndAlpha(15)
		Dust:SetStartSize(0)
		Dust:SetEndSize(3 * size)
		Dust:SetRoll(math.Rand(150, 360))
		Dust:SetRollDelta(math.Rand(-0.2, 0.2))
		Dust:SetAirResistance( 0 )
		Dust:SetGravity(Vector(0, 0, 0))
		Dust:SetLighting( false )
	end

end


function EFFECT:MuzzleSmoke( Ground, SmokeColor )

	if not self.Emitter then return end

	local PMul       = self.ParticleMul
	local size    = self.Radius * 1

	local Angle      = self.DirVec:Angle()

	for _ = 0, size * 2 * PMul do

		Angle:RotateAroundAxis(Angle:Forward(), 360 / size * 2 * math.Rand(0.8, 1.0))
		local ShootVector = Angle:Right()
		local Smoke = self.Emitter:Add( "particles/smokey", self.Origin )

		if Smoke then
			Smoke:SetVelocity( ShootVector * 45 * size - self.DirVec * 40 * size * math.Rand(0.8, 1.0) + self.GunVelocity * 1.5 )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime(  1.75 * size/4 )
			Smoke:SetStartAlpha( 25 )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 1 * size )
			Smoke:SetEndSize( 15 * size )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )
			Smoke:SetAirResistance( 250 )
			Smoke:SetGravity(Vector(0, 0, 0))
			local SMKColor = math.random( 0 , 20 )
			Smoke:SetColor( SmokeColor.r + SMKColor, SmokeColor.g + SMKColor, SmokeColor.b + SMKColor )
		end
	end


	local ParticleCount = math.ceil( math.Clamp( size , 6, 150 ) * PMul )

	local DustSpeed = 1
	for i = 1, ParticleCount do
		local Dust = self.Emitter:Add("particles/smokey", self.Origin + self.DirVec * size * (-10 + 25 * (i/ParticleCount)) )

		if Dust then
			Dust:SetVelocity(self.DirVec * DustSpeed * size * 15 + self.GunVelocity * 1.5)
			DustSpeed = DustSpeed + (2) * (i/ParticleCount)
			Dust:SetLifeTime(0)
			Dust:SetDieTime(2 * (size / 3))
			Dust:SetStartAlpha(50 * (i/ParticleCount))
			Dust:SetEndAlpha(0)
			Dust:SetStartSize(2 * size)
			Dust:SetEndSize(15 * (3 + DustSpeed/7.5) * size * (i/ParticleCount))
			Dust:SetRoll(math.Rand(150, 360))
			Dust:SetRollDelta(math.Rand(-0.2, 0.2))
			Dust:SetAirResistance(200)
			Dust:SetGravity(Vector(0, 0, -150))
			Dust:SetColor(SmokeColor.r, SmokeColor.g, SmokeColor.b)
		end
	end

	local Dust = self.Emitter:Add("effects/muzzleflash".. math.random(1,4), self.Origin  )

	if Dust then
		Dust:SetVelocity(self.DirVec * size * 55 + self.GunVelocity)
		Dust:SetLifeTime(0)
		Dust:SetDieTime(0.2 * (size / 3))
		Dust:SetStartAlpha(255)
		Dust:SetEndAlpha(255)
		Dust:SetStartSize(1 * size)
		Dust:SetEndSize(10 * size)
		Dust:SetRoll(math.Rand(150, 360))
		Dust:SetRollDelta(math.Rand(-0.2, 0.2))
		Dust:SetAirResistance( 0 )
		Dust:SetGravity(Vector(0, 0, 0))
		Dust:SetLighting( false )
		local Length = 25 * size
--		Dust:SetStartLength( Length )
--		Dust:SetEndLength( Length*1 )
	end

	local Dust = self.Emitter:Add("effects/muzzleflash".. math.random(1,4), self.Origin  )

	if Dust then
		Dust:SetVelocity(self.DirVec * size * 15 + self.GunVelocity)
		Dust:SetLifeTime(0)
		Dust:SetDieTime(0.15 * (size / 3))
		Dust:SetStartAlpha(200)
		Dust:SetEndAlpha(15)
		Dust:SetStartSize(1 * size)
		Dust:SetEndSize(10 * size)
		Dust:SetRoll(math.Rand(150, 360))
		Dust:SetRollDelta(math.Rand(-0.2, 0.2))
		Dust:SetAirResistance( 0 )
		Dust:SetGravity(Vector(0, 0, 0))
		Dust:SetLighting( false )
	end

	local Dust = self.Emitter:Add("sprites/orangeflare1", self.Origin  )

	if Dust then
		Dust:SetVelocity(self.DirVec * size * 15 + self.GunVelocity)
		Dust:SetLifeTime(0)
		Dust:SetDieTime(0.1 * (size / 3))
		Dust:SetStartAlpha(60)
		Dust:SetEndAlpha(0)
		Dust:SetStartSize(2 * size)
		Dust:SetEndSize(3 * size)
		Dust:SetRoll(math.Rand(150, 360))
		Dust:SetRollDelta(math.Rand(-0.2, 0.2))
		Dust:SetAirResistance( 0 )
		Dust:SetGravity(Vector(0, 0, 0))
		Dust:SetLighting( false )
	end

	local Dust = self.Emitter:Add("effects/ar2_altfire1b", self.Origin  )

	if Dust then
		Dust:SetVelocity(self.DirVec * size * 15 + self.GunVelocity)
		Dust:SetLifeTime(0)
		Dust:SetDieTime(0.1 * (size / 3))
		Dust:SetStartAlpha(100)
		Dust:SetEndAlpha(15)
		Dust:SetStartSize(0)
		Dust:SetEndSize(4 * size)
		Dust:SetRoll(math.Rand(150, 360))
		Dust:SetRollDelta(math.Rand(-0.2, 0.2))
		Dust:SetAirResistance( 0 )
		Dust:SetGravity(Vector(0, 0, 0))
		Dust:SetLighting( false )
	end

end

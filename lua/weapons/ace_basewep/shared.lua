	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACE Base"
	SWEP.Author				= "RDC"
	SWEP.Contact			= "Discord: RDC#7737"	
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "y"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "You shouldn't have this"
	SWEP.Instructions       = ""

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACE Sweps"
SWEP.ViewModel 			= "models/weapons/v_snip_sg550.mdl";
SWEP.WorldModel 		= "models/weapons/w_snip_sg550.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 10
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 5
SWEP.Primary.RecoilAngleVer	= 1
SWEP.Primary.RecoilAngleHor	= 1
SWEP.Primary.ClipSize		= 5
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_SG550.Single"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

// misnomer.  the position of the acf muzzleflash.
SWEP.AimOffset = Vector(32, 8, -1)

// use this to chop the scope off your gun
SWEP.ScopeChopPos = Vector(0, 0, 0)
SWEP.ScopeChopAngle = Angle(0, 0, -90)

SWEP.ZoomTime = 0.4


SWEP.InaccuracyCrouchBonus = 1.7
SWEP.InaccuracyDuckPenalty = 6

SWEP.HasZoom = true
SWEP.HasScope = false

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false

SWEP.InaccuracyAccumulation = 1

SWEP.ZoomFOV = 50
SWEP.ZoomAccuracyImprovement = 0.2 -- 0.3 means 0.7 the inaccuracy
SWEP.ZoomRecoilImprovement = 0.5 -- 0.3 means 0.7 the recoil movement

SWEP.CrouchAccuracyImprovement = 0.2 -- 0.3 means 0.7 the inaccuracy
SWEP.CrouchRecoilImprovement = 0.5 -- 0.3 means 0.7 the recoil movement

SWEP.IronSights = true
SWEP.IronSightsPos = Vector(-2, -4.74, 2.98)
SWEP.ZoomPos = Vector(2,-2,2)
SWEP.IronSightsAng = Angle(0.45, 0, 0)
SWEP.CarrySpeedMul = 1 --WalkSpeedMult when carrying the weapon

SWEP.NormalPlayerWalkSpeed = 1000
SWEP.NormalPlayerRunSpeed = 1000


function SWEP:Think()
	
	if CLIENT then
		self:ZoomThink()
	end
	
	
	
	if self.ThinkAfter then self:ThinkAfter() end
	
	
	if SERVER then
        
        if self.Zoomed and not self:CanZoom() then
            self:SetZoom(false)
        end
        
	end
	
end

function SWEP:InitBulletData()
	
	self.BulletData = {}

		self.BulletData.Id = "7.62mmMG"
		self.BulletData.Type = "AP"
		self.BulletData.Id = 1
		self.BulletData.Caliber = 0.556
		self.BulletData.PropLength = 4 --Volume of the case as a cylinder * Powder density converted from g to kg		
		self.BulletData.ProjLength = 8 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
		self.BulletData.Data5 = 0  --He Filler or Flechette count
		self.BulletData.Data6 = 0 --HEAT ConeAng or Flechette Spread
		self.BulletData.Data7 = 0
		self.BulletData.Data8 = 0
		self.BulletData.Data9 = 0
		self.BulletData.Data10 = 1 -- Tracer
		self.BulletData.Colour = Color(255, 0, 0)
		--
		self.BulletData.Data13 = 0 --THEAT ConeAng2
		self.BulletData.Data14 = 0 --THEAT HE Allocation
		self.BulletData.Data15 = 0
	
		self.BulletData.AmmoType  = self.BulletData.Type
		self.BulletData.FrAera    = 3.1416 * (self.BulletData.Caliber/2)^2
		self.BulletData.ProjMass  = self.BulletData.FrAera * (self.BulletData.ProjLength*7.9/1000)
		self.BulletData.PropMass  = self.BulletData.FrAera * (self.BulletData.PropLength*ACF.PDensity/1000) --Volume of the case as a cylinder * Powder density converted from g to kg
		self.BulletData.FillerVol = self.BulletData.Data5
		self.BulletData.FillerMass = self.BulletData.FillerVol * ACF.HEDensity/1000
		--		self.BulletData.DragCoef  = 0 --Alternatively manually set it
		self.BulletData.DragCoef  = ((self.BulletData.FrAera/10000)/self.BulletData.ProjMass)	

		--Don't touch below here
		self.BulletData.MuzzleVel = ACF_MuzzleVelocity( self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber )		
		self.BulletData.ShovePower = 0.2
		self.BulletData.KETransfert = 0.3
		self.BulletData.PenAera = self.BulletData.FrAera^ACF.PenAreaMod
		self.BulletData.Pos = Vector(0 , 0 , 0)
		self.BulletData.LimitVel = 800	
		self.BulletData.Ricochet = 60
		self.BulletData.Flight = Vector(0 , 0 , 0)
		self.BulletData.BoomPower = self.BulletData.PropMass + self.BulletData.FillerMass
		self.BulletData.FuseLength = 0
		--For Fake Crate
		self.Type = self.BulletData.Type
		self.BulletData.Tracer = self.BulletData.Data10
		self.Tracer = self.BulletData.Tracer
		self.Caliber = self.BulletData.Caliber
		self.ProjMass = self.BulletData.ProjMass
		self.FillerMass = self.BulletData.FillerMass
		self.DragCoef = self.BulletData.DragCoef
		self.Colour = self.BulletData.Colour
		self.DetonatorAngle = 80
		
end

function SWEP:CanZoom()

 --   local sprinting = self.Owner:KeyDown(IN_SPEED)
 --   if sprinting then return false end
    
    return true

end

function SWEP:SecondaryAttack()

	if SERVER and self.HasZoom and self:CanZoom() then
		self:SetZoom()
	end

	return false
	
end

function SWEP:SetZoom(zoom)

    if zoom == nil then
        self.Zoomed = not self.Zoomed
    else
        self.Zoomed = zoom
    end
	
	
	if SERVER then self:SetNWBool("Zoomed", self.Zoomed) end
	
	if self.Zoomed then
		
		if SERVER then 
            self:SetOwnerZoomSpeed(true)
            self.Owner:SetFOV(self.ZoomFOV, 0.25) 
        end
        
	else			
		
		if SERVER then 
            self:SetOwnerZoomSpeed(false)
            self.Owner:SetFOV(0, 0.25) 
        end
        
	end

	
--	self:GetViewModelPosition(self.Owner:EyePos(), self.Owner:EyeAngles())
end

function SWEP:SetOwnerZoomSpeed(setSpeed)
	if ( CLIENT ) then return end
    if setSpeed then
    
        self.Owner:SetWalkSpeed( self.NormalPlayerWalkSpeed * 0.5 * self.CarrySpeedMul )
        self.Owner:SetRunSpeed( self.NormalPlayerRunSpeed * 0.5 * self.CarrySpeedMul)
        
    elseif self.NormalPlayerWalkSpeed and self.NormalPlayerRunSpeed then
    
        self.Owner:SetWalkSpeed( self.NormalPlayerWalkSpeed * self.CarrySpeedMul)
        self.Owner:SetRunSpeed( self.NormalPlayerRunSpeed * self.CarrySpeedMul)
        
    end

end


-- Adjust these variables to move the viewmodel's position
SWEP.IronSightsPos = Vector( 15, 0, 0 )
SWEP.IronSightsAng = Vector( 0, 0, 0 )

function SWEP:GetViewModelPosition( EyePos, EyeAng )
	local Mul = 0

	local Offset = self.IronSightsPos

	if ( self.IronSightsAng ) then
		EyeAng = EyeAng * 1

		EyeAng:RotateAroundAxis( EyeAng:Right(), 	self.IronSightsAng.x * Mul )
		EyeAng:RotateAroundAxis( EyeAng:Up(), 		self.IronSightsAng.y * Mul )
		EyeAng:RotateAroundAxis( EyeAng:Forward(),	self.IronSightsAng.z * Mul )
	end

	local Right 	= EyeAng:Right()
	local Up 		= EyeAng:Up()
	local Forward 	= EyeAng:Forward()

	EyePos = EyePos + Offset.x * Right * Mul
	EyePos = EyePos + Offset.y * Forward * Mul
	EyePos = EyePos + Offset.z * Up * Mul

	return EyePos, EyeAng
end	


function SWEP:ACEFireBullet()


	self.Owner = self:GetParent()
--	self:SetOwner(self:GetParent())
	local ZoomedNumber = self.Zoomed and 1 or 0
	local CrouchedNumber = self.Owner:Crouching() and 1 or 0
		
	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()

	
	local EyeAngle = self.Owner:EyeAngles()
	--Boolet Firing
	local RandUnitSquare = (EyeAngle:Up() * (2 * math.random() - 1) + EyeAngle:Right() * (2 * math.random() - 1))
	local Spread = RandUnitSquare:GetNormalized() * self.Primary.Cone * (self.InaccuracyAccumulation - self.ZoomAccuracyImprovement * ZoomedNumber - self.CrouchAccuracyImprovement * CrouchedNumber) * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4)))
--	local Spread = Vector(0 , 0 , 0)
--	local Spread = EyeAngle:Forward()/10 * SWEP.coneAng * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4))) 
	local ShootVec = EyeAngle:Forward()+Spread
--	local ShootVec = EyeAngle:Forward()
	
	self.BulletData.Pos = MuzzlePos+EyeAngle:Forward()*35
	self.BulletData.Flight = ShootVec * self.BulletData.MuzzleVel * 39.37 + self.Owner:GetVelocity()
--	self.BulletData.Flight = ShootVec * self.BulletData.MuzzleVel * 39.37
	
--	print("MV: "..self.BulletData.Flight:Length()/39.37)
	self.BulletData.Owner = self:GetParent()
	self.BulletData.Gun = self:GetParent()
	self.BulletData.Crate = self.FakeCrate:EntIndex()
	
	if self.BeforeFire then
		self:BeforeFire()
	end
	
--function Round.create( Gun, BulletData )
	
--	ACF_CreateBullet( BulletData )
	
--end
	
	self.CreateShell = ACF.RoundTypes[self.BulletData.Type].create
	self:CreateShell( self.BulletData )	
	
--	self.Owner:SetEyeAngles( EyeAngle+Angle(math.random(-1,1)*self.Primary.RecoilAngleVer,math.random(-1,1)*self.Primary.RecoilAngleHor,0) * (self.InaccuracyAccumulation - CrouchedNumber * self.CrouchRecoilImprovement - self.ZoomRecoilImprovement * ZoomedNumber) )
end

function SWEP:DoImpactEffect( tr, nDamageType )
return true
end
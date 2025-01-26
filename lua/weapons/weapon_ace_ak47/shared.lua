SWEP.Base = "weapon_ace_base"
SWEP.PrintName = "AK-47"
SWEP.Category = "ACE Weapons"
SWEP.SubCategory = "Assault Rifles"
SWEP.Purpose = "Slavic bullet thrower"
SWEP.Spawnable = true

SWEP.Slot = 2
SWEP.SlotPos = 1

--Main settings--
SWEP.FireRate = 10 --Rounds per second

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 180
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Sound = "ace_weapons/sweps/multi_sound/ak47_multi.mp3"
SWEP.Primary.LightScale = 200 --Muzzleflash light radius
SWEP.Primary.BulletCount = 1 --Number of bullets to fire each shot, used for shotguns

SWEP.ReloadSound = "Weapon_Pistol.Reload" --Sound other players hear when you reload - this is NOT your first-person sound
										--Most models have a built-in first-person reload sound
SWEP.ReticuleSize = 35
SWEP.ZoomFOV = 60
SWEP.HasScope = false --True if the weapon has a sniper-style scope


--Recoil (crosshair movement) settings--
--"Heat" is a number that represents how long you've been firing, affecting how quickly your crosshair moves upwards
SWEP.HeatReductionRate = 300 --Heat loss per second when not firing
SWEP.HeatPerShot = 10 --Heat generated per shot
SWEP.HeatMax = 80 --Maximum heat - determines max rate at which recoil is applied to eye angles
				--Also determines point at which random spread is at its highest intensity
				--HeatMax divided by HeatPerShot gives you how many shots until you reach MaxSpread

SWEP.AngularRecoil = 30	--Amount of angular recoil

--How much the recoil is biased to one side proportional to vertical recoil
--Positive numbers bias to the right, negative to the left
SWEP.RecoilSideBias = 0.15

SWEP.ZoomRecoilBonus = 0.5 --Reduce recoil by this amount when zoomed or scoped
SWEP.CrouchRecoilBonus = 0.2 --Reduce recoil by this amount when crouching
SWEP.ViewPunchAmount = 0 --Degrees to punch the view upwards each shot - does not actually move crosshair, just a visual effect


--Spread (aimcone) settings--
SWEP.BaseSpread = 0.1 --First-shot random spread, in degrees
SWEP.MaxSpread = 3 --Maximum added random spread from heat value, in degrees
					--If HeatMax is 0 this will be ignored and only BaseSpread will be taken into account (AT4 for example)
SWEP.MovementSpread = 1.5 --Increase aimcone to this many degrees when sprinting at full speed
SWEP.UnscopedSpread = 0.4 --Spread, in degrees, when unscoped with a scoped weapon


--Model settings--
SWEP.ViewModelFlip = true
SWEP.ViewModel = "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.HoldType = "ar2"
SWEP.DeployDelay = 1 --Time before you can fire after deploying the weapon
SWEP.CSMuzzleFlashes = true



SWEP.CarrySpeedMul			= 1 --WalkSpeedMult when carrying the weapon

SWEP.NormalPlayerWalkSpeed	= 200 --Default walk and sprint speed in case all else fails
SWEP.NormalPlayerRunSpeed	= 400

SWEP.SwayScale = 0.3
SWEP.BobScale = 0.4

function SWEP:InitBulletData()
	self.BulletData = {}

	self.BulletData.Id = "7.62mmMG"
	self.BulletData.Type = "AP"
	self.BulletData.Id = 1
	self.BulletData.Caliber = 0.762
	self.BulletData.PropLength = 6 --Volume of the case as a cylinder * Powder density converted from g to kg
	self.BulletData.ProjLength = 4 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
	self.BulletData.Data5 = 0  --He Filler or Flechette count
	self.BulletData.Data6 = 0 --HEAT ConeAng or Flechette Spread
	self.BulletData.Data7 = 0
	self.BulletData.Data8 = 0
	self.BulletData.Data9 = 0
	self.BulletData.Data10 = 1 -- Tracer
	self.BulletData.Colour = Color(0, 255, 0)

	self.BulletData.Data13 = 0 --THEAT ConeAng2
	self.BulletData.Data14 = 0 --THEAT HE Allocation
	self.BulletData.Data15 = 0

	self.BulletData.AmmoType = self.BulletData.Type
	self.BulletData.FrArea = 3.1416 * (self.BulletData.Caliber / 2) ^ 2
	self.BulletData.ProjMass = self.BulletData.FrArea * (self.BulletData.ProjLength * 7.9 / 1000)
	self.BulletData.PropMass = self.BulletData.FrArea * (self.BulletData.PropLength * ACF.PDensity / 1000) --Volume of the case as a cylinder * Powder density converted from g to kg
	--self.BulletData.DragCoef = 0.0075  --Manually set drag coefficient
	self.BulletData.DragCoef  = ((self.BulletData.FrArea / 10000) / self.BulletData.ProjMass) / 3

	--Don't touch below here
	self.BulletData.MuzzleVel = ACF_MuzzleVelocity(self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber)
	self.BulletData.ShovePower = 0.2
	self.BulletData.KETransfert = 0.3
	self.BulletData.PenArea = self.BulletData.FrArea ^ ACF.PenAreaMod * 1.1
	self.BulletData.Pos = Vector(0, 0, 0)
	self.BulletData.LimitVel = 800
	self.BulletData.Ricochet = 60
	self.BulletData.Flight = Vector(0, 0, 0)
	self.BulletData.BoomPower = self.BulletData.PropMass

	--For Fake Crate
	self.Type = self.BulletData.Type
	self.BulletData.Tracer = self.BulletData.Data10
	self.Tracer = self.BulletData.Tracer
	self.Caliber = self.BulletData.Caliber
	self.ProjMass = self.BulletData.ProjMass
	self.FillerMass = self.BulletData.Data5
	self.DragCoef = self.BulletData.DragCoef
	self.Colour = self.BulletData.Colour
end

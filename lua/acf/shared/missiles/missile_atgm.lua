ACF_defineGunClass("ATGM", {
	type			= "missile",
	spread			= 1,
	name			= "[ATGM] - Anti-Tank Guided Missile",
	desc			= ACFTranslation.MissileClasses[4],
	muzzleflash		= "40mm_muzzleflash_noscale",
	rofmod			= 1,
	sound			= "acf_extra/airfx/rocket_fire2.wav",
	year			= 1969,
	soundDistance	= " ",
	soundNormal		= " ",
	effect			= "Rocket Motor ATGM",
	reloadmul		= 5,
	guidanceInac	= 1,  -- How much inaccuracy this missile will have when its being guided. Note that this is a squared relation. Meaning that 20 inac means 40 units in total. Deal about it
} )

-- The BGM-71E, a wire guided missile with medium anti-tank effectiveness.
ACF_defineGun("BGM-71E ASM", {								-- id
	name			= "BGM-71E Missile",
	desc			= "The BGM-71E missile is a lightweight, wire guided anti-tank munition. It can be used in both air-to-surface and surface-to-surface combat, making it a decent alternative for ground vehicles.",
	model			= "models/missiles/bgm_71e.mdl",
	effect			= "Rocket Motor ATGM",
	gunclass		= "ATGM",
	rack			= "1x BGM-71E",								-- Which rack to spawn this missile on?
	length			= 123,										-- Used for the physics calculations
	caliber			= 13,
	weight			= 76.4,										-- Don't scale down the weight though!
	year			= 1970,
	modeldiameter	= 3 * 2.54,

	round = {
		model				= "models/missiles/bgm_71e.mdl",
		rackmdl				= "models/missiles/bgm_71e.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.5,
		reloaddelay			= 30.0,

		maxlength			= 105,							-- Length of missile. Used for ammo properties.
		propweight			= 1.2,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 15,							-- Armour effectiveness of casing, in mm

		turnrate			= 70,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.35,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 20,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 45,							-- Acceleration in m/s.
		burntime			= 5,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 30,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.002,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.1,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		penmul			= math.sqrt(0.9265)					-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)	--was 0.797
	},

	ent			= "acf_missile_to_rack",						-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Wire"},
	fuses		= {"Contact", "Optical", "Plunging"},

	racks	= {											-- a whitelist for racks that this missile can load into.
					["1x BGM-71E"] = true,
					["2x BGM-71E"] = true,
					["4x BGM-71E"] = true
				},


	viewcone		= 90,										-- getting outside this cone will break the lock.  Divided by 2.

	ghosttime		= 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay		= 0.00										-- minimum fuse arming delay
} )

ACF_defineGun("9M133 ASM", {									-- id
	name			= "9M133 Kornet Missile",
	desc			= "The Kornet is a modern antitank missile, with good range and a very powerful warhead, but somewhat limited maneuverability.",
	model			= "models/kali/weapons/kornet/parts/9m133 kornet missile.mdl",
	effect			= "Rocket Motor ATGM",
	gunclass		= "ATGM",
	rack			= "1x Kornet",							-- Which rack to spawn this missile on?
	length			= 130,
	caliber			= 15.2,
	weight			= 29,									-- Don't scale down the weight though!
	year			= 1994,
	modeldiameter	= 3 * 2.54, -- in cm

	round = {
		model				= "models/kali/weapons/kornet/parts/9m133 kornet missile.mdl",
		rackmdl				= "models/kali/weapons/kornet/parts/9m133 kornet missile.mdl",
		firedelay			= 0.5,
		reloadspeed			= 2.0,
		reloaddelay			= 40.0,

		maxlength			= 105,							-- Length of missile. Used for ammo properties.
		propweight			= 1,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 20,							-- Armour effectiveness of casing, in mm

		turnrate			= 3,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.45,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 18,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 50,							-- Acceleration in m/s.
		burntime			= 5,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 40,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.1,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		penmul			= math.sqrt(1.2)					-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)	--was 0.797
	},

	ent			= "acf_missile_to_rack",						-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser"},
	fuses		= {"Contact", "Optical"},



	racks	= {											-- a whitelist for racks that this missile can load into.
					["1x Kornet"] = true,
					["2x Kornet"] = true,
					["4x Kornet"] = true
			},

	viewcone		= 25,										-- getting outside this cone will break the lock.  Divided by 2.
	ghosttime		= 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay		= 0.00										-- minimum fuse arming delay
} )

-- The AT-3, a short-range wire-guided missile with better anti-tank effectiveness than the BGM-71E but much slower.
ACF_defineGun("AT-3 ASM", { --id
	name			= "AT-3 Sagger Missile",
	desc			= "The AT-3 missile (9M14P1) is a short-range wire-guided anti-tank munition. While powerful and lightweight its speed will make you die of old age before you hit the target.",
	model			= "models/missiles/at3.mdl",
	effect			= "Rocket Motor FFAR",
	gunclass		= "ATGM",
	rack			= "1xAT3RK",									-- Which rack to spawn this missile on?
	length			= 84,										-- Used for the physics calculations
	caliber			= 13,
	weight			= 12.5,										-- Don't scale down the weight though!
	year			= 1969,
	modeldiameter	= 3 * 2.54,
	bodydiameter     = 7, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		model				= "models/missiles/at3.mdl",
		rackmdl				= "models/missiles/at3.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.5,
		reloaddelay			= 15.0,

		maxlength			= 55,							-- Length of missile. Used for ammo properties.
		propweight			= 1.2,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 13,							-- Armour effectiveness of casing, in mm

		turnrate			= 30,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.6,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 60,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 7,							-- Acceleration in m/s.
		burntime			= 10,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 30,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.002,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.5,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		penmul			= math.sqrt(1.4)					-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)	--was 0.797
	},

	ent			= "acf_missile_to_rack",						-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Wire"},
	fuses		= {"Contact", "Optical"},

	racks	= {											-- a whitelist for racks that this missile can load into.
					["1xAT3RKS"] = true,
					["1xAT3RK"] = true,
					["1xRK_small"] = true,
					["3xRK"] = true
				},

	skinindex	= {HEAT = 0, HE = 1},
	viewcone		= 60,										-- getting outside this cone will break the lock.  Divided by 2.

	agility			= 0.1, --0.3										-- multiplier for missile turn-rate.
	ghosttime		= 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay		= 0.00										-- minimum fuse arming delay
} )

ACF_defineGun("AT-2 ASM", { --id
	name			= "AT-2 Fleyta Missile",
	desc			= "The AT-2 Missile (9M17P) is a more powerful, yet light, Anti-Tank Missile, the big brother of the Sagger. Being agile, deliveries a powerful payload at the cost of being slower than the AT-3",
	model			= "models/missiles/at2.mdl",
	effect			= "Rocket Motor FFAR",
	gunclass		= "ATGM",
	rack			= "1xRK",									-- Which rack to spawn this missile on?
	length			= 115,										-- Used for the physics calculations
	caliber			= 16,
	weight			= 27,										-- Don't scale down the weight though!
	year			= 1969,
	modeldiameter	= 2.8 * 2.54,

	round = {
		model				= "models/missiles/at2.mdl",
		rackmdl				= "models/missiles/at2.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.5,
		reloaddelay			= 40.0,

		maxlength			= 55,							-- Length of missile. Used for ammo properties.
		propweight			= 1.2,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 15,							-- Armour effectiveness of casing, in mm

		turnrate			= 40,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.6,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 30,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 15,							-- Acceleration in m/s.
		burntime			= 10,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 30,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.002,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.5,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		penmul			= math.sqrt(1.3)					-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)	--was 0.797
	},

	ent				= "acf_missile_to_rack",						-- A workaround ent which spawns an appropriate rack for the missile.
	guidance		= {"Dumb", "Laser", "Wire"},

	fuses			= {"Contact", "Optical"},
	viewcone		= 60,										-- getting outside this cone will break the lock.  Divided by 2.
	racks			= {											-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true,
					["1xRK_small"] = true,
					["2x AGM-114"] = true,
					["4x AGM-114"] = true
					},
	ghosttime		= 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay		= 0.00									-- minimum fuse arming delay
} )

ACF_defineGun("FGM-148 ASM", {
	name			= "FGM-148 Javelin Missile",
	desc			= "A powerful medium-range multi-purpose Missile, being extremely agile, its able to be used vs low altitude aircraft and for attacking top of tanks. But its somewhat slow.",
	model			= "models/mcace/Jevelinemissile.mdl",		-- model to spawn on menu
	effect			= "Rocket Motor ATGM",
	effectbooster	= "Rocket Motor Missile1",
	gunclass		= "ATGM",
	rack			= "1x Javelin",								-- Which rack to spawn this missile on?
	length			= 98,										-- Used for the physics calculations
	caliber			= 12.7,										-- caliber
	weight			= 11.8,										-- Don't scale down the weight though!  --was 97.2
	year			= 1989,										-- year
	modeldiameter	= 3 * 2.54,

	round = {
		model				= "models/mcace/Jevelinemissile.mdl",
		rackmdl				= "models/mcace/Jevelinemissile.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.0,
		reloaddelay			= 60.0,

		maxlength			= 110,							-- Length of missile. Used for ammo properties.
		propweight			= 1,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 13,							-- Armour effectiveness of casing, in mm

		turnrate			= 60,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.35,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 20,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 0,							-- Acceleration in m/s.
		burntime			= 25,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 13,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 55,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 5,							-- Time in seconds for booster runtime
		boostdelay			= 0.45,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.002,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.1,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		penmul			= math.sqrt(0.55)					-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)	--was 0.797
	},

	ent				= "acf_missile_to_rack",						-- A workaround ent which spawns an appropriate rack for the missile.
	guidance		= {"Dumb", "Infrared","Laser"},				-- here you have Laser for those top attacks, feel free to build one.

	fuses			= {"Contact", "Optical"},

	seekcone		= 2.5,										-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone		= 80,										-- getting outside this cone will break the lock.  Divided by 2.
	racks			= {											-- a whitelist for racks that this missile can load into.
					["1x Javelin"] = true
					},

	armdelay		= 1,										-- minimum fuse arming delay
	ghosttime		= 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds

} )

--define the class
ACF_defineGunClass("HMG", {
	spread = 0.4,
	name = "Heavy Machinegun",
	desc = ACFTranslation.GunClasses[7],
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.17,
	year = 1935,
	sound = "weapons/ACF_Gun/mg_fire3.wav",
	soundDistance = " ",
	soundNormal = " ",
	longbarrel = {
		index = 2, 
		submodel = 4, 
		newpos = "muzzle2"
	}
} )

--add a gun to the class
ACF_defineGun("20mmHMGShort", {
	name = "Shortened 20mm Heavy Machinegun",
	desc = "The lightest of the HMGs, the 20mm has a rapid fire rate but suffers from poor payload size.  Often used to strafe ground troops or annoy low-flying aircraft. Has a very low velocity",
	model = "models/machinegun/machinegun_20mm_compact.mdl",
	canparent = true,
	gunclass = "HMG",
	caliber = 2.0,
	weight = 80,
	year = 1935,
	rofmod = 2.5, --at 1.5, 675rpm; at 2.0, 480rpm
	round = {
		maxlength = 20,
		propweight = 0.04
	}
} )

ACF_defineGun("30mmHMGShort", {
	name = "Shortened 30mm Heavy Machinegun",
	desc = "30mm shell chucker, light and compact. Great for lobbing mid sized HE shells at infantry.",
	model = "models/machinegun/machinegun_30mm_compact.mdl",
	canparent = true,
	gunclass = "HMG",
	caliber = 3.0,
	weight = 140,
	year = 1941,
	rofmod = 1.5, --at 1.05, 495rpm; 
	round = {
		maxlength = 25,
		propweight = 0.08
	}
} )

ACF_defineGun("40mmHMGShort", {
	name = "Shortened 40mm Heavy Machinegun",
	desc = "The heaviest of the heavy machineguns.  Massively powerful with a killer reload and hefty ammunition requirements. Lobs low velocity shells at a high rate of fire.",
	model = "models/machinegun/machinegun_40mm_compact.mdl",
	gunclass = "HMG",
	canparent = true,
	caliber = 4.0,
	weight = 205,
	year = 1955,
	rofmod = 1.1, --at 0.75, 455rpm
	round = {
		maxlength = 32,
		propweight = 0.12
	}
} )
	
--add a gun to the class
ACF_defineGun("20mmHMG", {
	name = "20mm Heavy Machinegun",
	desc = "The lightest of the HMGs, the 20mm has a rapid fire rate but suffers from poor payload size.  Often used to strafe ground troops or annoy low-flying aircraft.",
	model = "models/machinegun/machinegun_20mm_compact.mdl",
	gunclass = "HMG",
	canparent = true,
	caliber = 2.0,
	weight = 150,
	year = 1935,
	rofmod = 1.9, --at 1.5, 675rpm; at 2.0, 480rpm
	magsize = 150,
	magreload = 8,
	round = {
		maxlength = 30,
		propweight = 0.12
	}
} )

ACF_defineGun("30mmHMG", {
	name = "30mm Heavy Machinegun",
	desc = "30mm shell chucker, light and compact. Your average cold war dogfight go-to.",
	model = "models/machinegun/machinegun_30mm_compact.mdl",
	gunclass = "HMG",
	canparent = true,
	caliber = 3.0,
	weight = 255,
	year = 1941,
	rofmod = 1.1, --at 1.05, 495rpm; 
	magsize = 120,
	magreload = 9,
	round = {
		maxlength = 37,
		propweight = 0.35
	}
} )

ACF_defineGun("40mmHMG", {
	name = "40mm Heavy Machinegun",
	desc = "The heaviest of the heavy machineguns.  Massively powerful with a killer reload and hefty ammunition requirements, it can pop even relatively heavy targets with ease.",
	model = "models/machinegun/machinegun_40mm_compact.mdl",
	gunclass = "HMG",
	canparent = true,
	caliber = 4.0,
	weight = 360,
	year = 1955,
	rofmod = 0.95, --at 0.75, 455rpm
	magsize = 100,
	magreload = 10,
	round = {
		maxlength = 42,
		propweight = 0.9
	}
} )

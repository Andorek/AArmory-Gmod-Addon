AARMORY.Localise.armory = {}
--== Armory Localisation ==--

-- General --
AARMORY.Localise.armory.policeArmory = "Police Armory" -- The text floating above the armory, and in the gui menu.
AARMORY.Localise.armory.notEnoughCops = "There are not enough police online!" -- Text that appears when there are not enough police online to rob the armory.

-- The two options below are apart of the same string, however there is another string between them which cannot be set by the player so they are split in two. The same can be said for any two options in a similar format as the one below.
AARMORY.Localise.armory.ammoTimeDelay1 = "You have to wait " -- When someone tries to get more ammo before the delay timer is up. -- (1)
AARMORY.Localise.armory.ammoTimeDelay2 = " seconds before getting more ammo." -- (2)

AARMORY.Localise.armory.dontOwnWeapon = "You don't own the weapon " -- When someone tries to get ammo without already owning the weapon it belongs to.

AARMORY.Localise.armory.alreadyHasWeapon = "You already have the weapon " -- When you try to take a weapon you already own.
AARMORY.Localise.armory.notRightGroup = "You aren't the right group to grab " -- When you don't belong to any of the groups set in the weapon config.
AARMORY.Localise.armory.notRightJob = "You aren't the right job to grab " -- When you don't belong to any of the jobs set in the weapon config.
AARMORY.Localise.armory.weaponTimer1 = "You have to wait " -- When you try to grab another weapon before the delay timer is up. -- (1)
AARMORY.Localise.armory.weaponTimer2 = " seconds before getting another weapon." -- (2)
AARMORY.Localise.armory.retrieve = "Retrieving " -- The text that shows when grabbing a weapon from the armory.

-- Admin Panel --
AARMORY.Localise.armory.adminPanel = "AArmory Admin Panel"
AARMORY.Localise.armory.adminWeaponPanel = "AArmory Weapons Panel"

AARMORY.Localise.armory.jobs = "Jobs"
AARMORY.Localise.armory.groups = "Groups"

AARMORY.Localise.armory.add = "Add"
AARMORY.Localise.armory.allowed = "Allowed"
AARMORY.Localise.armory.remove = "Remove"

AARMORY.Localise.armory.enabled = "Enabled"
AARMORY.Localise.armory.disabled = "Disabled"

AARMORY.Localise.armory.saved1 = "AArmory with ID "
AARMORY.Localise.armory.saved2 = "successfully saved! Armory is in "
AARMORY.Localise.armory.removed = " removed successfully."



-- Gui Mode --
AARMORY.Localise.armory.raidingTimer = "Raiding: " -- The text floating above the armory when raiding.
AARMORY.Localise.armory.cooldownTimer = "Cooldown: " -- The text floating above the armory when on cooldown.
AARMORY.Localise.armory.raiding = "The armory is being robbed!"
AARMORY.Localise.armory.cooldown = "The armory is on cooldown!"

AARMORY.Localise.armory.robberKilled = "The robbery was thwarted!"
AARMORY.Localise.armory.robberChangedJobs = "The robber changed jobs!"
AARMORY.Localise.armory.robberArrested = "The robber was arrested!"
AARMORY.Localise.armory.robberTooFarFromArmory = "The robber moved too far from the armory!"

AARMORY.Localise.armory.closeButton = "Close" -- The close text in the gui menu.
AARMORY.Localise.armory.equipButton = "Equip" -- The equip text in the gui menu.
AARMORY.Localise.armory.equipAmmoButton = "Equip Ammo" -- The equip ammo text in the gui menu.

-- Non-Gui Mode --
AARMORY.Localise.armory.restocking = "Restocking" -- The text on the armory after it is raided in non-gui mode.

AARMORY.Localise.armory.restock1 = "The weapon " 
AARMORY.Localise.armory.restock2 = " needs to restock after being stolen!"

AARMORY.Localise.armory.notRightJobNoGui = "You aren't the right job to use the armory!"


AARMORY.Localise.saw = {}
--== Armory Localisation ==--
AARMORY.Localise.saw.bigText = "SawOS" -- The big text on the saw.
AARMORY.Localise.saw.littleText = "For all your armory raiding needs..." -- The little text on the saw.

AARMORY.Localise.saw.idle = "Status: IDLE" -- The text on the progress bar of the saw when it is not turned on.
AARMORY.Localise.saw.running = "Status: RUNNING" -- The text on the progress bar of the saw when it is turned on.


--== Misc Localisation ==--

-- The below is what appears in the console when the server spawns armories on the map. The format should look like: "Spawned 'ENTITY' on map 'MAP' with position 'POSITION' and angle 'ANGLE'."
AARMORY.Localise.console1 = "Spawned AArmory "
AARMORY.Localise.console2 = " on map "
AARMORY.Localise.console3 = " with position "
AARMORY.Localise.console4 = " and angle "
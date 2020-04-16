
--== CONFIG ==--
AARMORY.Settings.robTime = 10 -- Rob time in seconds
AARMORY.Settings.robbers = { -- Put the job command here
    ["thief"] = true,
    ["prothief"] = true,
}

AARMORY.Settings.useCustomSoundfile = false -- If you want to replace the alarm with your own sound file.
AARMORY.Settings.customSoundfile = "ambient/alarms/alarm1.wav"
AARMORY.Settings.alarmChance = 50 -- The chance (%) that the alarm will play when a saw is attached (only for non-gui mode).

AARMORY.Settings.copAmount = 0 -- Put 0 to disable
AARMORY.Settings.weaponDelay = 5 -- A delay so cops don't spam weapons

AARMORY.Settings.openTime = 20 -- How long the armory stays open for after being raided.
AARMORY.Settings.cooldownTime = 20 -- How long it takes for the armory to restock/cooldown.

AARMORY.Settings.ammoInteractTimes = 3 -- Amount of times ammo can be collected before there is no ammo left (Prevents ammo spam).
AARMORY.Settings.ammoTimer = 5 -- Time before the ammoInteractTimes resets back to what you set it.

AARMORY.Settings.guiMode = true -- A simpler and alot less laggy version of the addon that allows an unlimited amount of weapons (automatically on if the weapons count is more than four).
AARMORY.Settings.rewardMoney = 5000 -- Only if guiMode is true currently.
AARMORY.Settings.distance = 600 -- How far the robber has to be from the armory before the robbery is canceled.

-- Global weapon positioning
AARMORY.Settings.weaponPitch = 0
AARMORY.Settings.weaponYaw = 0
AARMORY.Settings.weaponRoll = 0

AARMORY.Settings.weaponX = 0
AARMORY.Settings.weaponY = 0
AARMORY.Settings.weaponZ = 0

--== Weapons ==--
-- If you want the armory to spawn shipments when raided the weapon needs to be a shipment in shipments.lua.

AARMORY.weaponTable["cw_ak74"] = { -- Must be the actual weapon name (right click on the icon in-game and click 'Copy to clipboard' and paste here).
    printName = "AK-74", -- The name that will appear on the armory.
    model = "models/weapons/w_rif_ak47.mdl", -- The model that will appear in the armory.
    ammo = "5.45x39MM", -- Eg "SMG1"
    ammoAmount = 30, -- Amount of ammo to give (defaults to 30).
    amount = 15, -- The amount of weapons in the shipment after the armory is robbed (default 10 if no amount).

    restrictGroup = { -- Restricts the weapon to a particular groups.
        --["donator"] = true,
        --["owner"] = true,
    },

    restrictJob = { -- Restricts the weapon to a particular job. NOTE: Use the job command. This can be left empty if wanted because the addon already checks if the player is a cop.
        --["police"] = true,
        --["swatsupport"] = true,
    },

    -- Use the below options to position your weapon if its not positioned correctly already.
    -- NOTE: When changing angles it may seem like the weapon has disappeared but it just rotates around a large axis, so you'll have to reposition it back. Change the angles very gradually (increment by 1) to negate this.
    pitch = 0,
    yaw = 0,
    roll = 0,

    posX = 2,
    posY = 0,
    posZ = 0,
}

AARMORY.weaponTable["cw_mp5"] = { -- Weapon that contains the minimum amount of fields to work.
    printName = "MP5",
    model = "models/weapons/w_hk_mp5.mdl",
    ammo = "9x39MM",
}

AARMORY.weaponTable["cw_ar15"] = {
    printName = "AR-15",
    model = "models/weapons/w_rif_m4a1.mdl",
    ammo = "5.56x45MM",
    ammoAmount = 30,

    pitch = 0,
    yaw = 0,
    roll = 3,

    posX = -2,
    posY = 0,
    posZ = 0,
}

AARMORY.weaponTable["cw_g3a3"] = {
    printName = "G3A3",
    model = "models/weapons/w_hk_g3.mdl",
    ammo = "7.62x51MM",
    ammoAmount = 30,
}

--[[ Uncommenting this automatically puts the addon in gui mode as it exceeds 4 weapons.

AARMORY.weaponTable["cw_scarh"] = { 
    printName = "FN SCAR-H",
    model = "models/weapons/w_fn_scar_h.mdl",
    ammo = "5.56x45MM",
}

]]--
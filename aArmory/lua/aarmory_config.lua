
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


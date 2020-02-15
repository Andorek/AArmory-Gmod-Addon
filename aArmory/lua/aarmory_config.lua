AARMORY = AARMORY or {}

AARMORY.Settings = {}
AARMORY.weaponTable = {}

--- CONFIG ---

AARMORY.Settings.useCustomSoundfile = false
AARMORY.Settings.customSoundfile =  "ambient/alarms/apc_alarm_pass1.wav" -- Just a placeholder, put whatever you want here.

AARMORY.Settings.robbers = {"thief", "prothief"} -- Put the command for the job in here
AARMORY.Settings.robTimer = 10
AARMORY.Settings.robCooldown = 10 
AARMORY.Settings.cancelRobDistance = 900 -- How far away the player has to be to cancel robbing the armory.

AARMORY.Settings.weaponTimer = 20 -- How long it takes for the cp to be able to grab another gun
AARMORY.Settings.copAmount = 0 -- Amount of cops that need to be on before the armory can get robbed.

AARMORY.Settings.rewardMoney = 5000

-- Weapons --

AARMORY.weaponTable["cw_ak74"] = { -- Must be the actual weapon name (right click on the icon in-game and click 'Copy to clipboard' and paste here).
    printName = "AK-74", -- The name that will appear in the armory menu.
    model = "models/weapons/w_rif_ak47.mdl", -- The model that will appear in the armory menu.
    amount = 15 -- The amount of weapons in the shipment (default 10 if no amount)
}

AARMORY.weaponTable["cw_ar15"] = {
    printName = "AR-15",
    model = "models/weapons/w_rif_m4a1.mdl",
}


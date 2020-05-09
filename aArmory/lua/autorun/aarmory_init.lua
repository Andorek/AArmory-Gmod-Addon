AARMORY = {} or AARMORY
AARMORY.Settings = {}
AARMORY.Localise = {}
AARMORY.Config = {}

AddCSLuaFile("aarmory_config.lua")
AddCSLuaFile("aarmory_localisation.lua")
include("aarmory_config.lua")
include("aarmory_localisation.lua")

local function makeConfig()
    if !file.Exists("aarmory/config.txt", "DATA") then
        local configTable = {}
        configTable["Default"] = {
            aarmoryConfig = {
                robTime = {
                    pName = "Rob Time",
                    des = "The time it takes to saw through or rob the armory.",
                    var = 30,
                },
                robbers = {
                    pName = "Robbers",
                    des = "Which jobs can rob the armory.",
                    type = "jobs",
                    table = {
                    },
                },
                staff = {
                    pName = "Staff",
                    des = "The groups that can access the admin config.",
                    type = "staff",
                    table = {
                    },
                },
                alarmChance = {
                    pName = "Alarm Chance",
                    des = "The % chance that the alarm will go off when the saw is placed on the armory.",
                    var = 50,
                },
                copAmount = {
                    pName = "Cop Amount",
                    des = "The amount of cops that need to be online to start robbing the armory (disabled if 0).",
                    var = 0,
                },
                weaponDelay = {
                    pName = "Weapon Delay",
                    des = "The delay between retrieving weapons for cops.",
                    var = 5,
                },
                openTime = {
                    pName = "Open Time",
                    des = "The time before the armory closes after being sawed through.",
                    var = 30,
                },
                cooldownTime = {
                    pName = "Cooldown",
                    des = "The time after robbing before the armory can be used or robbed again.",
                    var = 30,
                },
                ammoInteractTimes = {
                    pName = "Ammo Limit",
                    des = "The amount of times a cop can take ammo before the delay timer starts.",
                    var = 3,
                },
                ammoTimer = {
                    pName = "Ammo Timer",
                    des = "The delay between retrieving ammo for cops.",
                    var = 5,
                },
                guiMode = {
                    pName = "GUI Mode",
                    des = "Whether the armory has a gui or uses stencils.",
                    var = false,
                },
                rewardMoney = {
                    pName = "Reward Money",
                    des = "The money rewarded to a robber after successfully robbing the armory.",
                    var = 5000,
                },
                distance = {
                    pName = "Distance",
                    des = "The distance the robber has to be from the armory before the robbery gets cancelled.",
                    var = 600,
                },
            },
            weapons = {},
            pos = Vector(0, 0, 0),
            ang = Angle(0, 0, 0),
            map = game.GetMap(),
        }
        for k, v in pairs(RPExtraTeams) do
            configTable["Default"].aarmoryConfig.robbers.table[v.command] = false
        end
        for k, v in pairs(CustomShipments) do
            configTable["Default"].weapons[v.entity] = v
            configTable["Default"].weapons[v.entity].ammoAmount = 30
            configTable["Default"].weapons[v.entity].shipmentAmount = 10
            configTable["Default"].weapons[v.entity].useWeapon = false
            configTable["Default"].weapons[v.entity].restrictJob = {}
            configTable["Default"].weapons[v.entity].restrictGroup = {}
            for a, b in pairs(RPExtraTeams) do
                configTable["Default"].weapons[v.entity].restrictJob[b.command] = false
            end
            for a, b in pairs(weapons.GetList()) do
                if v.entity == b.ClassName then
                    configTable["Default"].weapons[v.entity].ammo = b.Primary.Ammo
                end
            end
        end

        local jsonTab = util.TableToJSON(configTable, true)
        file.Write("aarmory/config.txt", jsonTab)
    end
end
hook.Add("Initialize", "configMaker", makeConfig)

local function aarmorySpawn()

    local configTable = util.JSONToTable( file.Read( "aarmory/config.txt", "DATA" ) )
    
    for k, v in pairs( configTable ) do
        if v.map == game.GetMap() and k != "Default" and !table.IsEmpty(configTable[k]) then
            local entity = ents.Create( "aarmory_ent" )

            local entPos = v.pos
            local entAng = v.ang

            entity.config = v

            entity:SetaarmoryID(k)
            entity:SetPos( entPos )
            entity:SetAngles( entAng )
            entity:Spawn()

            print(AARMORY.Localise.console1 .. k .. AARMORY.Localise.console2 .. tostring(v.map) .. AARMORY.Localise.console3 .. tostring(math.Round(entPos.x)) .. ", " .. tostring(math.Round(entPos.y)) .. ", " .. tostring(math.Round(entPos.x)) .. AARMORY.Localise.console4 .. tostring(math.Round(entAng.x)) .. ", " .. tostring(math.Round(entAng.y)) .. ", " .. tostring(math.Round(entAng.x)) .. ".")
        end
    end

end
hook.Add( "InitPostEntity", "aarmorySpawn", aarmorySpawn )
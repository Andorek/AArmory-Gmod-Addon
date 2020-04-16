AARMORY = {} or AARMORY
AARMORY.Settings = {}
AARMORY.Localise = {}
AARMORY.weaponTable = {}

AddCSLuaFile("aarmory_config.lua")
AddCSLuaFile("aarmory_localisation.lua")
include("aarmory_config.lua")
include("aarmory_localisation.lua")

local function aarmorySpawn()

    if file.Exists( "aarmory/aarmory.txt", "DATA" ) then
        aarmoryPosTable = util.JSONToTable( file.Read( "aarmory/aarmory.txt", "DATA" ) )
        
        for k, v in pairs( aarmoryPosTable, true ) do
            if v.map == game.GetMap() then
                local entity = ents.Create( "aarmory_ent" )

                local entPos = v.pos
                local entAng = v.ang
            
                entity:SetPos( entPos )
                entity:SetAngles( entAng )
                entity:Spawn()

                print(AARMORY.Localise.console1 .. k .. AARMORY.Localise.console2 .. tostring(v.map) .. AARMORY.Localise.console3 .. tostring(math.Round(entPos.x)) .. ", " .. tostring(math.Round(entPos.y)) .. ", " .. tostring(math.Round(entPos.x)) .. AARMORY.Localise.console4 .. tostring(math.Round(entAng.x)) .. ", " .. tostring(math.Round(entAng.y)) .. ", " .. tostring(math.Round(entAng.x)) .. ".")

            end
        end

    end
end
hook.Add( "InitPostEntity", "aarmorySpawn", aarmorySpawn )
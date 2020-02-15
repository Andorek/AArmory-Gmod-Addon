AddCSLuaFile("aarmory_config.lua")
include("aarmory_config.lua")

local function aarmorySpawn()

    if file.Exists( "aarmory/aarmory.txt", "DATA" ) then
        aarmoryPosTable = util.JSONToTable( file.Read( "aarmory/aarmory.txt", "DATA" ) )
        
        for k, v in SortedPairs( aarmoryPosTable, true ) do
            if v.map == game.GetMap() then
                local entity = ents.Create( "aarmory" )

                local entPos = v.pos
                local entAng = v.ang
                
                entity:SetPos( entPos )
                entity:SetAngles( entAng )
                entity:Spawn()
            end
        end
    end
end
hook.Add( "InitPostEntity", "aarmorySpawn", aarmorySpawn )


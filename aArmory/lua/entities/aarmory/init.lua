AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

util.AddNetworkString( "useEnt" )
util.AddNetworkString( "giveWeapon" )

function ENT:Initialize()
    self:SetModel( "models/props_c17/lockers001a.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:EnableMotion( false ) end

end

local function saveEnt( ply, text, team )
    local posTable = {}

    if ply:IsSuperAdmin() then
        if text == "/aarmorysave" or text == "!aarmorysave" then
            
            local count = 0
            for k, v in pairs( ents.FindByClass( "aarmory" ) ) do
                posTable[ tostring( v ) ] = {
                    pos = v:GetPos(),
                    ang = v:GetAngles(),
                    map = game.GetMap(),
                }
            end

            local jsonTab = util.TableToJSON( posTable )

            if !file.IsDir( "aarmory", "DATA" ) then
                file.CreateDir( "aarmory" )
                file.Write( "aarmory/aarmory.txt", jsonTab )
            else
                file.Write( "aarmory/aarmory.txt", jsonTab )
            end

        elseif text == "/aarmoryremove" or text == "!aarmoryremove" then
            if file.Exists( "aarmory/aarmory.txt", "DATA" ) then
                file.Delete( "aarmory/aarmory.txt", "DATA" )
            elseif file.IsDir( "aarmory", "DATA" ) then
                file.Delete( "aarmory" )
            end
        end
    end
end
hook.Add( "PlayerSay", "entitySaver", saveEnt )

-- Taken from a ULX chat spawnshipment addon and adjusted
local function aarmorySpawnShipment( ply, name, amount, entity, spawnPos )
    local found, foundKey = DarkRP.getShipmentByName( name ) -- The weapon must be in shipments.lua
        if isnumber( foundKey ) then
            local crate = ents.Create( found.shipmentClass or "spawned_shipment" )
            crate.SID = ply.SID
            crate:Setowning_ent( ply )
            crate:SetContents( foundKey, amount or 10 )

            crate:SetPos( spawnPos )
            crate.nodupe = true
            crate.ammoadd = found.spareammo
            crate.clip1 = found.clip1
            crate.clip2 = found.clip2
            crate:Spawn()
            crate:SetPlayer( ply )

        local phys = crate:GetPhysicsObject()
        phys:Wake()
            if found.weight then
                phys:SetMass( found.weight )
            end
        end
end

local usePly
function ENT:Use( ply )
    usePly = ply

    local cpCount = 0
    for k, v in pairs( player.GetAll() ) do
        if v:isCP() then
            cpCount = cpCount + 1
        end
    end
    
    local plyJob = ply:getJobTable().command
    if ply:isCP() then
        net.Start( "useEnt" )
            net.WriteString(plyJob)
            net.WriteEntity(self)
        net.Send( ply )
    else
        for k, v in pairs( AARMORY.Settings.robbers ) do
            if v == plyJob then
                if cpCount < AARMORY.Settings.copAmount and AARMORY.Settings.copAmount != 0 then -- Checks cop amount
                    DarkRP.notify( ply, 0, 5, "There are not enough police online!" )
                    return
                elseif timer.Exists( self:EntIndex() .. "aarmoryDelay" ) and timer.TimeLeft( self:EntIndex() .. "aarmoryDelay" ) != nil then -- Checks if armory is on cooldown
                    DarkRP.notify( ply, 0, 5, "The armory is on cooldown!" )
                    return
                elseif timer.Exists( self:EntIndex() .. "aarmoryRobbing" ) and timer.TimeLeft( self:EntIndex() .. "aarmoryRobbing" ) != nil then -- Checks if the armory is already being robbed
                    DarkRP.notify( ply, 0, 5, "The armory is already being robbed!" )
                    return
                end

                if !timer.Exists( self:EntIndex() .. "aarmoryRobbing" ) then
                    self:SetIsRobbing(true)
                    timer.Create( self:EntIndex() .. "aarmoryRobbing", AARMORY.Settings.robTimer, 1, function()
    
                        ply:addMoney( AARMORY.Settings.rewardMoney )
                        self:SetIsRobbing(false)
    
                        for k, v in SortedPairsByMemberValue(AARMORY.weaponTable, "printName", true) do
                            aarmorySpawnShipment( ply, v.printName, v.amount, k, self:GetPos() + self:GetForward() * 50 )
    
                            if !timer.Exists( self:EntIndex() .. "aarmoryDelay" ) then
                                timer.Create( self:EntIndex() .. "aarmoryDelay", AARMORY.Settings.robCooldown, 1, function() end )
                            else
                                timer.Start( self:EntIndex() .. "aarmoryDelay" )
                            end
                        end
    
                    end )
    
                elseif timer.Exists( self:EntIndex() .. "aarmoryRobbing" ) then -- I don't need to check if the timer is running or not here as that's done at the top of this function.
                    if !self:GetIsRobbing() then self:SetIsRobbing(true) end
                    timer.Start( self:EntIndex() .. "aarmoryRobbing" )
                end
                
            end
        end
    end
    
end

function ENT:Think()
    if timer.Exists( self:EntIndex() .. "aarmoryRobbing" ) and timer.TimeLeft( self:EntIndex() .. "aarmoryRobbing" ) != nil then
        local dist = AARMORY.Settings.cancelRobDistance
        
        if usePly:GetPos():DistToSqr( self:GetPos() ) > ( dist * dist ) or !usePly:Alive() then -- Checks player distance from armory and cancels robber if it is too far
            self:SetIsRobbing(false)
            
            timer.Stop(self:EntIndex() .. "aarmoryRobbing")

            if !timer.Exists( self:EntIndex() .. "aarmoryDelay" ) then -- Starts the cooldown if the robbery is aborted in this way.
                timer.Create( self:EntIndex() .. "aarmoryDelay", AARMORY.Settings.robCooldown, 1, function() end )
            else
                timer.Start( self:EntIndex() .. "aarmoryDelay" )
            end

            if !usePly:Alive() then 
                DarkRP.notify( usePly, 0, 5, "You failed the robbery!" )
            else 
                DarkRP.notify( usePly, 0, 5, "You went too far from the armory!" )
            end
        end
    end

end

function ENT:OnRemove()
    if timer.Exists( self:EntIndex() .. "aarmoryRobbing" ) then
        timer.Remove( self:EntIndex() .. "aarmoryRobbing" )
    end

    if timer.Exists( self:EntIndex() .. "aarmoryDelay" ) then
        timer.Remove( self:EntIndex() .. "aarmoryDelay" )
    end

    if self:GetIsRobbing() then self:SetIsRobbing(false) end
end

net.Receive("giveWeapon", function( len, ply )
    local weapon = net.ReadString()
    local weaponPrintName = net.ReadString()
    local canGetWeapon = true

    if !timer.Exists( "weaponTimer" .. ply:SteamID() ) then -- A cooldown so cops don't spam themselves weapons.
        timer.Create( "weaponTimer" .. ply:SteamID(), AARMORY.Settings.weaponTimer, 1, function()
            canGetWeapon = true
        end )
    elseif timer.Exists( "weaponTimer" .. ply:SteamID() ) then
        canGetWeapon = nil
        if timer.TimeLeft( "weaponTimer" .. ply:SteamID() ) == nil then
            timer.Start( "weaponTimer" .. ply:SteamID() )
        end
    end

    local nToggle = nil
    local nTest -- Can't be canGetWeapon as that interferes with what the timers set.
    for k, v in pairs(AARMORY.weaponTable) do -- Protection from people networking different guns from what are supposed to be given.
        if weapon != k and !nToggle then
            nTest = nil
        else
            nTest = true 
            nToggle = true
        end
    end

    if !nTest then
        print(ply:Nick() .. " tried to spawn an illegal weapon.")
        return
    elseif ply:HasWeapon( weapon ) then
        DarkRP.notify( ply, 0, 5, "You already have the weapon " .. weaponPrintName .. "." )
        return
    elseif !canGetWeapon or !ply:isCP() then
        if timer.TimeLeft("weaponTimer" .. ply:SteamID()) != nil then -- Has to be here otherwise timer keeps restarting itself.
            DarkRP.notify( ply, 0, 5, "You have to wait " .. math.Round(timer.TimeLeft("weaponTimer" .. ply:SteamID())) .. " seconds before getting another weapon.")
        else
            DarkRP.notify( ply, 0, 5, "You cannot equip " .. weaponPrintName .. ".")
        end
        return
    else
        ply:Give( weapon )
    end
    

end)

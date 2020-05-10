AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

util.AddNetworkString("aarmoryUse")
util.AddNetworkString("aarmoryGive")
util.AddNetworkString("sendConfig")
util.AddNetworkString("aarmoryClientConfig")

local function networkConfig(ent, ply) -- Only sends the stuff needed clientside, not the whole config.
    net.Start("aarmoryClientConfig")
        net.WriteUInt(ent:GetaarmoryID(), 12)
        net.WriteUInt(table.Count(ent.configTable.weapons), 12)
        for k, v in SortedPairs(ent.configTable.weapons) do
            net.WriteString(k)
            net.WriteString(v.name)
            net.WriteString(v.model)
            net.WriteBool(v.useWeapon)
            net.WriteVector(v.stencilPos)
            net.WriteAngle(v.stencilAng)
        end
    net.Send(ply)
end

--[[
local function debugNetwork(ply, text)
    if text == "!aarmory" or text == "/aarmory" then
        for k, v in pairs(player.GetAll()) do
            for a, b in pairs(ents.FindByClass("aarmory_ent")) do
                networkConfig(b, v)
            end
        end
    end
end
hook.Add("PlayerSay", "debug", debugNetwork)
]]--

function ENT:Initialize()
    self:SetModel( "models/props_c17/lockers001a.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )

    local config = util.JSONToTable(file.Read("aarmory/config.txt", "DATA"))
    for k, v in pairs(config) do
        AARMORY.Config[k] = v
    end

    self.configTable = config["Default"]
    if AARMORY.Config[self:GetaarmoryID()] != nil then
        self.configTable = AARMORY.Config[self:GetaarmoryID()]
    end

    for k, v in pairs(player.GetAll()) do
        v.ammoLimit = {}
        networkConfig(self, v)
    end

    local isGui = self.configTable.aarmoryConfig.guiMode.var
    local tCount = 0
    for k, v in pairs(self.configTable.weapons) do
        if v.useWeapon then
            tCount = tCount + 1
        end
    end
    if isGui or tCount > 4 then
        self:SetisGui(true)
    else
        self:SetisGui(false)
    end

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:EnableMotion( false ) end -- Keeps it still/frozen until interacted with.

end

net.Receive("sendConfig", function(len, ply)
        if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
        local netTable = net.ReadTable()
        local remove = net.ReadBool()
        local ent = net.ReadEntity()
        local configTable = AARMORY.Config -- Had to do this so I could get rid of table.add, which was turning the keys into numbers.
        local id = 1
        for k, v in pairs(AARMORY.Config) do
            if k == ent:GetaarmoryID() then
                id = k
                break
            elseif k == id then
                id = id + 1
            end
        end
        if AARMORY.Config[id] != nil then
            for k, v in pairs(AARMORY.Config[id].aarmoryConfig.staff.table) do
                if ply:GetUserGroup() != k and !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
            end
        end
        configTable[id] = netTable

        if !remove then
            configTable[id].pos = ent:GetPos()
            configTable[id].ang = ent:GetAngles()
            configTable[id].map = game.GetMap()

            local jsonTab = util.TableToJSON(configTable, true)
            file.Write("aarmory/config.txt", jsonTab)
            AARMORY.Config[id] = configTable[id]

            local entity = ents.Create("aarmory_ent")
            
            entity:SetPos( ent:GetPos() )
            entity:SetAngles( ent:GetAngles() )
            ent:Remove()
            entity:SetaarmoryID(id)
            entity:Spawn()
            local text = "stencil mode."
            if entity:GetisGui() then text = "GUI mode." end
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.saved1 .. id .. AARMORY.Localise.armory.saved2 .. text)
        else
            if ent:GetaarmoryID() == 0 then return end
            for k, v in pairs(configTable) do
                if k == id then
                    table.Empty(v)
                    table.Empty(AARMORY.Config[k])
                    DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.saved1 .. k .. AARMORY.Localise.armory.removed)
                end
            end
            local jsonTab = util.TableToJSON(configTable, true)
            file.Write("aarmory/config.txt", jsonTab)
        end

end)

local function plyFullyLoaded(ply)
    for k, v in pairs(ents.FindByClass("aarmory_ent")) do
        networkConfig(v, ply)
    end
end
hook.Add("PlayerFullLoad", "plyLoaded", plyFullyLoaded)

local function plyConnect(ply)
    ply.ammoLimit = {}
    hook.Add("SetupMove",ply,function(self,ply,_,cmd) -- Taken from the gmod wiki
        if self == ply and not cmd:IsForced() then 
            hook.Run("PlayerFullLoad",self)
            hook.Remove("SetupMove",self) 
        end
    end)
end
hook.Add("PlayerInitialSpawn", "ammoTableMaker", plyConnect)


local function ammoTimeLimit(ply, weapon, id)
    if ply.ammoLimit[weapon] >= 0 then
        ply.ammoLimit[weapon] = ply.ammoLimit[weapon] - 1
        if !timer.Exists("ammoLimitTimer" .. weapon .. ply:SteamID()) then
            timer.Create("ammoLimitTimer" .. weapon .. ply:SteamID(), AARMORY.Config[id].aarmoryConfig.ammoTimer.var, 1, function()
                ply.ammoLimit[weapon] = AARMORY.Config[id].aarmoryConfig.ammoInteractTimes.var
            end)
        elseif timer.TimeLeft("ammoLimitTimer" .. weapon .. ply:SteamID()) == nil then
            timer.Start("ammoLimitTimer" .. weapon .. ply:SteamID())
        end
    end
end

-- Taken from a ULX spawnshipment addon and adjusted
local function aarmorySpawnShipment( ply, id, entity, spawnPos )
    local found, foundKey = DarkRP.getShipmentByName( AARMORY.Config[id].weapons[entity].name ) -- The weapon must be in shipments.lua
        if isnumber( foundKey ) then
            local crate = ents.Create( found.shipmentClass or "spawned_shipment" )
            crate.SID = ply.SID
            crate:Setowning_ent( ply )
            crate:SetContents( foundKey, AARMORY.Config[id].weapons[entity].name )

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

local curDoorEnt = {} -- Has to be defined outside the function otherwise it would keep resetting to nil.
function ENT:openArmory(isRobbing, sawPos, ply, weapon) -- A mess of timers, but it all works.
    
    local aarmoryDoorEnt = ents.Create("prop_physics")
    aarmoryDoorEnt:SetModel("models/props_lab/lockerdoorleft.mdl")

    if !isRobbing then
        if !timer.Exists("openTimer" .. weapon) then
            aarmoryDoorEnt:SetPos(sawPos or self:GetPos() + self:GetAngles():Forward() * 10)
            aarmoryDoorEnt:Spawn()
            curDoorEnt[weapon] = {
                ent = aarmoryDoorEnt
            }
            timer.Create("openTimer" .. weapon, self.configTable.aarmoryConfig.openTime.var, 1, function()
                self:SetNWBool("open" .. weapon .. tostring(self), false)
                if self:GetalarmChance() then
                    self:SetalarmChance(false)
                end
                if IsValid(aarmoryDoorEnt) then
                    aarmoryDoorEnt:Remove()
                end
            end)
        elseif timer.TimeLeft("openTimer" .. weapon) == nil then
            aarmoryDoorEnt:SetPos(sawPos or self:GetPos() + self:GetAngles():Forward() * 10)
            aarmoryDoorEnt:Spawn()
            timer.Start("openTimer" .. weapon)
        end
    else
        aarmorySpawnShipment( ply, self:GetaarmoryID(), weapon, self:GetPos() + self:GetAngles():Forward() * 10 )
        if IsValid(curDoorEnt[weapon].ent) then
            curDoorEnt[weapon].ent:Remove()
        end
        self:SetNWBool("open" .. weapon .. tostring(self), false)
        if !timer.Exists("cooldown" .. weapon) then
            if self:GetalarmChance() then
                self:SetalarmChance(false)
            end
            self:SetNWBool("cooldown" .. weapon .. tostring(self), true)
            timer.Create("cooldown" .. weapon, self.configTable.aarmoryConfig.cooldownTime.var, 1, function()
                self:SetNWBool("cooldown" .. weapon .. tostring(self), false)
            end)
        elseif timer.TimeLeft("cooldown" .. weapon) == nil then
            self:SetNWBool("cooldown" .. weapon .. tostring(self), true)
            timer.Start("cooldown" .. weapon)
        end
    end
end

function ENT:Touch(ent)
    local cpCount = 0
    for k, v in pairs(player.GetAll()) do
        if v:isCP() then
            cpCount = cpCount + 1
        end
    end
    if self:GetisGui() then
        return
    elseif cpCount < self.configTable.aarmoryConfig.copAmount.var and self.configTable.aarmoryConfig.copAmount.var != 0 then
        return
    end

    if ent:GetClass() == "aarmorysaw_ent" then

        local ang = self:GetAngles()
        local pos = self:GetPos()
        local sawAng = ent:GetAngles()
        local sawPos = self:WorldToLocal(ent:GetPos() + (ang:Right() * -28) + ( ang:Up() * 8.6 ) + ( ang:Forward() * -24 )) -- Saw position relative to the aarmory position. Also, the angles are here for the proper 3d2d position when the ent is rotated.
        local y, x = sawPos.x / 0.02, sawPos.y / 0.02 -- Note: For some reason x is y and y is x? Switched so it makes sense in later code.

        local count = 1
        local sOffset = 0
        local offset = 0
        for k, v in SortedPairs(self.configTable.weapons) do
            if v.useWeapon then
                if x > 0 + offset and x < 605 + offset then
                    if self:GetNWBool("open" .. k .. tostring(self)) or self:GetNWBool("cooldown" .. k .. tostring(self)) then return end
                    for a, b in pairs(self:GetChildren()) do
                        if b:GetParentAttachment() == count then return end -- The saw's attachment id does not turn back to 0 after removing it from the armory.
                    end
                    ent:SetParent(self, count)
                    ent:SetPos( Vector(6.5,-10 + sOffset,-2))
                    ent:SetAngles(ang + Angle(175, 60, 100))
                    if math.Rand(0, 100) < self.configTable.aarmoryConfig.alarmChance.var and !self:GetalarmChance() then
                        self:SetalarmChance(true)
                    end
                end
                count = count + 1
                sOffset = sOffset + 12.5
                offset = offset + 605
            end
        end
    end
end

local function WorldToScreen(vWorldPos,vPos,vScale,aRot) -- From the maurits.tv archived gmod wiki (cam.Start3D2D)
    local vWorldPos=vWorldPos-vPos;
    vWorldPos:Rotate(Angle(0,-aRot.y,0));
    vWorldPos:Rotate(Angle(-aRot.p,0,0));
    vWorldPos:Rotate(Angle(0,0,-aRot.r));
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale;
end

local function aarmoryGiveWeapon(weapon, name, giveAmmo, ammoType, ammoAmount, maxAmmoLimit, ply, restrictJobTable, restrictGroupTable, id)
    local canGetWeapon = true
    if giveAmmo then
        if ply:HasWeapon(weapon) and maxAmmoLimit > 0 then
            ammoTimeLimit(ply, weapon, id)
            ply:GiveAmmo(ammoAmount or 30, ammoType)
        elseif maxAmmoLimit <= 0 then
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.ammoTimeDelay1 .. AARMORY.Localise.armory.ammoTimeDelay2)
        else
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.dontOwnWeapon .. name .. ".")
        end
    end

    if ply:isCP() and !giveAmmo then
        if !timer.Exists( "weaponTimer" .. ply:SteamID() ) then -- A cooldown so cops don't spam themselves weapons.
            timer.Create( "weaponTimer" .. ply:SteamID(), AARMORY.Config[id].aarmoryConfig.weaponDelay.var, 1, function()
                canGetWeapon = true
            end )
        elseif timer.Exists( "weaponTimer" .. ply:SteamID() ) then
            if timer.TimeLeft( "weaponTimer" .. ply:SteamID() ) == nil then
                timer.Start( "weaponTimer" .. ply:SteamID() )
            else
                canGetWeapon = nil
            end
        end
        if ply:HasWeapon(weapon) then
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.alreadyHasWeapon .. name .. ".")
            return
        elseif !restrictGroupTable then
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.notRightGroup .. name .. "!")
            return
        elseif !restrictJobTable then
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.notRightJob .. name .. "!")
            return
        elseif !canGetWeapon then
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.weaponTimer1 .. tostring(math.Round(timer.TimeLeft("weaponTimer" .. ply:SteamID()))) .. AARMORY.Localise.armory.weaponTimer2)
            return
        else
            ply:Give(weapon)
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.retrieve .. name .. ".")
        end
    end

end


local robber
function ENT:startAArmoryRobbery(ply) -- This function is for the gui version of the addon.
    robber = ply

    local cpCount = 0
    for k, v in pairs(player.GetAll()) do
        if v:isCP() then
            cpCount = cpCount + 1
        end
    end

    if cpCount < self.configTable.aarmoryConfig.copAmount.var and self.configTable.aarmoryConfig.copAmount.var != 0 then
        DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.notEnoughCops )
        return
    elseif timer.TimeLeft("aarmoryCooldown" .. self:EntIndex()) != nil then
        DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.cooldown )
        return
    elseif timer.TimeLeft("aarmoryRobbing" .. self:EntIndex()) != nil then
        DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.raiding )
        return
    end

    if !timer.Exists("aarmoryRobbing" .. self:EntIndex()) then
        timer.Create("aarmoryRobbing" .. self:EntIndex(), self.configTable.aarmoryConfig.robTime.var, 1, function()

            ply:addMoney(self.configTable.aarmoryConfig.rewardMoney.var)

            local offset = 0
            for k, v in pairs(self.configTable.weapons) do
                if v.useWeapon then
                    aarmorySpawnShipment( ply, v.name, v.amount or 10, k, self:GetPos() + self:GetAngles():Right() * (-40 + offset) + self:GetAngles():Forward() * 20 )
                    offset = offset + 40
                end
            end

            if !timer.Exists("aarmoryCooldown" .. self:EntIndex()) then
                timer.Create("aarmoryCooldown" .. self:EntIndex(), self.configTable.aarmoryConfig.cooldownTime.var, 1, function() end)
            else
                timer.Start("aarmoryCooldown" .. self:EntIndex())
            end
        end)
    else
        timer.Start("aarmoryRobbing" .. self:EntIndex())
    end
end

function ENT:Think()
    if self:GetisGui() then
        if timer.TimeLeft("aarmoryRobbing" .. self:EntIndex()) != nil then
            self:SetrobTimer(timer.TimeLeft("aarmoryRobbing" .. self:EntIndex()))
        end
        if timer.TimeLeft("aarmoryCooldown" .. self:EntIndex()) then
            self:SetcooldownTimer(timer.TimeLeft("aarmoryCooldown" .. self:EntIndex()))
        end
        if IsValid(robber) and timer.TimeLeft("aarmoryRobbing" .. self:EntIndex()) != nil then
            if !robber:Alive() then
                for k, v in pairs(player.GetAll()) do
                    DarkRP.notify( v, 0, 5, AARMORY.Localise.armory.robberKilled )
                end
                self:SetrobTimer(0)
                timer.Remove("aarmoryRobbing" .. self:EntIndex())
                if !timer.Exists("aarmoryCooldown" .. self:EntIndex()) then
                    timer.Create("aarmoryCooldown" .. self:EntIndex(), self.configTable.aarmoryConfig.cooldownTime.var, 1, function() end)
                else
                    timer.Start("aarmoryCooldown" .. self:EntIndex())
                end
            elseif !self.configTable.aarmoryConfig.robbers.table[robber:getJobTable().command] then
                for k, v in pairs(player.GetAll()) do
                    DarkRP.notify( v, 0, 5, AARMORY.Localise.armory.robberChangedJobs )
                end
                self:SetrobTimer(0)
                timer.Remove("aarmoryRobbing" .. self:EntIndex())
                if !timer.Exists("aarmoryCooldown" .. self:EntIndex()) then
                    timer.Create("aarmoryCooldown" .. self:EntIndex(), self.configTable.aarmoryConfig.cooldownTime.var, 1, function() end)
                else
                    timer.Start("aarmoryCooldown" .. self:EntIndex())
                end
            elseif robber:isArrested() then
                for k, v in pairs(player.GetAll()) do
                    DarkRP.notify( v, 0, 5, AARMORY.Localise.armory.robberArrested )
                end
                self:SetrobTimer(0)
                timer.Remove("aarmoryRobbing" .. self:EntIndex())
                if !timer.Exists("aarmoryCooldown" .. self:EntIndex()) then
                    timer.Create("aarmoryCooldown" .. self:EntIndex(), self.configTable.aarmoryConfig.cooldownTime.var, 1, function() end)
                else
                    timer.Start("aarmoryCooldown" .. self:EntIndex())
                end
            elseif robber:GetPos():DistToSqr(self:GetPos()) > (self.configTable.aarmoryConfig.distance.var * self.configTable.aarmoryConfig.distance.var) then
                for k, v in pairs(player.GetAll()) do
                    DarkRP.notify( v, 0, 5, AARMORY.Localise.armory.robberTooFarFromArmory )
                end
                self:SetrobTimer(0)
                timer.Remove("aarmoryRobbing" .. self:EntIndex())
                if !timer.Exists("aarmoryCooldown" .. self:EntIndex()) then
                    timer.Create("aarmoryCooldown" .. self:EntIndex(), self.configTable.aarmoryConfig.cooldownTime.var, 1, function() end)
                else
                    timer.Start("aarmoryCooldown" .. self:EntIndex())
                end
            end
        end
    end
end

function ENT:Use(ply)
    local plyJob = ply:getJobTable().command
    local isRobber = self.configTable.aarmoryConfig.robbers.table[plyJob]
    local isAdmin = ply:IsAdmin() or ply:IsSuperAdmin() or self.configTable.aarmoryConfig.staff.table[ply:GetUserGroup()]
    local isCP = ply:isCP()
    local isGui = self:GetisGui()

    

    local open = {}
    for k, v in pairs(self.configTable.weapons) do
        if v.useWeapon then
            open[k .. tostring(self)] = self:GetNWBool("open" .. k .. tostring(self))
            if ply.ammoLimit[k] == nil then -- Otherwise when new guns are added players have to reconnect for them to work
                ply.ammoLimit[k] = self.configTable.aarmoryConfig.ammoInteractTimes.var
            end
        end
    end

    local ang = self:GetAngles()
    ang:RotateAroundAxis(self:GetAngles():Right(), 90)
    ang:RotateAroundAxis(self:GetAngles():Up(), 180)
    ang:RotateAroundAxis(self:GetAngles():Forward(), -90)

    pos = self:GetPos() + (ang:Right() * -28) + ( ang:Up() * 8.6 ) + ( ang:Forward() * -24 ) -- Has to be the same pos as in drawStencil() (NOTE: Put this after ang).

    local cursorX, cursorY = WorldToScreen(ply:GetEyeTrace().HitPos, pos, 0.02, ang) -- God knows why only 'ply' instead of 'p' works here.
    --print("X: " .. cursorX .. ", " .. "Y: " .. cursorY)

    local count = 1
    local offset = 0

    if isAdmin and !isCP and !isRobber then
        net.Start("aarmoryUse")
            net.WriteEntity(self)
            net.WriteBool(isAdmin)
            net.WriteBool(isRobber)
            net.WriteTable(self.configTable)
        net.Send(ply)
    end

    if !isGui then
        for k, v in SortedPairs(self.configTable.weapons) do
            if v.useWeapon then
                if cursorX > (0 + offset) and cursorX < (605 + offset) and !open[k .. tostring(self)] and isCP then
                    if self:GetNWBool("cooldown" .. k .. tostring(self)) then
                        DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.restock1 .. v.name .. AARMORY.Localise.armory.restock2 )
                        break
                    else
                        for k, v in pairs(self:GetChildren()) do
                            if v:GetParentAttachment() == count then return end -- The saw's attachment id does not turn back to 0 after removing it from the armory.
                        end
                        self:SetNWBool("open" .. k .. tostring(self), true)
                    end
                elseif cursorX > (0 + offset) and cursorX < (150  + offset) then
                    if isCP then
                        self:SetNWBool("open" .. k .. tostring(self), false)
                        break
                    end
                elseif cursorX > (150 + offset) and cursorX < (605 + offset) then
                    if isCP then
                        if cursorY > 0 and cursorY < 600 then
                                aarmoryGiveWeapon(k, v.name, true, v.ammo, v.ammoAmount, ply.ammoLimit[k], ply, nil, nil, self:GetaarmoryID())
                            break
                        end
                        local isJob = true
                        local isGroup = true
                        if !IsValid(v.restrictJob) or table.IsEmpty(v.restrictJob) or v.restrictJob[plyJob] then
                            isJob = true
                        else
                            isJob = false
                        end
                        if !IsValid(v.restrictGroup) or table.IsEmpty(v.restrictGroup) or v.restrictGroup[ply:GetUserGroup()] then
                            isGroup = true
                        else
                            isGroup = false
                        end
                        aarmoryGiveWeapon(k, v.name, false, v.ammo, v.ammoAmount, ply.ammoLimit[k], ply, isJob, isGroup, self:GetaarmoryID())
                    elseif isRobber and open[k .. tostring(self)] then
                        self:openArmory(true, nil, ply, k)
                    elseif open[k .. tostring(self)] then
                        DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.notRightJobNoGui )
                    end
                    break
                end
                offset = offset + 605
                count = count + 1
            end
        end
    elseif isCP then
        if timer.TimeLeft("aarmoryCooldown" .. self:EntIndex()) != nil then
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.cooldown )
            return
        elseif timer.TimeLeft("aarmoryRobbing" .. self:EntIndex()) != nil then
            DarkRP.notify( ply, 0, 5, AARMORY.Localise.armory.raiding )
            return
        else
            net.Start("aarmoryUse")
                net.WriteEntity(self)
                net.WriteBool(false) -- Otherwise the admin menu comes up when you're a cop.
                net.WriteBool(isRobber)
                net.WriteTable(self.configTable)
            net.Send(ply)
        end
    elseif isRobber then
        self:startAArmoryRobbery(ply)
    end
end

net.Receive("aarmoryGive", function(len, ply)
    local weapon = net.ReadString() -- Note if the weapon gotten from here is not in the weapon table in the config file for some reason then you will get an error.
    local ammoBool = net.ReadBool()
    local id = net.ReadInt(12)
    local weaponPrintName = AARMORY.Config[id].weapons[weapon].name
    local weaponAmmo = AARMORY.Config[id].weapons[weapon].ammo
    local weaponAmmoAmount = AARMORY.Config[id].weapons[weapon].ammoAmount
    local weaponAmmoLimit = ply.ammoLimit[weapon]

    local isJob = true
    local isGroup = true
    if !IsValid(AARMORY.Config[id].weapons[weapon].restrictJob) or table.IsEmpty(AARMORY.Config[id].weapons[weapon].restrictJob) or AARMORY.Config[id].weapons[weapon].restrictJob[plyJob] then
        isJob = true
    else
        isJob = false
    end
    if !IsValid(AARMORY.Config[id].weapons[weapon].restrictGroup) or table.IsEmpty(AARMORY.Config[id].weapons[weapon].restrictGroup) or AARMORY.Config[id].weapons[weapon].restrictGroup[ply:GetUserGroup()] then
        isGroup = true
    else
        isGroup = false
    end

    if ply:isCP() then
        aarmoryGiveWeapon(weapon, weaponPrintName, ammoBool, weaponAmmo, weaponAmmoAmount, weaponAmmoLimit, ply, isJob, isGroup, id)
    end
end)

function ENT:OnRemove()
    if timer.Exists("aarmoryCooldown" .. self:EntIndex()) then
        timer.Remove("aarmoryCooldown" .. self:EntIndex())
    end
    if timer.Exists("aarmoryRobbing" .. self:EntIndex()) then
        timer.Remove("aarmoryRobbing" .. self:EntIndex())
    end
    for k, v in pairs(self.configTable.weapons) do
        if timer.Exists("cooldown" .. k) then
            timer.Remove("aarmoryRobbing" .. self:EntIndex())
        end
        if timer.Exists("cooldown" .. k) then
            timer.Remove("cooldown" .. k)
        end
        if timer.Exists("openTimer" .. k) then
            timer.Remove("openTimer" .. k)
        end
        for a, b in pairs(player.GetAll()) do
            if timer.Exists("ammoLimitTimer" .. k .. b:SteamID()) then
                timer.Stop("ammoLimitTimer" .. k .. b:SteamID())
            end
        end
    end
end
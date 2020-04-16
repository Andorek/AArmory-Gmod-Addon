ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Spawnable = true
 
ENT.PrintName		= "Armory"
ENT.Author			= "Andorek"
ENT.Contact			= "Add me on steam"
ENT.Purpose			= "An Armory"
ENT.Instructions	= ""
ENT.Category = "AArmory"

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "isGui")
    self:NetworkVar("Bool", 1, "alarmChance")

    -- Used for guiMode only
    self:NetworkVar("Int", 0, "robTimer")
    self:NetworkVar("Int", 1, "cooldownTimer")
    
end

function ENT:Initialize() -- I can't use data tables because I need to be able to retrieve the data from a string.

    for k, v in pairs(AARMORY.weaponTable) do
        if self:GetisGui() then return end
        self:SetNWBool("open" .. k, false)
        self:SetNWBool("cooldown" .. k, false)
    end

end
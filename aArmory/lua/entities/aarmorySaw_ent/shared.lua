ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Spawnable = true
 
ENT.PrintName		= "Armory Saw"
ENT.Author			= "Andorek"
ENT.Contact			= "Add me on steam"
ENT.Purpose			= "A saw to rob the Armory"
ENT.Instructions	= ""
ENT.Category = "AArmory"

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "robTimer")
end
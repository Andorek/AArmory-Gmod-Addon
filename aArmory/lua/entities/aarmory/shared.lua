ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Spawnable = true
 
ENT.PrintName		= "Armory"
ENT.Author			= "Andorek"
ENT.Contact			= "Add me on steam"
ENT.Purpose			= "An Armory"
ENT.Instructions	= ""

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsRobbing")
end



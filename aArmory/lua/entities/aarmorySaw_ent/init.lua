AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/props/cs_militia/circularsaw01.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )

    self.sound = CreateSound(self, "npc/manhack/mh_engine_loop1.wav")

    local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:Use(ply)
    if !IsValid(self:GetParent()) then return end
    local pEnt = self:GetParent()
    self:SetmaxRobTime(AARMORY.Config[pEnt:GetaarmoryID()].aarmoryConfig.robTime.var)

    if self:GetParentAttachment() == 1 or self:GetParentAttachment() == 2 or self:GetParentAttachment() == 3 or self:GetParentAttachment() == 4 then -- Need to fix this so its dynamic later.
        if !timer.Exists("sawTimer" .. self:EntIndex()) then
            timer.Create("sawTimer" .. self:EntIndex(), pEnt.configTable.aarmoryConfig.robTime.var, 1, function()
                local pEntForward = self:GetPos() + pEnt:GetAngles():Forward() * 20

                local count = 1
                for k, v in SortedPairs(pEnt.configTable.weapons) do
                    if v.useWeapon then
                        if self:GetParentAttachment() == count then
                            pEnt:SetNWBool("open" .. k .. tostring(pEnt), true)
                            self:SetParent(nil, 0)
                            self.sound:Stop()
                            self:SetPos(pEntForward)

                            pEnt:openArmory(false, pEntForward, nil, k)
                            break
                        end
                        count = count + 1
                    end
                end
            end)
        elseif timer.TimeLeft("sawTimer") != nil then
            timer.Start("sawTimer")
        end

        self.sound:Play()
        self.sound:ChangeVolume(0.6, 0)
        self.sound:ChangePitch(255, 0)
    end

end

function ENT:Think()
    if timer.Exists("sawTimer" .. self:EntIndex()) and timer.TimeLeft("sawTimer" .. self:EntIndex()) != nil then -- ONLY runs when the timer is running. Never reaches 0 because it is cutoff by the networking before it can.
        self:SetrobTimer(timer.TimeLeft("sawTimer" .. self:EntIndex()))
    end
end

function ENT:OnRemove()
    self:SetParent()
    if timer.Exists("cooldownTimer" .. self:EntIndex()) then
        timer.Remove("cooldownTimer" .. self:EntIndex())
    end
    if
       timer.Exists("sawTimer" .. self:EntIndex()) then timer.Remove("sawTimer" .. self:EntIndex())
    end
    if self.sound:IsPlaying() then
        self.sound:Stop()
    end

end
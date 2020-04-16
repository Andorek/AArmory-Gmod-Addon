include( "shared.lua" )

surface.CreateFont( "aarmoryFont", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 22,
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

surface.CreateFont( "aarmoryFontBig", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 100,
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )


surface.CreateFont( "aarmoryFontMassive", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 260,
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

surface.CreateFont( "aarmoryFontSmallerMassive", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 180,
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

function ENT:Initialize()
    --self.time = CurTime()
    local s
    if AARMORY.Settings.useCustomSoundfile then s = AARMORY.Settings.customSoundfile else s = "ambient/alarms/alarm1.wav" end
    self.sound = CreateSound(self, s) -- This has to be clientside otherwise when a player joins afer the armory is created they will not be able to hear any alarm (Important because the armory can be saved to the map, creating the armory before any player joins).
end

function ENT:Draw()
    self:DrawModel()

    local ang = self:GetAngles()
    ang:RotateAroundAxis(self:GetAngles():Right(), 90)
    ang:RotateAroundAxis(self:GetAngles():Up(), 180)
    ang:RotateAroundAxis(self:GetAngles():Forward(), -90)

    local pos = self:GetPos() + (ang:Right() * -45) + ( ang:Up() * 6 ) + ( ang:Forward() * 0 )

    local raidTimer = math.Round(self:GetrobTimer())
    local cooldownTimer = math.Round(self:GetcooldownTimer())

    cam.Start3D2D(pos, ang, 0.025)
        draw.SimpleTextOutlined(AARMORY.Localise.armory.policeArmory, "aarmoryFontMassive", 0, 0, Color(100,100,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 10, Color(0,0,0,255))

        if self:GetisGui() then
            if raidTimer != 0 then
                draw.SimpleTextOutlined(AARMORY.Localise.armory.raidingTimer .. raidTimer, "aarmoryFontSmallerMassive", 0, 270, Color(255,50,50,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 10, Color(0,0,0,255))
            elseif cooldownTimer != 0 then
                draw.SimpleTextOutlined(AARMORY.Localise.armory.cooldownTimer .. cooldownTimer, "aarmoryFontSmallerMassive", 0, 270, Color(150,150,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 10, Color(0,0,0,255))
            end
        end

    cam.End3D2D()
end

function ENT:Think()
    local isAnyOpen = true
    for k, v in pairs(AARMORY.weaponTable) do
        if self:GetNWBool("open" .. k) then -- The alarm wont stop unless ALL locker doors are closed
            isAnyOpen = true
            break
        else
            isAnyOpen = false
        end
    end
    local robTimer = self:GetrobTimer()
    local isGui = self:GetisGui()
    local soundChance = self:GetalarmChance()
    local sound = self.sound
    if isGui then
        if robTimer != 0 then
            sound:Play()
        elseif robTimer == 0 and sound:IsPlaying() then
            sound:Stop()
        end
    elseif soundChance and !sound:IsPlaying() then
        sound:Play()
    elseif !soundChance and sound:IsPlaying() and !isAnyOpen then
        sound:Stop()
    end
end

net.Receive("aarmoryUse", function(len, p)
    local ent = net.ReadEntity()

    local giveAmmo = false

    local frame = vgui.Create( "DFrame", panel ) -- All the sizes/positioning are a mess, but they work for multiple resolutions.
        frame:SetSize( ScrW() * 0.3, ScrH() * 0.6 )
        frame:Center()
        frame:MakePopup()
        frame:SetSizable( false )
        frame:SetDeleteOnClose( true )
        frame:ShowCloseButton( false )
        frame:SetTitle( "" )
        frame:SetDraggable( false )
        frame:SetVisible( true )
        frame.Paint = function( s,w,h )
            draw.RoundedBox( 6, 0, 0, w, h, Color( 100, 100, 255, 255 ) )
            draw.RoundedBox( 6, w / 44, h / 56, w - ( w / 22 ), h - ( h / 28 ), Color( 255, 255, 255, 255 ) )

            draw.RoundedBox( 2, w / 44, h / 1.26, w - ( w / 22 ), h / 5, Color( 100, 100, 255, 255) )
            draw.RoundedBox( 6, w / 44, h / 1.23, w - ( w / 22 ), h / 6, Color( 255, 255, 255, 255 ) )
        end

    local closeButton = vgui.Create( "DButton", frame )
        closeButton:SetPos( frame:GetWide() / 3, frame:GetTall() / 1.18 )
        closeButton:SetSize( frame:GetWide() / 3, frame:GetTall() / 10 )
        closeButton:SetTextColor( Color(255,255,255) )
        closeButton:SetFont( "Trebuchet24" )
        closeButton:SetText( AARMORY.Localise.armory.closeButton )
        closeButton.DoClick = function() frame:Close() end
        closeButton.Paint = function( s, w, h )
            draw.RoundedBox( 6, 0, 0, w, h, Color( 100,100,255,255 ) )
        end
    
    local weaponListPanelBase = vgui.Create( "DPanel", frame )
        weaponListPanelBase:SetPos( frame:GetWide() / 44, frame:GetTall() / 56 )
        weaponListPanelBase:SetSize( frame:GetWide() - ( frame:GetWide() / 22 ), frame:GetTall() / 1.3 )
        weaponListPanelBase.Paint = function( s, w, h ) end
        
    local weaponListScroll = vgui.Create( "DScrollPanel", weaponListPanelBase )
        weaponListScroll:Dock( FILL )
        local barStyle = weaponListScroll:GetVBar()
            barStyle:SetWide( frame:GetWide() / 80 )
            function barStyle:Paint( w, h ) end
            function barStyle.btnUp:Paint( w, h ) end
            function barStyle.btnDown:Paint( w, h ) end
            function barStyle.btnGrip:Paint( w, h ) 
                draw.RoundedBox( 2, 0, 0, w / 2, h, Color( 220, 220, 220, 255 ) )
            end

    local pHeightOffset = frame:GetTall() / 50
    local pHeight = frame:GetTall() / 48
    for k, v in pairs(AARMORY.weaponTable) do
        local wName = v.printName
        local wModel = v.model

        local giveAmmo
        if ply:HasWeapon(k) then
            giveAmmo = true
        else
            giveAmmo = false
        end

        local weaponListPanel = weaponListScroll:Add( "DFrame" )
            weaponListPanel:SetPos( frame:GetWide() / 32, pHeight )
            weaponListPanel:SetSize( frame:GetWide() - ( frame:GetWide() / 10 ), frame:GetTall() / 5.8 )
            weaponListPanel:SetSizable( false )
            weaponListPanel:ShowCloseButton( false )
            weaponListPanel:SetTitle( "" )
            weaponListPanel:SetDraggable( false )
            weaponListPanel.Paint = function( s, w, h )
                draw.RoundedBox( 6, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
                draw.DrawText( wName, "Trebuchet24", w / 2.5, h / 2.5, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
            end

        local weaponButton = vgui.Create( "DButton", weaponListPanel )
            weaponButton:SetPos( weaponListPanel:GetWide() / 1.65, weaponListPanel:GetTall() / 4 )
            weaponButton:SetSize( weaponListPanel:GetWide() / 3, weaponListPanel:GetTall() / 1.8 )
            weaponButton:SetText( "" )
            weaponButton.Paint = function( s, w, h )
                draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 200, 200, 255 ) )
                if giveAmmo then
                    draw.DrawText( AARMORY.Localise.armory.equipAmmoButton, "Trebuchet24", w / 2, h / 4, Color( 0, 0, 0, 255), TEXT_ALIGN_CENTER )
                else
                    draw.DrawText( AARMORY.Localise.armory.equipButton, "Trebuchet24", w / 2, h / 4, Color( 0, 0, 0, 255), TEXT_ALIGN_CENTER )
                end
            end
            weaponButton.DoClick = function()

                net.Start( "aarmoryGive" )
                    net.WriteString( k )
                    net.WriteBool( giveAmmo )
                net.SendToServer()
            
                if !giveAmmo then
                    frame:Close()
                end

            end

        local weaponModelPanel = vgui.Create( "DPanel", weaponListPanel )
            weaponModelPanel:SetPos( ( weaponListPanel:GetWide() / weaponListPanel:GetTall() ) * 2, weaponListPanel:GetWide() / weaponListPanel:GetTall() * 2 )
            weaponModelPanel:SetSize( ( weaponListPanel:GetWide() / weaponListPanel:GetTall() ) * 20, ( weaponListPanel:GetWide() / weaponListPanel:GetTall() ) * 20 )
            weaponModelPanel.Paint = function( s, w, h )
                draw.RoundedBox( 6, 0, 0, w, h, Color( 210, 210, 210, 255 ) )
            end 

        local weaponModel = vgui.Create( "DModelPanel", weaponModelPanel ) -- Pretty sure I got most of this from either a wiki or a youtube video
            weaponModel:SetPos( 0, 0 )
            weaponModel:SetSize( weaponModelPanel:GetWide(), weaponModelPanel:GetTall() )
            weaponModel:SetModel( wModel )
            function weaponModel:LayoutEntity( Entity ) return end
            local mn, mx = weaponModel.Entity:GetRenderBounds()
            local size = 0
            size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
            size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
            size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )
            weaponModel:SetFOV( 40 )
            weaponModel:SetCamPos( Vector(
            size - 0,
            size + 0,
            size
            )
            )
            weaponModel:SetLookAt((mn + mx) * 0.5)


        pHeight = pHeight + weaponListPanel:GetTall() + pHeightOffset
    end        


end)

local function drawStencil()
    
    for k, v in pairs(ents.FindByClass("aarmory_ent")) do
        local ent = v
        local isGui = ent:GetisGui()
        local entPos = ent:GetPos()

        if !isGui and LocalPlayer():GetPos():DistToSqr(entPos) < (900 * 900) then
            local ang = v:GetAngles()
            ang:RotateAroundAxis(v:GetAngles():Right(), 90)
            ang:RotateAroundAxis(v:GetAngles():Up(), 180)
            ang:RotateAroundAxis(v:GetAngles():Forward(), -90)

            local pos = v:GetPos() + (ang:Right() * -28) + ( ang:Up() * 8.6 ) + ( ang:Forward() * -24 )

            local open = {}
            local cooldown = {}
            for k, v in pairs(AARMORY.weaponTable) do
                open[k] = ent:GetNWBool("open" .. k)
                cooldown[k] = ent:GetNWBool("cooldown" .. k)
            end

            cam.Start3D2D(pos, ang, 0.02)
                local offset = 0
                for k, v in pairs(AARMORY.weaponTable) do
                    if cooldown[k] then
                        draw.SimpleText("Restocking", "aarmoryFontBig", 290 + offset, 150, Color(255,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                    end
                    draw.SimpleText(v.printName, "aarmoryFontBig", 290 + offset, 30, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                    offset = offset + 610
                end
            cam.End3D2D()

            v:SetRenderMode(RENDERMODE_TRANSCOLOR)
            v:SetColor(Color(255,255,255,255))

                render.SetStencilEnable(true)
                
                    render.SetStencilWriteMask(255)
                    render.SetStencilTestMask(255)
                    
                    -- Draw the cut in the world
                    render.SetStencilReferenceValue(1)
                    render.SetStencilCompareFunction(STENCIL_ALWAYS)
                    render.SetStencilPassOperation(STENCIL_REPLACE)  
                    render.SetStencilZFailOperation( STENCIL_KEEP )

                    cam.Start3D2D(pos, ang, 0.02)

                        surface.SetDrawColor(255, 255, 255, 255)
                        local offset2 = 0
                        for k, v in pairs(AARMORY.weaponTable) do
                            if open[k] then
                                surface.DrawRect(0 + offset2, 0, 580, 2900)
                            end
                            offset2 = offset2 + 605
                        end

                    cam.End3D2D()

                    -- Draw items in cut
                    render.SetStencilCompareFunction(STENCIL_EQUAL)
                    cam.IgnoreZ( true ) -- see objects through world

                        render.SetLightingMode( 1 )
                        render.DepthRange(0, 0.9) -- VERY important. Stops the stencil rendering in front of the viewmodel.
                        
                        ang:RotateAroundAxis(v:GetAngles():Up(), 90)
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 15) + ( ang:Up() * 2) + ( ang:Forward() * 10), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 15) + ( ang:Up() * 14) + ( ang:Forward() * 10), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 15) + ( ang:Up() * 26) + ( ang:Forward() * 10), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 15) + ( ang:Up() * 38) + ( ang:Forward() * 10), angle = ang})

                        ang:RotateAroundAxis(v:GetAngles():Up(), 180)
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 15) + ( ang:Up() * -10) + ( ang:Forward() * -10), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 15) + ( ang:Up() * -21.7) + ( ang:Forward() * -10), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 15) + ( ang:Up() * -34) + ( ang:Forward() * -10), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 15) + ( ang:Up() * -46.3) + ( ang:Forward() * -10), angle = ang})

                        ang:RotateAroundAxis(v:GetAngles():Forward(), 90)
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 20) + ( ang:Up() * 48) + ( ang:Forward() * -10), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 20) + ( ang:Up() * 2) + ( ang:Forward() * -10), angle = ang})

                        ang:RotateAroundAxis(v:GetAngles():Forward(), -180)
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * -20) + ( ang:Up() * -10) + ( ang:Forward() * -10), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * -20) + ( ang:Up() * -22) + ( ang:Forward() * -10), angle = ang})

                        ang:RotateAroundAxis(v:GetAngles():Forward(), 90)
                        ang:RotateAroundAxis(v:GetAngles():Up(), -90 )
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 20) + ( ang:Up() * 10) + ( ang:Forward() * -10), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 20) + ( ang:Up() * 10) + ( ang:Forward() * -29), angle = ang})
                            render.Model({model = "models/props_phx/trains/trackslides_outer.mdl", pos = pos + (ang:Right() * 20) + ( ang:Up() * 10) + ( ang:Forward() * -39), angle = ang})

                        ang:RotateAroundAxis(v:GetAngles():Right(), -90 )
                        ang:RotateAroundAxis(v:GetAngles():Forward(), -90 )

                        local globalPitch, globalYaw, globalRoll = AARMORY.Settings.weaponPitch or 0, AARMORY.Settings.weaponYaw or 0, AARMORY.Settings.weaponRoll or 0
                        local globalX, globalY, globalZ = AARMORY.Settings.weaponX or 0, AARMORY.Settings.weaponY or 0, AARMORY.Settings.weaponZ or 0

                        local offSet1 = 0
                        
                        --local dOffsetX = 0
                        --local dOffsetY = 0
                        --local dOffsetZ = 0
                        for k, v in pairs(AARMORY.weaponTable) do
                            local offsetPitch, offsetYaw, offsetRoll = v.pitch or 0, v.yaw or 0, v.roll or 0
                            local offsetX, offsetY, offsetZ = v.posX or 0, v.posY or 0, v.posZ or 0
                            
                            ang:RotateAroundAxis(ent:GetAngles():Right(), offsetPitch + globalPitch)
                            ang:RotateAroundAxis(ent:GetAngles():Up(), offsetYaw + globalYaw)
                            ang:RotateAroundAxis(ent:GetAngles():Forward(), offsetRoll + globalRoll)

                            render.Model({model = v.model, pos = pos + (ang:Right() * (15 + globalZ + offsetZ)) + ( ang:Up() * (3.5 + offSet1 + globalX + offsetX)) + ( ang:Forward() * (-45 + globalY + offsetY)), angle = ang})
                            render.Model({model = v.model, pos = pos + (ang:Right() * (11 + globalZ + offsetZ)) + ( ang:Up() * (3.5 + offSet1 + globalX + offsetX)) + ( ang:Forward() * (-45 + globalY + offsetY)), angle = ang})
                            render.Model({model = v.model, pos = pos + (ang:Right() * (7 + globalZ + offsetZ)) + ( ang:Up() * (3.5 + offSet1 + globalX + offsetX)) + ( ang:Forward() * (-45 + globalY + offsetY)), angle = ang})
                            render.Model({model = v.model, pos = pos + (ang:Right() * (3 + globalZ + offsetZ)) + ( ang:Up() * (3.5 + offSet1 + globalX + offsetX)) + ( ang:Forward() * (-45 + globalY + offsetY)), angle = ang})
                            
                            ang:RotateAroundAxis(ent:GetAngles():Right(), -(offsetPitch + globalPitch))
                            ang:RotateAroundAxis(ent:GetAngles():Up(), -(offsetYaw + globalYaw))
                            ang:RotateAroundAxis(ent:GetAngles():Forward(), -(offsetRoll + globalRoll))

                            ang:RotateAroundAxis(ent:GetAngles():Forward(), 90)
                                render.Model({model = "models/items/boxmrounds.mdl", pos = pos + (ang:Right() * 10) + ( ang:Up() * -12.6) + ( ang:Forward() * (-115 + offSet1 + 73)), angle = ang})
                            ang:RotateAroundAxis(ent:GetAngles():Forward(), -90)

                            --[[ An animated locker door that opens. Doesn't look good at all in stencil but I'll work with it later.
                            ang:RotateAroundAxis(ent:GetAngles():Forward(), 90)
                            ang:RotateAroundAxis(ent:GetAngles():Up(), 90)
                                local startDoorX = ang:Right() * (-5 - offSet1)
                                local startDoorY = ang:Up() * -30
                                local startDoorZ = ang:Forward() * -1
                                local endDoorX = ang:Right() * (-1 - offSet1)
                                local endDoorY = ang:Up() * -30
                                local endDoorZ = ang:Forward() * 9
                            ang:RotateAroundAxis(ent:GetAngles():Up(), -90)
                            ang:RotateAroundAxis(ent:GetAngles():Forward(), -90)

                            local doorX = endDoorX
                            local doorY = endDoorY
                            local doorZ = endDoorZ
                            local doorRot = 0
                            if ent.time < CurTime()-5 && ent.time > CurTime()-6.6 then -- Handles the transition
                                doorRot = (90+(ent.time+5 - CurTime())*50)
                                doorX = LerpVector((ent.time+5 - CurTime()), endDoorX, startDoorX)
                                doorY = LerpVector((ent.time+5 - CurTime()), endDoorY, startDoorY)
                                doorZ = LerpVector((ent.time+5 - CurTime()), endDoorZ, startDoorZ)
                            elseif ent.time > CurTime()-6.6 then -- The start rotation
                                doorRot = 90
                                doorX = startDoorX
                                doorY = startDoorY
                                doorZ = startDoorZ
                            end

                            ang:RotateAroundAxis(ent:GetAngles():Forward(), 90)
                            ang:RotateAroundAxis(ent:GetAngles():Up(), doorRot)
                                render.Model({model = "models/props_lab/lockerdoorleft.mdl", pos = pos + doorX + doorY + doorZ, angle = ang}) 
                            ang:RotateAroundAxis(ent:GetAngles():Up(), -doorRot) -- For some reason I've got to cancel these angles out invertedly otherwise the angles for everything gets weird.
                            ang:RotateAroundAxis(ent:GetAngles():Forward(), -90)

                            dOffsetX = dOffsetX + 12
                            dOffsetY = dOffsetY + 0
                            dOffsetZ = dOffsetZ + 12

                            ]]--

                            offSet1 = offSet1 + 12.1
                            
                        end
                        
                        render.SetLightingMode( 0 )

                    
                    cam.IgnoreZ( false )

                render.SetStencilEnable(false)
                render.DepthRange(0, 1)
         end
    end
end
hook.Add("PostDrawTranslucentRenderables", "DrawStencil", drawStencil)

function ENT:OnRemove()
    if self.sound:IsPlaying() then
        self.sound:Stop()
    end
end
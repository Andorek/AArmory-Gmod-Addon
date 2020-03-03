include( "shared.lua" )

surface.CreateFont( "aarmoryFont", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 80,
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

function ENT:Draw()
    self:DrawModel()

    local ang = self:GetAngles()
    ang:RotateAroundAxis(self:GetAngles():Right(), 90)
	ang:RotateAroundAxis(self:GetAngles():Up(), 180)
    ang:RotateAroundAxis(self:GetAngles():Forward(), -90)
    
    local pos = self:GetPos() + (ang:Right() * -45) + ( ang:Up() * 1 ) + ( ang:Forward() * 1 ) -- The self:GetAngles() (ang) here are so the 3d2d rotates and positions its self relative to the entity correctly

    cam.Start3D2D(pos, ang, 0.1)
        local c
        if self:GetisAArmoryRobbing() then
            c = Color(255, 0, 0, 255)
        else
            c = Color(100, 100, 255, 255)
        end
        draw.SimpleTextOutlined("Police Armory", "aarmoryFont", 0, 0, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_Center, 2, Color(0,0,0,255))
    cam.End3D2D()
end

aarmorySound = {}
local function makeSound(ent) -- Sound can only be made after client connects, so making it on the server breaks the sound on ents spawned before the player connects.
    local s
    if AARMORY.Settings.useCustomSoundfile then s = AARMORY.Settings.customSoundfile else s = "ambient/alarms/alarm1.wav" end
    for k, v in pairs( ents.FindByClass( "aarmory" ) ) do
        if ent == v then
            aarmorySound[v] = {
                sound = CreateSound(v, s)
            }
        end     
    end
end
hook.Add("OnEntityCreated", "MakeSound", makeSound)

-- Most positions/sizes are a huge mess, but they work.
net.Receive("useAArmoryEnt", function()

        local frame = vgui.Create( "DFrame", panel )
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
            closeButton:SetText( "Close" )
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
        for k, v in pairs( AARMORY.weaponTable) do
            local wName = v.printName
            local wModel = v.model

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
                    draw.DrawText( "Equip", "Trebuchet24", w / 2, h / 4, Color( 0, 0, 0, 255), TEXT_ALIGN_CENTER )
                end
                weaponButton.DoClick = function()

                    net.Start( "giveAArmoryWeapon" )
                        net.WriteString( k )
                        net.WriteString( wName )
                    net.SendToServer()
                
                    frame:Close()

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

local robToggle = nil
function ENT:Think()
    local isRobbing = self:GetisAArmoryRobbing()
    if isRobbing and robToggle then return end

    if isRobbing and !robToggle then
        for k, v in pairs(aarmorySound) do
            if k == self then
                local s = v.sound
                s:Play()
            end
        end
        robToggle = true
    elseif !isRobbing and robToggle then
        for k, v in pairs(aarmorySound) do
            if k == self then
                local s = v.sound
                if s:IsPlaying() then 
                    s:Stop() 
                    robToggle = nil -- A few nested if statements but this needs to be here so the loops aren't running 24/7, only when needed.
                end
            end
        end
    end
end

function ENT:OnRemove()
    for k, v in pairs(aarmorySound) do
        local s = v.sound
        if s:IsPlaying() then s:Stop() end
    end
end
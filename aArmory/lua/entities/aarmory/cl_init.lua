include( "shared.lua" )

function ENT:Draw()
    self:DrawModel()

    local ang = self:GetAngles()
    local pos = self:GetPos() + (ang:Right() * 1) + ( ang:Up() * 1 ) + ( ang:Forward() * 1 ) -- The self:GetAngles() (ang) here are so the 3d2d rotates and positions its self relative to the entity correctly

    cam.Start3D2D(pos, ang, 0.02)

    cam.End3D2D()
end

AARMORY.Internal.aarmorySound = {}
local function makeSound(ent) -- Sound can only be made after client connects.
    local s
    if AARMORY.Settings.useCustomSoundfile then s = AARMORY.Settings.customSoundfile else s = "ambient/alarms/alarm1.wav" end
    for k, v in pairs( ents.FindByClass( "aarmory" ) ) do
        if ent == v and IsValid(v) then
            print("AArmory found!")
            AARMORY.Internal.aarmorySound[v] = {
                sound = CreateSound(v, s)
            }
        end     
    end
end
hook.Add("OnEntityCreated", "MakeSound", makeSound)

-- Most positions/sizes are a huge mess, but they work.
net.Receive("useEnt", function()
    local isCop = net.ReadBool()
    local plyJob = net.ReadString()
    local ent = net.ReadEntity()

    if isCop then
        local fWidth = ScrW() * 0.3
        local fHeight = ScrH() * 0.6

        local frame = vgui.Create( "DFrame", panel )
            frame:SetSize( fWidth, fHeight )
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
                draw.RoundedBox( 6, ( w / 22 ) / 2, ( h / 28 ) / 2, w - ( w / 22 ), h - ( h / 28 ), Color( 255, 255, 255, 255 ) )

                draw.RoundedBox( 2, ( w / 22 ) / 2, h / 1.26, w - ( w / 22 ), h / 5, Color( 100, 100, 255, 255) )
                draw.RoundedBox( 6, ( w / 22 ) / 2, h / 1.23, w - ( w / 22 ), h / 6, Color( 255, 255, 255, 255 ) )
            end

        local closeButton = vgui.Create( "DButton", frame )
            closeButton:SetPos( ( fWidth / 2 ) - ( ( fWidth / 3 ) / 2 ), fHeight / 1.18 )
            closeButton:SetSize( fWidth / 3, fHeight / 10 )
            closeButton:SetTextColor( Color(255,255,255) )
            closeButton:SetFont( "Trebuchet24" )
            closeButton:SetText( "Close" )
            closeButton.DoClick = function() frame:Close() end
            closeButton.Paint = function( s, w, h )
                draw.RoundedBox( 6, 0, 0, w, h, Color( 100,100,255,255 ) )
            end
        
        local weaponListPanelBase = vgui.Create( "DPanel", frame )
            weaponListPanelBase:SetPos( ( fWidth / 22 ) / 2, ( fHeight / 28 ) / 2 )
            weaponListPanelBase:SetSize( fWidth - ( fWidth / 22 ), fHeight / 1.3 )
            weaponListPanelBase.Paint = function( s, w, h ) end
            

        local weaponListScroll = vgui.Create( "DScrollPanel", weaponListPanelBase )
            weaponListScroll:Dock( FILL )
            local barStyle = weaponListScroll:GetVBar()
                barStyle:SetWide( fWidth / 80 )
                function barStyle:Paint( w, h ) end
                function barStyle.btnUp:Paint( w, h ) end
                function barStyle.btnDown:Paint( w, h ) end
                function barStyle.btnGrip:Paint( w, h ) 
                    draw.RoundedBox( 2, 0, 0, w / 2, h, Color( 220, 220, 220, 255 ) )
                end

        local pHeightOffset = fHeight / 50
        local pHeight = fHeight / 48
        for k, v in SortedPairsByMemberValue( AARMORY.weaponTable, "printName", true ) do
            local wName = v.printName
            local wModel = v.model

            local weaponListPanel = weaponListScroll:Add( "DFrame" )
                weaponListPanel:SetPos( ( fWidth / 16 ) / 2, pHeight )
                weaponListPanel:SetSize( fWidth - ( fWidth / 10 ), fHeight / 5.8 )
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

                    net.Start( "giveWeapon" )
                        net.WriteString( k )
                        net.WriteString( wName )
                    net.SendToServer()
                
                    frame:Close()

                end

            local weaponModelPanel = vgui.Create( "DPanel", weaponListPanel )
                weaponModelPanel:SetPos( ( weaponListPanel:GetWide() / weaponListPanel:GetTall() ) * 2, weaponListPanel:GetWide() / weaponListPanel:GetTall() * 1.2 )
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
    end
end)

local robToggle = nil
function ENT:Think()
    local isRobbing = self:GetNWBool("isRobbingN")
    if isRobbing and robToggle then return end

    if isRobbing and !robToggle then
        for k, v in pairs(AARMORY.Internal.aarmorySound) do
            if k == self then
                local s = v.sound
                s:Play()
            end
        end
        robToggle = true
    end

    if !isRobbing then
        for k, v in pairs(AARMORY.Internal.aarmorySound) do
            if k == self then
                local s = v.sound
                s:Stop()
            end
        end
        robToggle = false
    end
end

function ENT:OnRemove()
    for k, v in pairs(AARMORY.Internal.aarmorySound) do
        local s = v.sound
        if s:IsPlaying() then s:Stop() end
    end
end
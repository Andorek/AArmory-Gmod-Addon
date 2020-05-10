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

surface.CreateFont( "aarmoryFontGui", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 12,
    weight = 100,
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

surface.CreateFont( "aarmoryFontGuiBig", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 14,
    weight = 500,
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


local clientConfig = {}
net.Receive("aarmoryClientConfig", function()
    local id = net.ReadUInt(12)
    local weaponCount = net.ReadInt(12)
    if weaponCount == 0 then return end
    clientConfig[id] = {}
    clientConfig[id].weapons = {}
    for i = 1, weaponCount do
        local wEnt = net.ReadString()
        local wName = net.ReadString()
        local wModel = net.ReadString()
        local wBool = net.ReadBool()
        local wPos = net.ReadVector()
        local wAng = net.ReadAngle()
        if wBool then
            clientConfig[id].weapons[wEnt] = {}
            clientConfig[id].weapons[wEnt].name = wName
            clientConfig[id].weapons[wEnt].model = wModel
            clientConfig[id].weapons[wEnt].stencilPos = wPos
            clientConfig[id].weapons[wEnt].stencilAng = wAng
        end
    end
end)

function ENT:Initialize()
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
    if table.IsEmpty(clientConfig) or clientConfig[self:GetaarmoryID()] == nil then return end
    for k, v in pairs(clientConfig[self:GetaarmoryID()].weapons) do
        if self:GetNWBool("open" .. k .. tostring(self)) then -- The alarm wont stop unless ALL locker doors are closed
            return
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
    elseif !soundChance and sound:IsPlaying() then
        sound:Stop()
    end
end

net.Receive("aarmoryUse", function(len, p)
    local ent = net.ReadEntity()
    local isAdmin = net.ReadBool()
    local isRobber = net.ReadBool()
    local configTable = net.ReadTable()
    
    local giveAmmo = false

    

    if isAdmin then

        local adminFrame = vgui.Create( "DFrame", panel ) -- All the sizes/positioning are a mess, but they work for multiple resolutions.
        adminFrame:SetSize( (ScrW() * 0.3) * 2, ScrH() * 0.6 )
        adminFrame:Center()
        adminFrame:MakePopup()
        adminFrame:SetSizable( false )
        adminFrame:SetDeleteOnClose( true )
        adminFrame:ShowCloseButton( false )
        adminFrame:SetTitle( "" )
        adminFrame:SetDraggable( false )
        adminFrame:SetVisible( true )
        adminFrame.Paint = function( s,w,h )
            draw.RoundedBox( 6, 0, 0, w, h, Color( 100, 100, 255, 255 ) ) -- Whole background
            draw.RoundedBox( 6, w / 80, h / 60, w / 2.1, h / 1.035, Color( 255, 255, 255, 255 ) ) -- Left Panel
            draw.RoundedBox( 6, w / 1.95, h / 60, w / 2.1, h / 1.035, Color( 255, 255, 255, 255 ) ) -- Right Panel

            draw.RoundedBox( 6, 0, h / 1.26, w, h / 1.035, Color( 100, 100, 255, 255 ) ) -- Bottom Border
            draw.RoundedBox( 6, w / 80, h / 1.23, w / 1.025, h / 6, Color( 255, 255, 255, 255 ) ) -- Bottom Background

            draw.SimpleTextOutlined(AARMORY.Localise.armory.adminPanel, "aarmoryFont", w / 4, h / 30, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0,0,0,255))
            draw.SimpleTextOutlined(AARMORY.Localise.armory.adminWeaponPanel, "aarmoryFont", w / 1.32, h / 30, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0,0,0,255))
            
        end

        local configScrollPanel = vgui.Create( "DPanel", adminFrame )
                configScrollPanel:SetPos( adminFrame:GetWide() / 50, adminFrame:GetTall() / 8 )
                configScrollPanel:SetSize( ( adminFrame:GetWide() / 2.15 ), adminFrame:GetTall() / 1.49 )
                configScrollPanel.Paint = function( s, w, h ) end
            
        local configScroll = vgui.Create( "DScrollPanel", configScrollPanel )
            configScroll:Dock( FILL )
            local barStyle = configScroll:GetVBar()
                barStyle:SetWide( adminFrame:GetWide() / 100 )
                function barStyle:Paint( w, h ) end
                function barStyle.btnUp:Paint( w, h ) end
                function barStyle.btnDown:Paint( w, h ) end
                function barStyle.btnGrip:Paint( w, h ) 
                    draw.RoundedBox( 2, w / 2, 0, w / 2, h, Color( 220, 220, 220, 255 ) )
                end

        local pHeightOffset = adminFrame:GetTall() / 8
        local pHeight = 0
        for k, v in pairs(configTable.aarmoryConfig) do
            local cName = v.pName
            local cDes = v.des

            local configFrame = vgui.Create("DFrame", configScroll)
                configFrame:SetPos(0, pHeight)
                configFrame:SetSize(adminFrame:GetWide() / 2.2, adminFrame:GetTall() / 10)
                configFrame:SetSizable( false )
                configFrame:SetDeleteOnClose( true )
                configFrame:ShowCloseButton( false )
                configFrame:SetTitle( "" )
                configFrame:SetDraggable( false )
                configFrame.Paint = function(s, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, Color(220,220,220,255)) -- Background
                    draw.SimpleTextOutlined(cName, "aarmoryFont", w / 50, h / 3, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    draw.SimpleText(cDes, "aarmoryFontGui", w / 50, h / 1.3, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

            if istable(v.table) then -- I could combine a few vgui elements here but for sake of organisation I won't.
                if v.type == "jobs" then
                    local jobComboEntry = vgui.Create("DComboBox", configFrame)
                        jobComboEntry:SetPos(configFrame:GetWide() / 1.7, configFrame:GetTall() / 6)
                        jobComboEntry:SetSize(configFrame:GetWide() / 4.5, configFrame:GetTall() / 3)
                        jobComboEntry:SetText(AARMORY.Localise.armory.jobs)
                        for a, b in pairs(v.table) do
                            if !b then
                                jobComboEntry:AddChoice(a)
                            end
                        end

                    local jobComboAllowed = vgui.Create("DComboBox", configFrame)
                        jobComboAllowed:SetPos(configFrame:GetWide() / 1.7, configFrame:GetTall() / 1.7)
                        jobComboAllowed:SetSize(configFrame:GetWide() / 4.5, configFrame:GetTall() / 3)
                        jobComboAllowed:SetText(AARMORY.Localise.armory.allowed)
                        for a, b in pairs(v.table) do
                            if b then
                                jobComboAllowed:AddChoice(a)
                            end
                        end

                    local jobAddButton = vgui.Create("DButton", configFrame)
                        jobAddButton:SetPos(configFrame:GetWide() / 1.22, configFrame:GetTall() / 6)
                        jobAddButton:SetSize(configFrame:GetWide() / 6, configFrame:GetTall() / 3)
                        jobAddButton:SetTextColor(Color(255,255,255,255))
                        jobAddButton:SetFont("aarmoryFontGuiBig")
                        jobAddButton:SetText(AARMORY.Localise.armory.add)
                        jobAddButton.Paint = function(s, w, h)
                            draw.RoundedBox(6, 0, 0, w, h, Color(50,255,50,255))
                        end
                        jobAddButton.DoClick = function()
                            local job = jobComboEntry:GetSelected()
                            if job == nil then return end
                            v.table[job] = true

                            jobComboEntry:Clear() -- There really should be a way to remove individual options
                            jobComboEntry:SetText(AARMORY.Localise.armory.jobs)
                            for a, b in pairs(v.table) do
                                if !b then
                                    jobComboEntry:AddChoice(a)
                                end
                            end

                            jobComboAllowed:Clear()
                            jobComboAllowed:SetText(AARMORY.Localise.armory.allowed)
                            for a, b in pairs(v.table) do
                                if b then
                                    jobComboAllowed:AddChoice(a)
                                end
                            end
                        end


                    local jobRemoveButton = vgui.Create("DButton", configFrame)
                        jobRemoveButton:SetPos(configFrame:GetWide() / 1.22, configFrame:GetTall() / 1.7)
                        jobRemoveButton:SetSize(configFrame:GetWide() / 6, configFrame:GetTall() / 3)
                        jobRemoveButton:SetTextColor(Color(255,255,255,255))
                        jobRemoveButton:SetFont("aarmoryFontGuiBig")
                        jobRemoveButton:SetText(AARMORY.Localise.armory.remove)
                        jobRemoveButton.Paint = function(s, w, h)
                            draw.RoundedBox(6, 0, 0, w, h, Color(255,50,50,255))
                        end
                        jobRemoveButton.DoClick = function()
                            local job = jobComboAllowed:GetSelected()
                            if job == nil then return end
                            v.table[job] = false

                            jobComboEntry:Clear() -- There really should be a way to remove individual options
                            jobComboEntry:SetText(AARMORY.Localise.armory.jobs)
                            for a, b in pairs(v.table) do
                                if !b then
                                    jobComboEntry:AddChoice(a)
                                end
                            end

                            jobComboAllowed:Clear()
                            jobComboAllowed:SetText(AARMORY.Localise.armory.allowed)
                            for a, b in pairs(v.table) do
                                if b then
                                    jobComboAllowed:AddChoice(a)
                                end
                            end
                        end
                elseif v.type == "staff" then
                    local staffTextEntry = vgui.Create("DTextEntry", configFrame)
                        staffTextEntry:SetPos(configFrame:GetWide() / 1.7, configFrame:GetTall() / 6)
                        staffTextEntry:SetSize(configFrame:GetWide() / 4.5, configFrame:GetTall() / 3)
                        staffTextEntry:SetText(AARMORY.Localise.armory.groups)

                    local staffComboAllowed = vgui.Create("DComboBox", configFrame)
                        staffComboAllowed:SetPos(configFrame:GetWide() / 1.7, configFrame:GetTall() / 1.7)
                        staffComboAllowed:SetSize(configFrame:GetWide() / 4.5, configFrame:GetTall() / 3)
                        staffComboAllowed:SetText(AARMORY.Localise.armory.allowed)
                        for a, b in pairs(v.table) do
                            if b then
                                staffComboAllowed:AddChoice(a)
                            end
                        end

                    local staffAddButton = vgui.Create("DButton", configFrame)
                        staffAddButton:SetPos(configFrame:GetWide() / 1.22, configFrame:GetTall() / 6)
                        staffAddButton:SetSize(configFrame:GetWide() / 6, configFrame:GetTall() / 3)
                        staffAddButton:SetTextColor(Color(255,255,255,255))
                        staffAddButton:SetFont("aarmoryFontGuiBig")
                        staffAddButton:SetText(AARMORY.Localise.armory.add)
                        staffAddButton.Paint = function(s, w, h)
                            draw.RoundedBox(6, 0, 0, w, h, Color(50,255,50,255))
                        end
                        staffAddButton.DoClick = function()
                            local group = staffTextEntry:GetValue()
                            v.table[group] = true
                            staffComboAllowed:Clear()
                            staffComboAllowed:SetText(AARMORY.Localise.armory.allowed)
                            for a, b in pairs(v.table) do
                                if b then
                                    staffComboAllowed:AddChoice(a)
                                end
                            end
                        end


                    local staffRemoveButton = vgui.Create("DButton", configFrame)
                        staffRemoveButton:SetPos(configFrame:GetWide() / 1.22, configFrame:GetTall() / 1.7)
                        staffRemoveButton:SetSize(configFrame:GetWide() / 6, configFrame:GetTall() / 3)
                        staffRemoveButton:SetTextColor(Color(255,255,255,255))
                        staffRemoveButton:SetFont("aarmoryFontGuiBig")
                        staffRemoveButton:SetText(AARMORY.Localise.armory.remove)
                        staffRemoveButton.Paint = function(s, w, h)
                            draw.RoundedBox(6, 0, 0, w, h, Color(255,50,50,255))
                        end
                        staffRemoveButton.DoClick = function()
                            local group = staffComboAllowed:GetSelected()
                            if group == nil then return end
                            if group then
                                v.table[group] = false
                            end
                            staffComboAllowed:Clear()
                            staffComboAllowed:SetText(AARMORY.Localise.armory.allowed)
                            for a, b in pairs(v.table) do
                                if b then
                                    staffComboAllowed:AddChoice(a)
                                end
                            end
                        end
                    end
            elseif type(v.var) == "boolean" then
                local bColor = Color(50,255,50,255)
                local boolButton = vgui.Create("DButton", configFrame)
                    boolButton:SetPos(configFrame:GetWide() / 1.5, configFrame:GetTall() / 50)
                    boolButton:SetSize(configFrame:GetWide() / 3, configFrame:GetTall() / 2)
                    boolButton:SetTextColor( Color(255,255,255) )
                    boolButton:SetFont( "aarmoryFontGuiBig" )
                    boolButton.DoClick = function()
                        v.var = !v.var
                        print(v.var)
                    end
                    boolButton.Think = function()
                        if v.var then
                            boolButton:SetText( AARMORY.Localise.armory.enabled )
                            bColor = Color(50,255,50,255)
                        else
                            boolButton:SetText( AARMORY.Localise.armory.disabled )
                            bColor = Color(255,50,50,255)
                        end
                    end
                    boolButton.Paint = function(s, w, h)
                        draw.RoundedBoxEx(10, 0, 0, w, h, bColor, false, false, true, false)
                    end
            else
                local settingTextEntry = vgui.Create("DTextEntry", configFrame)
                        settingTextEntry:SetPos(configFrame:GetWide() / 1.7, configFrame:GetTall() / 6)
                        settingTextEntry:SetSize(configFrame:GetWide() / 4.5, configFrame:GetTall() / 3)
                        settingTextEntry:SetText(v.var)
                        settingTextEntry.OnChange = function()
                            v.var = settingTextEntry:GetValue()
                            print(v.var)
                        end
            end

            pHeight = pHeight + pHeightOffset
        end

        local weaponScrollPanel = vgui.Create( "DPanel", adminFrame )
                weaponScrollPanel:SetPos( adminFrame:GetWide() / 1.93, adminFrame:GetTall() / 8 )
                weaponScrollPanel:SetSize( ( adminFrame:GetWide() / 2.15 ), adminFrame:GetTall() / 1.49 )
                weaponScrollPanel.Paint = function( s, w, h ) end
            
        local weaponScroll = vgui.Create( "DScrollPanel", weaponScrollPanel )
            weaponScroll:Dock( FILL )
            local barStyle = weaponScroll:GetVBar()
                barStyle:SetWide( adminFrame:GetWide() / 100 )
                function barStyle:Paint( w, h ) end
                function barStyle.btnUp:Paint( w, h ) end
                function barStyle.btnDown:Paint( w, h ) end
                function barStyle.btnGrip:Paint( w, h ) 
                    draw.RoundedBox( 2, w / 2, 0, w / 2, h, Color( 220, 220, 220, 255 ) )
                end

        local wHeightOffset = adminFrame:GetTall() / 4.5
        local wHeight = 0
        for k, v in pairs(configTable.weapons) do
            local wName = v.name
            local wAmmo = v.ammo
            local wEntity = v.entity
            local wModel = v.model
            local posX, posY, posZ = v.stencilPos.x, v.stencilPos.y, v.stencilPos.z
            local angPitch, angYaw, angRoll = v.stencilAng.pitch, v.stencilAng.yaw, v.stencilAng.roll

            local weaponFrame = vgui.Create("DFrame", weaponScroll)
            weaponFrame:SetPos(0, wHeight)
            weaponFrame:SetSize(adminFrame:GetWide() / 2.2, adminFrame:GetTall() / 5)
            weaponFrame:SetSizable( false )
            weaponFrame:SetDeleteOnClose( true )
            weaponFrame:ShowCloseButton( false )
            weaponFrame:SetTitle( "" )
            weaponFrame:SetDraggable( false )
            weaponFrame.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(220,220,220,255)) -- Background
                draw.SimpleTextOutlined(wName, "aarmoryFont", w / 4, h / 7, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                draw.SimpleText("Entity: " .. wEntity, "aarmoryFontGui", w / 50, h / 12, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("Ammo: " .. wAmmo, "aarmoryFontGui", w / 50, h / 1.08, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                draw.SimpleText("Pos: ", "aarmoryFontGuiBig", w / 4, h / 1.15, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("Ang: ", "aarmoryFontGuiBig", w / 1.7, h / 1.15, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            local wJobComboEntry = vgui.Create("DComboBox", weaponFrame)
                wJobComboEntry:SetPos(weaponFrame:GetWide() / 4, weaponFrame:GetTall() / 3.5)
                wJobComboEntry:SetSize(weaponFrame:GetWide() / 6, weaponFrame:GetTall() / 7)
                wJobComboEntry:SetText("Jobs")
                for a, b in pairs(v.restrictJob) do
                    if !b then
                        wJobComboEntry:AddChoice(a)
                    end
                end

            local wJobComboAllowed = vgui.Create("DComboBox", weaponFrame)
                wJobComboAllowed:SetPos(weaponFrame:GetWide() / 2.35, weaponFrame:GetTall() / 3.5)
                wJobComboAllowed:SetSize(weaponFrame:GetWide() / 6, weaponFrame:GetTall() / 7)
                wJobComboAllowed:SetText("Allowed")
                for a, b in pairs(v.restrictJob) do
                    if b then
                        wJobComboAllowed:AddChoice(a)
                    end
                end

            local wJobAddButton = vgui.Create("DButton", weaponFrame)
                wJobAddButton:SetPos(weaponFrame:GetWide() / 4, weaponFrame:GetTall() / 2.2)
                wJobAddButton:SetSize(weaponFrame:GetWide() / 6, weaponFrame:GetTall() / 7)
                wJobAddButton:SetTextColor( Color(255,255,255) )
                wJobAddButton:SetFont( "aarmoryFontGuiBig" )
                wJobAddButton:SetText("Add")
                wJobAddButton.DoClick = function()
                    local job = wJobComboEntry:GetSelected()
                    if job == nil then return end
                    v.restrictJob[job] = true
                    wJobComboEntry:Clear()
                    wJobComboEntry:SetText("Jobs")
                    for a, b in pairs(v.restrictJob) do
                        if !b then
                            wJobComboEntry:AddChoice(a)
                        end
                    end
                    wJobComboAllowed:Clear()
                    wJobComboAllowed:SetText("Allowed")
                    for a, b in pairs(v.restrictJob) do
                        if b then
                            wJobComboAllowed:AddChoice(a)
                        end
                    end
                end
                wJobAddButton.Paint = function(s, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(50,255,50,255))
                end

            local wJobRemoveButton = vgui.Create("DButton", weaponFrame)
                wJobRemoveButton:SetPos(weaponFrame:GetWide() / 2.35, weaponFrame:GetTall() / 2.2)
                wJobRemoveButton:SetSize(weaponFrame:GetWide() / 6, weaponFrame:GetTall() / 7)
                wJobRemoveButton:SetTextColor( Color(255,255,255) )
                wJobRemoveButton:SetFont( "aarmoryFontGuiBig" )
                wJobRemoveButton:SetText("Remove")
                wJobRemoveButton.DoClick = function()
                    local job = wJobComboAllowed:GetSelected()
                    if job == nil then return end
                    v.restrictJob[job] = false
                    wJobComboEntry:Clear()
                    wJobComboEntry:SetText("Jobs")
                    for a, b in pairs(v.restrictJob) do
                        if !b then
                            wJobComboEntry:AddChoice(a)
                        end
                    end
                    wJobComboAllowed:Clear()
                    wJobComboAllowed:SetText("Allowed")
                    for a, b in pairs(v.restrictJob) do
                        if b then
                            wJobComboAllowed:AddChoice(a)
                        end
                    end
                end
                wJobRemoveButton.Paint = function(s, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(255,50,50,255))
                end

            local wGroupTextEntry = vgui.Create("DTextEntry", weaponFrame)
                wGroupTextEntry:SetPos(weaponFrame:GetWide() / 1.65, weaponFrame:GetTall() / 3.5)
                wGroupTextEntry:SetSize(weaponFrame:GetWide() / 6, weaponFrame:GetTall() / 7)
                wGroupTextEntry:SetText("Groups")
                
            local wGroupComboAllowed = vgui.Create("DComboBox", weaponFrame)
                wGroupComboAllowed:SetPos(weaponFrame:GetWide() / 1.28, weaponFrame:GetTall() / 3.5)
                wGroupComboAllowed:SetSize(weaponFrame:GetWide() / 6, weaponFrame:GetTall() / 7)
                wGroupComboAllowed:SetText("Allowed")
                for a, b in pairs(v.restrictGroup) do
                    if b then
                        wGroupComboAllowed:AddChoice(a)
                    end
                end

            local wGroupAddButton = vgui.Create("DButton", weaponFrame)
                wGroupAddButton:SetPos(weaponFrame:GetWide() / 1.65, weaponFrame:GetTall() / 2.2)
                wGroupAddButton:SetSize(weaponFrame:GetWide() / 6, weaponFrame:GetTall() / 7)
                wGroupAddButton:SetTextColor( Color(255,255,255) )
                wGroupAddButton:SetFont( "aarmoryFontGuiBig" )
                wGroupAddButton:SetText("Add")
                wGroupAddButton.DoClick = function()
                    local group = wGroupTextEntry:GetValue()
                    if group == nil then return end
                    v.restrictGroup[group] = true
                    wGroupComboAllowed:Clear()
                    wGroupComboAllowed:SetText("Allowed")
                    for a, b in pairs(v.restrictGroup) do
                        if b then
                            wGroupComboAllowed:AddChoice(a)
                        end
                    end
                end
                wGroupAddButton.Paint = function(s, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(50,255,50,255))
                end
                
            local wGroupRemoveButton = vgui.Create("DButton", weaponFrame)
                wGroupRemoveButton:SetPos(weaponFrame:GetWide() / 1.28, weaponFrame:GetTall() / 2.2)
                wGroupRemoveButton:SetSize(weaponFrame:GetWide() / 6, weaponFrame:GetTall() / 7)
                wGroupRemoveButton:SetTextColor( Color(255,255,255) )
                wGroupRemoveButton:SetFont( "aarmoryFontGuiBig" )
                wGroupRemoveButton:SetText("Remove")
                wGroupRemoveButton.DoClick = function()
                    local group = wGroupComboAllowed:GetSelected()
                    if group == nil then return end
                    v.restrictGroup[group] = false
                    wGroupComboAllowed:Clear()
                    wGroupComboAllowed:SetText("Allowed")
                    for a, b in pairs(v.restrictGroup) do
                        if b then
                            wGroupComboAllowed:AddChoice(a)
                        end
                    end
                end
                wGroupRemoveButton.Paint = function(s, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(255,50,50,255))
                end

            local wAmmoTextEntry = vgui.Create("DTextEntry", weaponFrame)
                wAmmoTextEntry:SetPos(weaponFrame:GetWide() / 4, weaponFrame:GetTall() / 1.6)
                wAmmoTextEntry:SetSize(weaponFrame:GetWide() / 4.5, weaponFrame:GetTall() / 7)
                wAmmoTextEntry:SetText("Ammo Amount")
                wAmmoTextEntry.OnChange = function()
                    local ammoAmount = wAmmoTextEntry:GetValue()
                    v.ammoAmount = ammoAmount
                end 
            
            local wShipmentTextEntry = vgui.Create("DTextEntry", weaponFrame)
                wShipmentTextEntry:SetPos(weaponFrame:GetWide() / 2.05, weaponFrame:GetTall() / 1.6)
                wShipmentTextEntry:SetSize(weaponFrame:GetWide() / 4.5, weaponFrame:GetTall() / 7)
                wShipmentTextEntry:SetText("Shipment Amount")
                wShipmentTextEntry.OnChange = function()
                    local shipmentAmount = wShipmentTextEntry:GetValue()
                    v.shipmentAmount = shipmentAmount
                end 

            local wPosX = vgui.Create("DTextEntry", weaponFrame)
                wPosX:SetPos(weaponFrame:GetWide() / 3.2, weaponFrame:GetTall() / 1.22)
                wPosX:SetSize(weaponFrame:GetWide() / 12, weaponFrame:GetTall() / 8)
                wPosX:SetText(posX)

            local wPosY = vgui.Create("DTextEntry", weaponFrame)
                wPosY:SetPos(weaponFrame:GetWide() / 2.5, weaponFrame:GetTall() / 1.22)
                wPosY:SetSize(weaponFrame:GetWide() / 12, weaponFrame:GetTall() / 8)
                wPosY:SetText(posY)
            
            local wPosZ = vgui.Create("DTextEntry", weaponFrame)
                wPosZ:SetPos(weaponFrame:GetWide() / 2.055, weaponFrame:GetTall() / 1.22)
                wPosZ:SetSize(weaponFrame:GetWide() / 12, weaponFrame:GetTall() / 8)
                wPosZ:SetText(posZ)

            local wAngPitch = vgui.Create("DTextEntry", weaponFrame)
                wAngPitch:SetPos(weaponFrame:GetWide() / 1.52, weaponFrame:GetTall() / 1.22)
                wAngPitch:SetSize(weaponFrame:GetWide() / 12, weaponFrame:GetTall() / 8)
                wAngPitch:SetText(angPitch)

            local wAngYaw = vgui.Create("DTextEntry", weaponFrame)
                wAngYaw:SetPos(weaponFrame:GetWide() / 1.34, weaponFrame:GetTall() / 1.22)
                wAngYaw:SetSize(weaponFrame:GetWide() / 12, weaponFrame:GetTall() / 8)
                wAngYaw:SetText(angYaw)
            
            local wAngRoll = vgui.Create("DTextEntry", weaponFrame)
                wAngRoll:SetPos(weaponFrame:GetWide() / 1.2, weaponFrame:GetTall() / 1.22)
                wAngRoll:SetSize(weaponFrame:GetWide() / 12, weaponFrame:GetTall() / 8)
                wAngRoll:SetText(angRoll)

            wPosX.OnChange = function()
                posX = tonumber(wPosX:GetValue())
                v.stencilPos = Vector(posX, posY, posZ)
            end
            wPosY.OnChange = function()
                posY = tonumber(wPosY:GetValue())
                v.stencilPos = Vector(posX, posY, posZ)
            end
            wPosZ.OnChange = function()
                posZ = tonumber(wPosZ:GetValue())
                v.stencilPos = Vector(posX, posY, posZ)
            end

            wAngPitch.OnChange = function()
                angPitch = tonumber(wAngPitch:GetValue())
                v.stencilAng = Angle(angPitch, angYaw, angRoll)
            end
            wAngYaw.OnChange = function()
                angYaw = tonumber(wAngYaw:GetValue())
                v.stencilAng = Angle(angPitch, angYaw, angRoll)
            end
            wAngRoll.OnChange = function()
                angRoll = tonumber(wAngRoll:GetValue())
                v.stencilAng = Angle(angPitch, angYaw, angRoll)
            end

            local wColor = Color(50,255,50,255)
            local wButton = vgui.Create("DButton", weaponFrame)
                wButton:SetPos(weaponFrame:GetWide() / 1.37, weaponFrame:GetTall() / 1.6)
                wButton:SetSize(weaponFrame:GetWide() / 4.5, weaponFrame:GetTall() / 7)
                wButton:SetTextColor( Color(255,255,255) )
                wButton:SetFont( "aarmoryFontGuiBig" )
                wButton.DoClick = function()
                    v.useWeapon = !v.useWeapon
                end
                wButton.Think = function()
                    if v.useWeapon then
                        wColor = Color(50, 255, 50, 255)
                        wButton:SetText("Enabled")
                    else
                        wColor = Color(255, 50, 50, 255)
                        wButton:SetText("Disabled")
                    end
                end
                wButton.Paint = function(s, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, wColor)
                end

            local modelFrame = vgui.Create("DFrame", weaponFrame)
                modelFrame:SetPos(weaponFrame:GetWide() / 50, weaponFrame:GetTall() / 6)
                modelFrame:SetSize(weaponFrame:GetWide() / 5, weaponFrame:GetTall() / 1.5)
                modelFrame:SetSizable( false )
                modelFrame:SetDeleteOnClose( true )
                modelFrame:ShowCloseButton( false )
                modelFrame:SetTitle( "" )
                modelFrame:SetDraggable( false )
                modelFrame.Paint = function(s, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, Color(200,200,200,255)) -- Background
                end

            local weaponModelAdmin = vgui.Create( "DModelPanel", modelFrame ) -- Pretty sure I got most of this from either a wiki or a youtube video
                weaponModelAdmin:SetPos( 0, 0 )
                weaponModelAdmin:SetSize( modelFrame:GetWide(), modelFrame:GetTall() )
                weaponModelAdmin:SetModel( wModel )
                function weaponModelAdmin:LayoutEntity( Entity ) return end
                local mn, mx = weaponModelAdmin.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
                size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
                size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )
                weaponModelAdmin:SetFOV( 40 )
                weaponModelAdmin:SetCamPos( Vector(
                size - 0,
                size + 0,
                size
                )
                )
                weaponModelAdmin:SetLookAt((mn + mx) * 0.5)

            wHeight = wHeight + wHeightOffset
        end

        local adminCloseButton = vgui.Create( "DButton", adminFrame )
            adminCloseButton:SetPos( adminFrame:GetWide() / 4, adminFrame:GetTall() / 1.18 )
            adminCloseButton:SetSize( (adminFrame:GetWide() / 3) / 1.5, adminFrame:GetTall() / 10 )
            adminCloseButton:SetTextColor( Color(255,255,255) )
            adminCloseButton:SetFont( "aarmoryFont" )
            adminCloseButton:SetText( AARMORY.Localise.armory.closeButton )
            adminCloseButton.DoClick = function() adminFrame:Close() end
            adminCloseButton.Paint = function( s, w, h )
                draw.RoundedBox( 6, 0, 0, w, h, Color( 100,100,255,255 ) )
            end

            local adminRemoveButton = vgui.Create( "DButton", adminFrame )
                adminRemoveButton:SetPos( adminFrame:GetWide() / 1.9, adminFrame:GetTall() / 1.1 )
                adminRemoveButton:SetSize( (adminFrame:GetWide() / 3) / 1.5, ( adminFrame:GetTall() / 10 ) / 2 )
                adminRemoveButton:SetTextColor( Color(255,255,255) )
                adminRemoveButton:SetFont( "aarmoryFont" )
                adminRemoveButton:SetText( "Remove from Map" )
                adminRemoveButton.DoClick = function()
                    net.Start("sendConfig")
                        net.WriteTable(configTable)
                        net.WriteBool(true)
                        net.WriteEntity(ent)
                    net.SendToServer()
                    adminFrame:Close() 
                end
                adminRemoveButton.Paint = function( s, w, h )
                    draw.RoundedBox( 6, 0, 0, w, h, Color( 255,50,50,255 ) )
                end

            local adminSaveButton = vgui.Create( "DButton", adminFrame )
                adminSaveButton:SetPos( adminFrame:GetWide() / 1.9, adminFrame:GetTall() / 1.18 )
                adminSaveButton:SetSize( (adminFrame:GetWide() / 3) / 1.5, ( adminFrame:GetTall() / 10 ) / 2 )
                adminSaveButton:SetTextColor( Color(255,255,255) )
                adminSaveButton:SetFont( "aarmoryFont" )
                adminSaveButton:SetText( "Save to Map" )
                adminSaveButton.DoClick = function()
                    net.Start("sendConfig")
                        net.WriteTable(configTable)
                        net.WriteBool(false)
                        net.WriteEntity(ent)
                    net.SendToServer()
                    adminFrame:Close() 
                end
                adminSaveButton.Paint = function( s, w, h )
                    draw.RoundedBox( 6, 0, 0, w, h, Color( 50,255,50,255 ) )
                end
                
    else

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

            draw.SimpleTextOutlined(AARMORY.Localise.armory.policeArmory, "aarmoryFont", w / 2, h / 40, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0,0,0,255))
        end

        local closeButton = vgui.Create( "DButton", frame )
            closeButton:SetPos( frame:GetWide() / 3, frame:GetTall() / 1.18 )
            closeButton:SetSize( frame:GetWide() / 3, frame:GetTall() / 10 )
            closeButton:SetTextColor( Color(255,255,255) )
            closeButton:SetFont( "aarmoryFont" )
            closeButton:SetText( AARMORY.Localise.armory.closeButton )
            closeButton.DoClick = function() frame:Close() end
            closeButton.Paint = function( s, w, h )
                draw.RoundedBox( 6, 0, 0, w, h, Color( 100,100,255,255 ) )
            end
        
        local weaponListPanelBase = vgui.Create( "DPanel", frame )
            weaponListPanelBase:SetPos( frame:GetWide() / 44, frame:GetTall() / 12.5 )
            weaponListPanelBase:SetSize( frame:GetWide() - ( frame:GetWide() / 22 ), frame:GetTall() / 1.4 )
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
        for k, v in pairs(configTable.weapons) do
            if v.useWeapon then
                local wName = v.name
                local wAmmo = v.ammo
                local wModel = v.model

                local giveAmmo = false
                if ply:HasWeapon(k) then
                    giveAmmo = true
                end

                local weaponListPanel = weaponListScroll:Add( "DFrame" )
                    weaponListPanel:SetPos( frame:GetWide() / 32, pHeight )
                    weaponListPanel:SetSize( frame:GetWide() - ( frame:GetWide() / 10 ), frame:GetTall() / 8 )
                    weaponListPanel:SetSizable( false )
                    weaponListPanel:ShowCloseButton( false )
                    weaponListPanel:SetTitle( "" )
                    weaponListPanel:SetDraggable( false )
                    weaponListPanel.Paint = function( s, w, h )
                        draw.RoundedBox( 10, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
                        draw.SimpleTextOutlined(wName, "aarmoryFont", w / 5, h / 16, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0,0,0,255))
                        draw.SimpleTextOutlined(wAmmo, "aarmoryFontGuiBig", w / 4.9, h / 2.5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0,0,0,255))
                    end

                local weaponButton = vgui.Create( "DButton", weaponListPanel )
                    weaponButton:SetPos( weaponListPanel:GetWide() / 5, weaponListPanel:GetTall() / 1.5 )
                    weaponButton:SetSize( weaponListPanel:GetWide() / 3.5, weaponListPanel:GetTall() / 3.5 )
                    weaponButton:SetText( "" )
                    weaponButton.Paint = function( s, w, h )
                        draw.RoundedBox(10, 0, 0, w, h, Color(50,255,50))
                        if giveAmmo then
                            draw.SimpleText( AARMORY.Localise.armory.equipAmmoButton, "aarmoryFontGuiBig", w / 2, h / 2, Color( 255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        else
                            draw.SimpleText( AARMORY.Localise.armory.equipButton, "aarmoryFontGuiBig", w / 2, h / 2, Color( 255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                    end
                    weaponButton.DoClick = function()

                        net.Start( "aarmoryGive" )
                            net.WriteString( k )
                            net.WriteBool( giveAmmo )
                            net.WriteInt(ent:GetaarmoryID(), 12)
                        net.SendToServer()
                    
                        if !giveAmmo then
                            frame:Close()
                        end

                    end

                local weaponModelPanel = vgui.Create( "DPanel", weaponListPanel )
                    weaponModelPanel:SetPos( weaponListPanel:GetWide() / 70, weaponListPanel:GetTall() / 16 )
                    weaponModelPanel:SetSize( weaponListPanel:GetWide() / 6, weaponListPanel:GetTall() / 1.1 )
                    weaponModelPanel.Paint = function( s, w, h )
                        draw.RoundedBox( 10, 0, 0, w, h, Color( 210, 210, 210, 255 ) )
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
    end

end)

local function drawStencil()
    for k, v in pairs(ents.FindByClass("aarmory_ent")) do
        local ent = v
        if clientConfig[ent:GetaarmoryID()] != nil and !table.IsEmpty(clientConfig) then
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
            for k, v in SortedPairs(clientConfig[ent:GetaarmoryID()].weapons) do
                open[k .. tostring(ent)] = ent:GetNWBool("open" .. k .. tostring(ent))
                cooldown[k .. tostring(ent)] = ent:GetNWBool("cooldown" .. k .. tostring(ent))
            end

            cam.Start3D2D(pos, ang, 0.02)
                local offset = 0
                for k, v in SortedPairs(clientConfig[ent:GetaarmoryID()].weapons) do
                    if cooldown[k .. tostring(ent)] then
                        draw.SimpleText(AARMORY.Localise.armory.restocking, "aarmoryFontBig", 290 + offset, 150, Color(255,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                    end
                    draw.SimpleText(v.name, "aarmoryFontBig", 290 + offset, 30, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
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
                        for k, v in SortedPairs(clientConfig[ent:GetaarmoryID()].weapons) do
                            if open[k .. tostring(ent)] then
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
                        for k, v in SortedPairs(clientConfig[ent:GetaarmoryID()].weapons) do
                            local offsetPitch, offsetYaw, offsetRoll = v.stencilAng.pitch or 0, v.stencilAng.yaw or 0, v.stencilAng.roll or 0
                            local offsetX, offsetY, offsetZ = v.stencilPos.x or 0, v.stencilPos.y or 0, v.stencilPos.z or 0
                            
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
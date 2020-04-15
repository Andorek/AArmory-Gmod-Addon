include( "shared.lua" )


surface.CreateFont( "aarmorySawFont", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 60,
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

surface.CreateFont( "aarmorySawFontSmall", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 35,
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

surface.CreateFont( "aarmorySawFontTiny", {
    font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 21,
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

    ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Right(), 30)
    ang:RotateAroundAxis(ang:Forward(), 10)
    ang:RotateAroundAxis(ang:Up(), 180)
    pos = self:GetPos() + (ang:Right() * -3) + ( ang:Up() * 13 ) + ( ang:Forward() * -8 )

    cam.Start3D2D(pos, ang, 0.02)
    surface.SetDrawColor(255, 255, 255, 255)
        draw.RoundedBox(50, 0, 0, 400, 300, Color(0,0,0,200))
        draw.SimpleText("SawOS", "aarmorySawFont", 200, 10, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText("For all your armory raiding needs...", "aarmorySawFontTiny", 200, 80, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        draw.RoundedBox(20, 50, 130, 300, 100, Color(255,255,255,200))

        if self:GetrobTimer() > 0.3 then -- Networked timer doesn't reach zero, only gets close
            draw.RoundedBox(20, 60, 140, Lerp(self:GetrobTimer() / AARMORY.Settings.robTime, 280, 0), 80, Color(255,255,0,255))
            draw.SimpleTextOutlined("Status: RUNNING", "aarmorySawFontSmall", 200, 160, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 4, Color(0,0,0,255))
        else
            draw.SimpleTextOutlined("Status: IDLE", "aarmorySawFontSmall", 200, 160, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 4, Color(0,0,0,255))
        end

    cam.End3D2D()
end

function ENT:Think()
end
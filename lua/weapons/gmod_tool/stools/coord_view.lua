TOOL.Category = "Koshmarov"
TOOL.Name = "#Coords viewer."

if SERVER then return end

function TOOL:LeftClick(trace)
	if self.Blocked then return end
	timer.Simple(.1, function() self.Blocked = nil end)
	self.Blocked = true

	if IsValid(self.SelectedEntity) then
		chat.AddText(tostring(self.RelativePosToEntity))
		return false
	end

	if (not IsValid(trace.Entity)) and (not trace.Entity:IsValid()) then return end

	self.SelectedEntity = trace.Entity

	hook.Add("PostDrawOpaqueRenderables", "CoordsDraw", function() self:PostDrawOpaqueRenderables() end)
	return false
end

function TOOL:RightClick(trace)
	self.SelectedEntity = nil
	hook.Remove(
		"PostDrawOpaqueRenderables", "CoordsDraw")
end

function TOOL:Think()
	if not IsValid(self.SelectedEntity) or not self.SelectedEntity:IsValid() then return end
	local tr = LocalPlayer():GetEyeTrace()

	self.RelativePosToEntity = self.SelectedEntity:WorldToLocal(tr.HitPos)
	self.HitPos = tr.HitPos
	self.HitNormal = tr.HitNormal
end

function TOOL:DrawHUD() end

local LineColor = Color(255, 255, 0, 255)

local function _DrawXYZ(ent, size)
	local X, Y, Z =
		Vector(1, 0, 0), Vector(0, 1, 0), Vector(0, 0, 1)
	local size = (size or 15)
	for i, v in ipairs({X, Y, Z}) do
		local StartPos = ent:LocalToWorld(v * size)
		local EndPos = ent:LocalToWorld(v * size * -1)
		local Color = Color(v.x * 255, v.y * 255, v.z * 255, 255)
		render.DrawLine(StartPos, EndPos, Color, true)
	end
end

local function _DrawHitNormal(ent, hitpos, hitnormal)
	render.DrawQuadEasy(hitpos + hitnormal, hitnormal, 8, 8, LineColor)
	render.DrawLine(hitpos, hitpos + hitnormal * 16, LineColor)
end

function TOOL:PostDrawOpaqueRenderables()
	if (not IsValid(self.SelectedEntity)) or (not self.SelectedEntity:IsValid()) then return end
	if not self.HitPos then return end
	local ent = self.SelectedEntity
	render.DrawWireframeBox( ent:GetPos(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs(), Color(155,155,0), true)
	render.DrawLine(ent:GetPos(), self.HitPos, LineColor)
	_DrawXYZ(ent, 55)
	_DrawHitNormal(ent, self.HitPos, self.HitNormal)
end

surface.CreateFont( "CustomFont1", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 48,
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

local tcols = {
	["x"] = Color(255, 0, 0),
	["y"] = Color(0, 255, 0),
	["z"] = Color(0, 0, 255),
}

function TOOL:DrawToolScreen(w, h)
	surface.SetFont("CustomFont1")

	if not IsValid(self.SelectedEntity) then 
		surface.SetTextPos(10, h/2 - 30)
		surface.SetTextColor(Color(255,255,255))
		surface.DrawText("NO_ENTITY")
		return 
	end
	surface.SetTextColor(Color(255,0,0,255))

	local pos = self.RelativePosToEntity
	for i, v in ipairs({"x", "y", "z"}) do
		local col = tcols[v]
		surface.SetTextColor(col)
		surface.SetTextPos(5, i * 40 + 10)
		surface.DrawText(("%s:%f"):format(v, pos[v]))
	end

	surface.SetTextColor(Color(255,255,0))
	surface.SetTextPos(5, 130 + 45)
	surface.DrawText(self.SelectedEntity:GetClass())
end
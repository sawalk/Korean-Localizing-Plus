local mod = RegisterMod("Repentance Korean", 1)
local SubSprite = Sprite()
local VoiceSFX = SFXManager()
SubSprite:Load("gfx/cutscenes/backwards.anm2", true)
local function GetScreenSize()
    local pos =  Game():GetRoom():WorldToScreenPosition(Vector(0,0)) -  Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset
    
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 162.5 * (26 / 40)
    
    return Vector(rx*2 + 13*26, ry*2 + 7*26)
end
function RenderSub(Anm2)
	SubSprite:Play(Anm2)
	SubSprite:Update()
	SubSprite.Scale = Vector(1, 1)
	SubSprite.Color = Color(1, 1, 1, 0.6, 0, 0, 0)
	SubSprite:Render(Vector(GetScreenSize().X/2, GetScreenSize().Y*0.85), Vector(0,0), Vector(0,0))
end

mod.isVisible = true
mod.IsHidden = false
local function onRender()
	mod.isVisible = false
	if Input.IsButtonTriggered(39, 0) then
		mod.IsHidden = not mod.IsHidden
	end
	if mod.IsHidden then
		return
	end
	if VoiceSFX:IsPlaying(598) then
		RenderSub("backwards1")
	elseif VoiceSFX:IsPlaying(599) then
		RenderSub("backwards2")
	elseif VoiceSFX:IsPlaying(600) then
		RenderSub("backwards3")
	elseif VoiceSFX:IsPlaying(601) then
		RenderSub("backwards4")
	end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)
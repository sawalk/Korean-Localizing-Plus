local mod = RegisterMod("　", 1)
local game = Game()
local SubSprite = Sprite()
local VoiceSFX = SFXManager()
SubSprite:Load("gfx/cutscenes/backwards.anm2", true)

Isaac.ConsoleOutput("Korean Localizing Plus loaded.\n")

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

-- {itemId, 'name', 'desc'}
local items = {
    --$$$ITEMS-START$$$
    {337, "부서진 시계", "망가진 것 같다"},
    {354, "식품 완구", "체력 증가. 상품까지 먹지는 마세요!"},
    {355, "엄마의 진주", "사거리 + 행운 증가"},
    {341, "찢어진 사진", "공격 속도, 투사체 속도 증가"},
    {371, "탑의 저주", "저주받은 느낌이야…"},
    {373, "명사수", "정확함은 힘을 가져다주지!"},
    {382, "프렌들리 볼", "넌 내 거야!"},
    {396, "심실 절단기", "숏컷 생성기"},
    {411, "욕망의 피", "그들의 피가 분노를 가져오리니!"},
    {444, "연필", "놈은 피를 흘린다"},
    {447, "납작한 콩", "난 울 때마다…잇몸이 시리다…"},
    {461, "기생충", "알까기 눈물"},
    {467, "손가락!", "어딜 만져! 어딜 만지냐고!"},
    {476, "1면 주사위", "무엇이 나올까?"},
    {477, "공허", "먹어 치운다"},
    {489, "무한 주사위", "영원히 리롤"},
    {495, "유령 고추", "화염의 눈물"},
    {499, "성찬", "무운을 빌지"},
    {502, "커다란 여드름", "여드름 눈물"},
    {507, "날카로운 빨대", "좀 더 피를 줘!"},
    {519, "작은 섬망", "기뻐 날뛰는 친구"},
    {555, "황금 면도날", "고통의 보람"},
    {556, "황", "일시적 악마 형상"},
    {625, "대왕 버섯", "나도 이제 큰 형아야!"},
    {709, "수플렉스!", "천사도 이길 기술"},
    {725, "과민성 대장 증후군", "뱃속이 꾸물거린다"},
    --{729, "참수 공격", "머리 받아라!"},
}
  
local trinkets = {
    --$$$TRINKETS-START$$$
    {145, "올백", "행운 수직 상승. 그 행운을 잃지 말라구!"},
}

if EID then
    -- Adds trinkets defined in trinkets
    for _, trinket in ipairs(trinkets) do
        local EIDdescription = EID:getDescriptionObj(5, 350, trinket[1]).Description
        EID:addTrinket(trinket[1], EIDdescription, trinket[2], "en_us")
    end

    -- Adds items defined in items
    for _, item in ipairs(items) do
        local EIDdescription = EID:getDescriptionObj(5, 100, item[1]).Description
        EID:addCollectible(item[1], EIDdescription, item[2], "en_us")
    end
end

if Encyclopedia then
    -- Adds trinkets defined in trinkets
    for _,trinket in ipairs(trinkets) do
        Encyclopedia.UpdateTrinket(trinket[1], {
            Name = trinket[2],
            Description = trinket[3],
        })
    end
    
    -- Adds items defined in items
    for _, item in ipairs(items) do
        Encyclopedia.UpdateItem(item[1], {
            Name = item[2],
            Description = item[3],
        })
    end
end

-- Handle displaying trinket names
if #trinkets ~= 0 then
    local t_queueLastFrame
    local t_queueNow
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
        t_queueNow = player.QueuedItem.Item
        if (t_queueNow ~= nil) then
            for _, trinket in ipairs(trinkets) do
                if (t_queueNow.ID == trinket[1] and t_queueNow:IsTrinket() and t_queueLastFrame == nil) then
                    game:GetHUD():ShowItemText(trinket[2], trinket[3])
                end
            end
        end
        t_queueLastFrame = t_queueNow
    end)
end

-- Handle displaying item names
if #items ~= 0 then
    local i_queueLastFrame
    local i_queueNow
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
        i_queueNow = player.QueuedItem.Item
        if (i_queueNow ~= nil) then
            for _, item in ipairs(items) do
                if (i_queueNow.ID == item[1] and i_queueNow:IsCollectible() and i_queueLastFrame == nil) then
                    game:GetHUD():ShowItemText(item[2], item[3])
                end
            end
        end
        i_queueLastFrame = i_queueNow
    end)
end

local pillFiles = {
    [PillEffect.PILLEFFECT_TEARS_UP] = "gfx/ui/KLP_TearsUP.anm2",
    [PillEffect.PILLEFFECT_TEARS_DOWN] = "gfx/ui/KLP_TearsDown.anm2",
    [PillEffect.PILLEFFECT_SHOT_SPEED_UP] = "gfx/ui/KLP_ShotSpeedUp.anm2",
    [PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = "gfx/ui/KLP_ShotSpeedDown.anm2"
}

local pillAnimations = {
    [PillEffect.PILLEFFECT_TEARS_UP] = "Tears_Up",
    [PillEffect.PILLEFFECT_TEARS_DOWN] = "Tears_Down",
    [PillEffect.PILLEFFECT_SHOT_SPEED_UP] = "Shot_Speed_Up",
    [PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = "Shot_Speed_Down"
}

local currentPillSprite = nil
local pillUsedEffects = {}

function mod:isJacobAndEsau(player)
    return player:GetPlayerType() == PlayerType.PLAYER_JACOB or player:GetPlayerType() == PlayerType.PLAYER_ESAU
end

function mod:onUpdate()
    local player = Isaac.GetPlayer(0)
    local activePillColor = player:GetPill(0)
    
    -- Check PHD and False PHD
    local hasPHD = player:HasCollectible(CollectibleType.COLLECTIBLE_PHD)
    local hasFalsePHD = player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD)

    if activePillColor ~= PillColor.PILL_NULL then
        local activePillEffect = game:GetItemPool():GetPillEffect(activePillColor)
        local pillAnimation = pillAnimations[activePillEffect]
        
        if pillAnimation and (pillUsedEffects[activePillEffect] or hasPHD or hasFalsePHD) then
            if not currentPillSprite or not currentPillSprite:IsPlaying(pillAnimation) then
                currentPillSprite = Sprite()
                currentPillSprite:Load(pillFiles[activePillEffect], true)
                currentPillSprite:Play(pillAnimation, true)
            end
        else
            currentPillSprite = nil
        end
    else
        currentPillSprite = nil
    end
end

function mod:onRender()
    if currentPillSprite then
        local player = Isaac.GetPlayer(0)
        local screenWidth = Isaac.GetScreenWidth()
        local screenHeight = Isaac.GetScreenHeight()
        local renderPosition

        -- Get HUD offset
        local hudOffset = Options.HUDOffset
        local offsetX, offsetY

        if mod:isJacobAndEsau(player) then
            offsetX = 93 + hudOffset * 20 -- X offset
            offsetY = 33 + hudOffset * 12 -- Y offset
            renderPosition = Vector(offsetX, offsetY)
        else
            offsetX = -125 - hudOffset * 16 -- X offset
            offsetY = -20 - hudOffset * 6 -- Y offset
            renderPosition = Vector(screenWidth + offsetX, screenHeight + offsetY)
        end

        currentPillSprite:Render(renderPosition, Vector(0, 0), Vector(0, 0))
    end
end

function mod:onGameStart(isContinued)
    currentPillSprite = nil
    pillUsedEffects = {}
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onGameStart)

local pillNames = {
    [PillEffect.PILLEFFECT_TEARS_DOWN] = "공격 속도 감소",
    [PillEffect.PILLEFFECT_TEARS_UP] = "공격 속도 증가",
    [PillEffect.PILLEFFECT_X_LAX] = "설사약",
    [PillEffect.PILLEFFECT_HORF] = "퉤엣!",
    [PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = "투사체 속도 감소",
    [PillEffect.PILLEFFECT_SHOT_SPEED_UP] = "투사체 속도 증가",
}

local json = require("json")

function mod:onEvaluatePill(pillEffect)
    local player = Isaac.GetPlayer(0)
    local pillName = pillNames[pillEffect]
    if pillName then
        game:GetHUD():ShowItemText(pillName)
    end

    if pillFiles[pillEffect] and pillAnimations[pillEffect] then
        currentPillSprite = Sprite()
        currentPillSprite:Load(pillFiles[pillEffect], true)
        currentPillSprite:Play(pillAnimations[pillEffect], true)
    else
        currentPillSprite = nil
    end
    
    pillUsedEffects[pillEffect] = true
end

mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.onEvaluatePill)
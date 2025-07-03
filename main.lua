local mod = RegisterMod("Korean Localizing Plus", 1)
KoreanLocalizingPlus = mod

------ 경고 메시지 ------
mod.repplus = REPENTANCE_PLUS or FontRenderSettings ~= nil
local notKorean = Options.Language ~= "kr"
local function checkLanguage()
    if notKorean and not mod.repplus then
        print("\n\n[Korean Localizing Plus]\nPlaying in a language other than Korean is not recommended!\nPlease turn off the Korean Localizing Plus,\nset the language to Korean,\nand turn the Korean Localizing Plus back on.\n")
    end
end

local function GetScreenSize()
    local pos = Game():GetRoom():WorldToScreenPosition(Vector(0,0)) - Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset
  
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 162.5 * (26 / 40)
  
    return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

local sprite = Sprite()
if notKorean or mod.repplus then
    sprite:Load("gfx/ui/popup_warning.anm2", true)   -- 경고 팝업 로드
elseif KoreanFontChange then
    sprite:Load("gfx/cutscenes/backwards_kfc.anm2", true)   -- 아빠의 쪽지 자막 로드(한국어 폰트 변경)
else
    sprite:Load("gfx/cutscenes/backwards.anm2", true)   -- 아빠의 쪽지 자막 로드
end

function RenderSub(Anm2)
    sprite:Play(Anm2)
    sprite:Update()
    sprite.Scale = Vector(1, 1)
    if mod.repplus or notKorean then
        sprite.Color = Color(1, 1, 1, 1, 0, 0, 0)
        sprite:Render(Vector(GetScreenSize().X/1.96, GetScreenSize().Y/2.2), Vector(0,0), Vector(0,0))
    else
        sprite.Color = Color(1, 1, 1, 0.6, 0, 0, 0)
        sprite:Render(Vector(GetScreenSize().X/2, GetScreenSize().Y*0.85), Vector(0,0), Vector(0,0))
    end
end

local showAnm2 = false
local renderingTime = 15
local DisplayedTime = 0
local function updateAnm2()
    if mod.repplus or notKorean then
        DisplayedTime = DisplayedTime + 1
        if DisplayedTime >= renderingTime then
            showAnm2 = true
        end
    end
end

local function renderAnm2()
    if showAnm2 then
        if notKorean and not mod.repplus then
            RenderSub("notKorean")
        else
            RenderSub("runningRep+")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, checkLanguage)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, updateAnm2)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderAnm2)


------ 아빠의 쪽지 자막 by blackcreamtea ------
local function GetScreenSize()
    local pos = Game():GetRoom():WorldToScreenPosition(Vector(0,0)) - Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset

    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 162.5 * (26 / 40)

    return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

mod.isVisible = true
mod.IsHidden = false

local VoiceSFX = SFXManager()
local function onRender()
    if Input.IsButtonTriggered(39, 0) then
        mod.IsHidden = not mod.IsHidden
    end
    if mod.IsHidden then return end

    for i = 598, 601 do
        if KoreanVoiceDubbing then
            if VoiceSFX:IsPlaying(Isaac.GetSoundIdByName("DADS_NOTE_KOREAN_" .. (i - 597))) then
                RenderSub("backwards" .. (i - 597))
            end
        else
            if VoiceSFX:IsPlaying(i) then
                RenderSub("backwards" .. (i - 597))
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)


------ EZITEMS by ddeeddii ------
local game = Game()
local data = include('include.data')
local json = require('json')
local jsonData = json.decode(data)

local changes = {
    items = {},
    trinkets = {}
}

if not EZITEMS then
    EZITEMS = {}

    EZITEMS.items = {}
    EZITEMS.trinkets = {}
    EZITEMS.cards = {}
    EZITEMS.pills = {}
end

local function addItem(id, name, description, type)
    if not EZITEMS[type][tostring(id)] then
        EZITEMS[type][tostring(id)] = {}
    end

    table.insert(EZITEMS[type][tostring(id)], {name = name, description = description, mod = mod.Name, modTemplate = 'vanilla'})
    changes[type][tostring(id)] = {name = name, description = description}
end

local getterFunctions = {
    items = Isaac.GetItemIdByName,
    trinkets = Isaac.GetTrinketIdByName,
}
local function parseJsonData()
    for itemType, root in pairs(jsonData) do
        for itemId, item in pairs(root) do
            if itemType == 'metadata' then
                goto continue
            end

            local trueId = itemId

            if tonumber(itemId) == nil then
                trueId = getterFunctions[itemType](itemId)
                if trueId ~= -1 then
                    addItem(trueId, item.name, item.description, itemType)
                else
                    print('[ EzTools | ' .. tostring(mod.Name) .. ']' .. itemType .. ' "' .. tostring(itemId) .. '" not found, skipping custom name/description...')
                end
            else
                addItem(trueId, item.name, item.description, itemType)
            end

            ::continue::
        end
    end
end

local itemVariants = {
    items = 100,
    trinkets = 350
}

local function checkConflicts()
    for type, itemTypeData in pairs(changes) do
        for id, itemData in pairs(itemTypeData) do
            if EZITEMS[type][tostring(id)] then
                local removeOwn = false
                for idx, conflict in ipairs(EZITEMS[type][tostring(id)]) do
                    if conflict.mod ~= mod.Name then
                        print('')
                        print('[ ' .. tostring(mod.Name) .. ' ]')
                        print('[ EzTools Conflict ] Item (type "' .. type .. '") with id "' .. tostring(id) .. '" (name: "' .. itemData.name .. '") is already in use by mod "' .. conflict.mod .. '"')
                        print('[ EzTools Conflict ] Mod "' .. conflict.mod .. '" has higher priority, so "' .. mod.Name .. '"\'s item will not be loaded')
                        print('[ EzTools Conflict ] Summary: (' .. itemData.name .. ') -> (' .. conflict.name .. ')')
                        print('')

                        changes[type][tostring(id)] = nil
                        removeOwn = true
                        conflict.resolved = true
                    elseif conflict.mod == mod.Name and removeOwn then
                        EZITEMS[type][tostring(id)][idx] = nil
                        removeOwn = false
                    end
                end
            end
        end
    end
end

parseJsonData()
checkConflicts()

if next(changes.trinkets) ~= nil then
    local t_queueLastFrame = {}
    local t_queueNow = {}
    mod:AddCallback(
        ModCallbacks.MC_POST_PLAYER_UPDATE,
 
        ---@param player EntityPlayer
        function(_, player)
            local playerKey = tostring(player.InitSeed)
            
            t_queueNow[playerKey] = player.QueuedItem.Item
            if (t_queueNow[playerKey] ~= nil) then
                local trinket = changes.trinkets[tostring(t_queueNow[playerKey].ID)]
                if trinket and t_queueNow[playerKey]:IsTrinket() and t_queueLastFrame[playerKey] == nil and not REPENTOGON then
                    game:GetHUD():ShowItemText(trinket.name, trinket.description)
                end
            end
            t_queueLastFrame[playerKey] = t_queueNow[playerKey]
        end
    )
end
 
if next(changes.items) ~= nil then
    local i_queueLastFrame = {}
    local i_queueNow = {}

    local gFuelDesc = include('include.data_gFuelDesc')
    local birthrightDesc = include("include.data_birthrightDesc")
    
    mod:AddCallback(
        ModCallbacks.MC_POST_PLAYER_UPDATE,

        ---@param player EntityPlayer
        function(_, player)
            local playerKey = tostring(player.InitSeed)
            
            i_queueNow[playerKey] = player.QueuedItem.Item
            if i_queueNow[playerKey] and i_queueNow[playerKey]:IsCollectible() and i_queueLastFrame[playerKey] == nil then
                local itemID = i_queueNow[playerKey].ID
                if itemID == -1 then   -- G FUEL!
                    local g_random = math.random(1, 50)
                    local g_description = gFuelDesc[g_random]
                    if g_description then
                        Game():GetHUD():ShowItemText("G FUEL!", g_description or "일종의 오류발생 메시지. 한국어 번역+ 제작자에게 연락바람")
                    end
                elseif itemID == CollectibleType.COLLECTIBLE_BIRTHRIGHT then   -- 생득권이라면
                    local b_playerType = player:GetPlayerType()
                    local b_description = birthrightDesc[b_playerType]
                    if b_description then
                        Game():GetHUD():ShowItemText("생득권", b_description or "???")
                    end 
                else
                    local item = changes.items[tostring(itemID)]   -- 일반 아이템이라면
                    if item and not REPENTOGON then
                        Game():GetHUD():ShowItemText(item.name, item.description)
                    end
                end
            end
            i_queueLastFrame[playerKey] = i_queueNow[playerKey]
        end
    )
end


------ 사해사본 by 双笙子佯谬 ------
local deadSeaScrollsList = {34,35,37,38,39,41,42,44,45,56,49,58,77,65,66,78,83,84,85,86,93,97,107,102,47,123,136,146,158,160,171,192}

local function getNextDeadSeaScrollsItem(rng)
    return deadSeaScrollsList[rng:RandomInt(#deadSeaScrollsList) + 1]
end

local lastPredictedID = nil    -- 마지막으로 예측된 아이템 ID 저장
local activePredictor = {
    [124] = getNextDeadSeaScrollsItem,
}

local function PredictDeadSeaScrolls(player)
    local predFunc = activePredictor[124]
    if predFunc then
        local rng = RNG()
        rng:SetSeed(player:GetCollectibleRNG(124):GetSeed(), 35)
        lastPredictedID = predFunc(rng)
    end
end

local function FakeDeadSeaScrolls()
    if lastPredictedID and lastPredictedID ~= 0 then
        local d_data = jsonData.items[tostring(lastPredictedID)]
        if d_data and not REPENTOGON then
            Game():GetHUD():ShowItemText(d_data.name)
        elseif not REPENTOGON then
            Game():GetHUD():ShowItemText("일종의 오류발생 메시지", "한국어 번역+ 제작자에게 연락바람")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    PredictDeadSeaScrolls(player)
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, flags)
    if item == 124 then
        FakeDeadSeaScrolls()
        PredictDeadSeaScrolls(player)
    end
    return true
end, 124)


------ 제작 가방 ------
if EID and not REPENTOGON then
    local previousBagItems = {}
    local lastPlayerType = -1

    local function ShowCraftedItem(player)
        local recipeID = EID:calculateBagOfCrafting(previousBagItems)
        local BoCItems = jsonData.items[tostring(recipeID)]
        
        if BoCItems then
            Game():GetHUD():ShowItemText(BoCItems.name, BoCItems.description)
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if Isaac.GetPlayer(0):GetPlayerType() ~= lastPlayerType then
            previousBagItems = {}
            lastPlayerType = Isaac.GetPlayer(0):GetPlayerType()
        end

        if lastPlayerType ~= 23 then return end   -- 더렵하진 카인이 아니면 종료

        local currentBagCount = #EID.BoC.BagItems
        if #previousBagItems == 8 and currentBagCount == 0 then
            ShowCraftedItem()
        end
        previousBagItems = EID.BoC.BagItems
    end)
else
    Isaac.DebugString("EID가 설치되지 않았습니다. 더럽혀진 카인이 아이템을 획득해도 그 아이템의 이름과 설명은 오역이 수정되지 않습니다.")
end


------ 레메게톤 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local w_queueLastFrame = {}
local w_queueNow = {}
local delayedWisps = {}
local gameStarted = false   -- 게임 시작 시 초기화용

local function WispText(familiar)
    local familiarKey = tostring(familiar.InitSeed)
    local WispID = familiar.SubType
    
    w_queueNow[familiarKey] = WispID
    if WispID > 0 and w_queueLastFrame[familiarKey] == nil then
        local wisp = changes.items[tostring(WispID)]
        if wisp and not REPENTOGON then
            Game():GetHUD():ShowItemText(wisp.name or "일종의 오류발생 메시지", wisp.description or "한국어 번역+ 제작자에게 연락바람")
        elseif not REPENTOGON then
            print("[ Korean Localizing Plus ]\n" .. tostring(WispID) .. "번 아이템이 모드 아이템이거나 플레이어가 2인 이상인 상태입니다.")
        end
    end
    w_queueLastFrame[familiarKey] = w_queueNow[familiarKey]
end

function mod:ResetWispData()
    gameStarted = true
    delayedWisps = {}
end

function mod:DetectWisp(familiar)
    if familiar.Type == 3 and familiar.Variant == 237 and gameStarted then
        local wispData = familiar:GetData()
        if familiar.Position:Distance(Vector(-1000, -1000)) < 1 then return end     -- 임시방편. HiddenItemManager를 사용하는 모드와 충돌 방지
        table.insert(delayedWisps, familiar)
    end
end

function mod:ShowWispText()
    if #delayedWisps > 0 then
        WispText(delayedWisps[1])   -- 1프레임 지연 실행
        table.remove(delayedWisps, 1)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.ResetWispData)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DetectWisp)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.ShowWispText)


------ 알약 관련 코드 ------
local pillFiles = {}

if KoreanFontChange then
    pillFiles = {
        [PillEffect.PILLEFFECT_TEARS_UP] = "gfx/ui/pilltext/koreanfontchange/tears/KLP_TearsUP_kfc.anm2",
        [PillEffect.PILLEFFECT_TEARS_DOWN] = "gfx/ui/pilltext/koreanfontchange/tears/KLP_TearsDown_kfc.anm2",
        [PillEffect.PILLEFFECT_SHOT_SPEED_UP] = "gfx/ui/pilltext/koreanfontchange/shotspeed/KLP_ShotSpeedUp_kfc.anm2",
        [PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = "gfx/ui/pilltext/koreanfontchange/shotspeed/KLP_ShotSpeedDown_kfc.anm2"
    }
else
    pillFiles = {
        [PillEffect.PILLEFFECT_TEARS_UP] = "gfx/ui/pilltext/tears/KLP_TearsUP.anm2",
        [PillEffect.PILLEFFECT_TEARS_DOWN] = "gfx/ui/pilltext/tears/KLP_TearsDown.anm2",
        [PillEffect.PILLEFFECT_SHOT_SPEED_UP] = "gfx/ui/pilltext/shotspeed/KLP_ShotSpeedUp.anm2",
        [PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = "gfx/ui/pilltext/shotspeed/KLP_ShotSpeedDown.anm2"
    }
end

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

        local hudOffset = Options.HUDOffset
        local offsetX, offsetY

        if mod:isJacobAndEsau(player) then
            if KoreanFontChange then
                offsetX = 108 + hudOffset * 20
            else
                offsetX = 93 + hudOffset * 20
            end
            offsetY = 33 + hudOffset * 12
            renderPosition = Vector(offsetX, offsetY)
        else
            offsetX = -125 - hudOffset * 16
            offsetY = -20 - hudOffset * 6
            renderPosition = Vector(screenWidth + offsetX, screenHeight + offsetY)
        end

        currentPillSprite:Render(renderPosition, Vector(0, 0), Vector(0, 0))
    end
end

function mod:onGameStart(isContinued)
    currentPillSprite = nil
    pillUsedEffects = {}
end

local pillNames = {
    [PillEffect.PILLEFFECT_X_LAX] = "설사약",
    [PillEffect.PILLEFFECT_HORF] = "퉤엣!",
    [PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = "투사체 속도 감소",
    [PillEffect.PILLEFFECT_SHOT_SPEED_UP] = "투사체 속도 증가",
}

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

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onGameStart)
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.onEvaluatePill)


------ REPENTOGON ------
if REPENTOGON then
    mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
        local conf = Isaac.GetItemConfig()

        if jsonData.items then
            for key, entry in pairs(jsonData.items) do
                local id = tonumber(key)
                if id and id ~= -1 then
                    local cfg = conf:GetCollectible(id)
                    cfg.Name = entry.name
                    cfg.Description = entry.description
                end
            end
        end

        if jsonData.trinkets then
            for key, entry in pairs(jsonData.trinkets) do
                local id = tonumber(key)
                if id and id ~= -1 then
                    local cfg = conf:GetTrinket(id)
                    cfg.Name = entry.name
                    cfg.Description = entry.description
                end
            end
        end
    end)
end
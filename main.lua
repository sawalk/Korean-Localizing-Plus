local mod = RegisterMod("Korean Localizing Plus", 1)
local data = include('data')
local json = require('json')
local game = Game()
local SubSprite = Sprite()
local VoiceSFX = SFXManager()

-- 한국어가 아닙니다!
local font = Font()
font:Load("font/cjk/lanapixel.fnt")

local showMessage = false
local messageTime = 150
local messageDisplayedTime = 0

local function checkLanguage()
  if Options.Language ~= "kr" then
    print("Korean Localizing Plus - Playing in a language other than Korean is not recommended!\n")
    showMessage = true
  end
end

local function updateMessage()
  if showMessage then
    messageDisplayedTime = messageDisplayedTime + 1
    if messageDisplayedTime >= messageTime then
      showMessage = false
    end
  end
end

local function renderMessage()
  local renderMessageWidth
  if showMessage then
    if Options.MaxScale == 3 and Options.Fullscreen == true then
      renderMessageWidth = 0.66666
      renderMessageY = 242
    else
      renderMessageWidth = 0.5
      renderMessageY = 240
    end
    font:DrawStringScaledUTF8("한국어 번역+가 한국어가 아닌 환경에서 실행되었습니다!",10,230,renderMessageWidth,renderMessageWidth,KColor(1,1,1,1),0,true)
    font:DrawStringScaledUTF8("모드를 끄고 언어를 한국어로 설정한 뒤 다시 모드를 켜주세요.",10,renderMessageY,renderMessageWidth,renderMessageWidth,KColor(1,1,1,1),0,true)
  end
end

-- (구)리펜턴스 한국어 자막
if KoreanFontChange then
  SubSprite:Load("gfx/cutscenes/backwards_kfc.anm2", true)
else
  SubSprite:Load("gfx/cutscenes/backwards.anm2", true)
end

local function GetScreenSize()
  local pos = Game():GetRoom():WorldToScreenPosition(Vector(0,0)) - Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset

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
  if Input.IsButtonTriggered(39, 0) then
      mod.IsHidden = not mod.IsHidden
  end
  if mod.IsHidden then return end

  for i = 598, 601 do
      if VoiceSFX:IsPlaying(i) then
          VoiceSFX:Stop(i)
          VoiceSFX:Play(Isaac.GetSoundIdByName("DADS_NOTE_KOREAN_" .. (i - 597)))
      end
  end

  for i = 1, 4 do
      if VoiceSFX:IsPlaying(Isaac.GetSoundIdByName("DADS_NOTE_KOREAN_" .. i)) then
          RenderSub("backwards" .. i)
      end
  end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, updateMessage)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderMessage)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, checkLanguage)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)


-- EZITEMS 관련
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
local function updateEid ()
  for type, itemTypeData in pairs(changes) do
    for id, itemData in pairs(itemTypeData) do
      EID:addDescriptionModifier(
        'EZITEMS | ' .. tostring(mod.Name) .. ' | ' .. itemData.name,
        function (descObj) return descObj.ObjType == 5 and descObj.ObjVariant == itemVariants[type] and descObj.ObjSubType == tonumber(id) end,
        function (descObj) descObj.Name = itemData.name; return descObj end
      )
    end
  end
end

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

-- 

parseJsonData()
checkConflicts()

if EID then
  updateEid()
end

if next(changes.trinkets) ~= nil then
  local t_queueLastFrame
  local t_queueNow
  mod:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,

    ---@param player EntityPlayer
    function(_, player)
      t_queueNow = player.QueuedItem.Item
      if (t_queueNow ~= nil) then
        local trinket = changes.trinkets[tostring(t_queueNow.ID)]
        if trinket and t_queueNow:IsTrinket() and t_queueLastFrame == nil then
          game:GetHUD():ShowItemText(trinket.name, trinket.description)
        end
      end
      t_queueLastFrame = t_queueNow
    end
  )
end

if next(changes.items) ~= nil then
  local i_queueLastFrame
  local i_queueNow
  mod:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,

    ---@param player EntityPlayer
    function(_, player)
      i_queueNow = player.QueuedItem.Item
      if (i_queueNow ~= nil) then
        local item = changes.items[tostring(i_queueNow.ID)]
        if item and i_queueNow:IsCollectible() and i_queueLastFrame == nil then
          game:GetHUD():ShowItemText(item.name, item.description)
        end
      end
      i_queueLastFrame = i_queueNow
    end
  )
end


-- 알약 관련 코드
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

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onGameStart)

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

mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.onEvaluatePill)
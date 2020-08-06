-- div. Funktionen, die andere Add-ons/Module nutzen.
local _func = {}

-- einzelne i18n-Textausgaben
function _func._L(addonName, localizationName)
  return function(localizationName)
    local _L = ShissuLocalization[addonName]

    if _L[localizationName] == nil then
      return ""
    end

    return _L[localizationName]
  end
end

-- String an String teilen, und die einzelnen Teile wieder in ein Array packen
function _func.splitToArray (search, text)
  if (text=='') then return false end

  local pos,arr = 0,{}

  for st,sp in function() return string.find(search,text,pos,true) end do
    table.insert(arr, string.sub(search,pos,st-1))
    pos = sp + 1
  end

  table.insert(arr,string.sub(search,pos))

  return arr
end

-- RGB zu Hex
function _func.RGBtoHex(r,g,b, list)
  local rgb = {255, 255, 255}

  if ( list ~= nil ) then
    rgb = { list[1]*255, list[2]*255, list[3]*255 }
  else
    rgb = {r*255, g*255, b*255}
  end

  local hexstring = ""

  for key, value in pairs(rgb) do
    local hex = ""

    while (value > 0)do
      local index = math.fmod(value, 16) + 1
      value = math.floor(value / 16)
      hex = string.sub("0123456789ABCDEF", index, index) .. hex
    end

    if(string.len(hex) == 0) then
      hex = "00"
    elseif(string.len(hex) == 1) then
      hex = "0" .. hex
    end

    hexstring = hexstring .. hex
  end

  return "|c" .. hexstring
end

-- String an String teilen, und die einzelnen Teile wieder in ein Array packen
function _func.splitToArray (search, text)
  if (text=='') then return false end

  local pos,arr = 0,{}

  for st,sp in function() return string.find(search,text,pos,true) end do
    table.insert(arr, string.sub(search,pos,st-1))
    pos = sp + 1
  end

  table.insert(arr,string.sub(search,pos))

  return arr
end

-- Unerwünschte Zeichen abschneiden
function _func.cutStringAtLetter(text, letter)
  if text ~= nil then
    local pos = string.find(text, letter, nil, true)

    if pos then text = string.sub (text, 1, pos-1) end
  end

  return text;
end

-- Auf- und Abrunden
function _func.round(number)
  local dec = number - math.floor(number)

   if dec > 0.5 then return math.ceil(number)
   else return math.floor(number) end
end

-- String leer / oder nicht existent
function _func.isStringEmpty(text)
  return text == nil or text == ''
end

-- For testing and comparison only, this is not to be used.
function _func.currentTime()
  local correction = GetSecondsSinceMidnight() - (GetTimeStamp() % 86400)
  if correction < -12*60*60 then correction = correction + 86400 end

  return GetTimeStamp() + correction
end

-- Zeit bis zum nächsten Gildenhändler???
-- Time to the next guild trader
function _func.getKioskTime(which)
  local additional = additional or 0

  --[[
  1: This fuction is not called using other parameters
  such as additional or day. If that changes this will
  not work
  2: This function gets the ammount of seconds remaining
  until the next trader flip.
  ]]--
  local _, weekCutoff = GetGuildKioskCycleTimes()

  -- Gebots Ende
  -- Bidding end
  if (which == 1) then
    weekCutoff = weekCutoff - 300
  -- Ersatzhändler
  -- Replacement dealer
  elseif (which == 2) then
    weekCutoff = weekCutoff + 300
  end

  return weekCutoff
end

ShissuFramework["func"] = _func
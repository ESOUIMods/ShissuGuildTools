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

-- Aktuelle Uhrzeit... Korrektur +
-- Current time + correction
function _func.currentTime()
  local correction = GetSecondsSinceMidnight() - (GetTimeStamp() % 86400)
  --sf_internal.v(string.format("%s %s", "1: correction: ", correction))
  if correction < -12*60*60 then correction = correction + 86400 end
  --sf_internal.v(string.format("%s %s", "2: correction: ", correction))
  the_result = GetTimeStamp() + correction
  --sf_internal.v(string.format("%s %s", "3: the_result: ", the_result))
  --sf_internal.v(string.format("%s %s", "4: the time: ", GetTimeStamp()))
  --sf_internal.v(string.format("%s %s", "5: the diff: ", GetDiffBetweenTimeStamps(GetTimeStamp(),the_result)))
  return the_result
end

-- Zeit bis zum nächsten Gildenhändler???
-- Time to the next guild trader
function _func.getKioskTime(which, additional, day)
  local hourSeconds = 60 * 60
  local daySeconds = 60 * 60 *24
  local weekSeconds = 7 * daySeconds
  local additional = additional or 0

  -- Erste Woche 1970 beginnt Donnerstag -> Verschiebung auf Gebotsende
  -- First week of 1970 begins Thursday -> postponement to end of bid
  local firstWeek = 1 + (3 * daySeconds) + (19 * hourSeconds)

  local currentTime =  _func.currentTime()

  -- Anzahl der Wochen seit 01.01.1970
  -- Number of weeks since 01/01/1970
  local week = math.floor(currentTime / weekSeconds) + additional
  local beginnKiosk = firstWeek + (weekSeconds * week) + 60 * 60

  --[[
  Rather then eliminate all of the code I will add this

  1: This fuction is not called using other parameters
  such as additional or day. If that changes this will
  not work
  2: This function gets the ammount of seconds remaining
  until the next trader flip.
  ]]--
  local _, weekCutoff = GetGuildKioskCycleTimes()
  beginnKiosk = weekCutoff

  -- Gebots Ende
  -- Bidding end
  if (which == 1) then
    beginnKiosk = beginnKiosk - 300
  -- Ersatzhändler
  -- Replacement dealer
  elseif (which == 2) then
    beginnKiosk = beginnKiosk + 300
  end

  -- Restliche Zeit in der Woche
  -- Remaining time in the week
  local restWeekTime = beginnKiosk - GetTimeStamp()

  --[[
  if (day) then
    restWeekTime = beginnKiosk
  end
  ]]--

  if restWeekTime < 0 then
    restWeekTime = 7 * 86400 -- one week if guild store is offline
  end

  return restWeekTime
end

ShissuFramework["func"] = _func
﻿-- Shissu Guild Tools Addon
-- ShissuHistoryScanner
--
-- Version: v1.5.0
-- Last Update: 25.11.2020
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local green = _globals["green"]
local red = _globals["red"]

local currentTime = ShissuFramework["func"].currentTime
local getKioskTime = ShissuFramework["func"].getKioskTime


local _addon = {}

_addon.Name = "ShissuHistoryScanner"
_addon.guildIndex = nil
_addon.category = GUILD_HISTORY_GENERAL
_addon.scanInterval = 4800
_addon.scanNewGuilds = 5 * 60 * 1000
_addon.firstGuildScan = false
_addon.firstScan = true

local _L = ShissuFramework["func"]._L(_addon.Name)

function _addon.getData(eventType, guildName, displayName)
  local timeFirst = 0
  local timeLast = 0
  local total = 0
  local last = 0
  local currentNPC = 0
  local previousNPC = 0

  if shissuHistoryScanner ~= nil then
    if ( shissuHistoryScanner[guildName] ~= nil ) then
      if ( shissuHistoryScanner[guildName][displayName] ~= nil ) then
        if ( shissuHistoryScanner[guildName][displayName][eventType] ~= nil ) then
          timeFirst = shissuHistoryScanner[guildName][displayName][eventType].timeFirst or 0
          timeLast = shissuHistoryScanner[guildName][displayName][eventType].timeLast or 0
          total = shissuHistoryScanner[guildName][displayName][eventType].total or 0
          last = shissuHistoryScanner[guildName][displayName][eventType].last or 0
          currentNPC = shissuHistoryScanner[guildName][displayName][eventType].currentNPC or 0
          previousNPC = shissuHistoryScanner[guildName][displayName][eventType].previousNPC or 0
        end
      end
    end
  end
  -- date time 1596684136
  --sf_internal.v(string.format("%s %s", "getData timeFirst ", timeFirst))
  -- date time 1596684136
  --sf_internal.v(string.format("%s %s", "getData timeLast ", timeLast))
  -- Total gold, but not sure the time span 5002 was current and previous day
  --sf_internal.v(string.format("%s %s", "getData total ", total))
  -- current day's deposits 5000
  --sf_internal.v(string.format("%s %s", "getData last ", last))
  -- total gold deposit since Kiosk Flip
  --sf_internal.v(string.format("%s %s", "getData currentNPC ", currentNPC))
  -- total gold deposit for previous Kiosk Flip
  --sf_internal.v(string.format("%s %s", "getData previousNPC ", previousNPC))
  return {timeFirst, timeLast, total, last, currentNPC, previousNPC}
end

function _addon.createDisplayNameData(guildName, displayName)
  if (shissuHistoryScanner[guildName][displayName] == nil) then
    shissuHistoryScanner[guildName][displayName] = {}
  end
end

function _addon.copyCurrentToPrev(guildName, displayName, eventType)
  --if (shissuHistoryScanner[guildName][displayName] ~= nil) then
    if shissuHistoryScanner[guildName][displayName][eventType] ~= nil then
      --if shissuHistoryScanner[guildName][displayName][eventType].currentNPC ~= nil then
        shissuHistoryScanner[guildName][displayName][eventType].previousNPC = shissuHistoryScanner[guildName][displayName][eventType].currentNPC
        shissuHistoryScanner[guildName][displayName][eventType].currentNPC = nil
      --end
    end
 -- end
end

function _addon.copyCurrentDateToLast()
  for i=1, GetNumGuilds() do
    local guildId = GetGuildId(i)
    local guildName = GetGuildName(guildId)

    for displayName, _ in pairs(shissuHistoryScanner[guildName]) do
      --if (shissuHistoryScanner[guildName][displayName] ~= nil) then
        _addon.copyCurrentToPrev(guildName, displayName, GUILD_EVENT_BANKGOLD_ADDED)
        _addon.copyCurrentToPrev(guildName, displayName, GUILD_EVENT_BANKGOLD_REMOVED)
        _addon.copyCurrentToPrev(guildName, displayName, GUILD_EVENT_BANKITEM_ADDED)
        _addon.copyCurrentToPrev(guildName, displayName, GUILD_EVENT_BANKITEM_REMOVED)
      --end
    end
  end
end

function _addon.previousTime(guildName, category)
  local t = 1500000000

  -- ~=
  if shissuHistoryScanner[guildName] == nil then
    return t
  end

  -- ~=
  if shissuHistoryScanner[guildName]["oldestEvent"] == nil then
    return t
  end

  local oldestEvent = shissuHistoryScanner[guildName]["oldestEvent"][category]

  if oldestEvent ~= nil then
    if oldestEvent > 0 then return oldestEvent end
  end

  for _, displayName in pairs(shissuHistoryScanner[guildName]) do
    if (displayName["timeJoined"] ~= nil) then

      if (category == GUILD_HISTORY_GENERAL) then
        if (displayName["timeJoined"] > 0) and (displayName["timeJoined"] < t) then
          t = displayName["timeJoined"]
        end
      else
        if (displayName[GUILD_EVENT_BANKGOLD_ADDED] ~= nil) then
          if (displayName[GUILD_EVENT_BANKGOLD_ADDED].timeFirst > 0) and (displayName[GUILD_EVENT_BANKGOLD_ADDED].timeFirst < t) then
            t = displayName[GUILD_EVENT_BANKGOLD_ADDED].timeFirst
          end
        end
      end
    end
  end

  return t
end

function _addon.processEvents(guildId, category)
  local guildName = GetGuildName(guildId)
  local numEvents = GetNumGuildEvents(guildId, category)

  if (numEvents == 0) then return end

  local _, firstEventTime = GetGuildEventInfo(guildId, category, 1)
  local _, lastEventTime = GetGuildEventInfo(guildId, category, numEvents)
  local lastScan = shissuHistoryScanner[GetGuildName(guildId)]["lastScans"][category] or 0
  local first = numEvents
  local last = 1
  local inc = -1

  local nextKiosk = ShissuFramework["globals"].next_kiosk_change
  local lastNPC = ShissuFramework["globals"].last_kiosk_change
  local previousKiosk = ShissuFramework["globals"].previous_kiosk_change

  --sf_internal.v("process: " .. guildId .. " " .. guildName)

  --sf_internal.v("NEXT Kiosk: " .. GetDateStringFromTimestamp(nextKiosk) .. " - " .. ZO_FormatTime((nextKiosk) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR))
  --sf_internal.v("Last NPC: " .. GetDateStringFromTimestamp(lastNPC) .. " - " .. ZO_FormatTime((lastNPC) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR))
  --sf_internal.v("Previous Kiosk: " .. GetDateStringFromTimestamp(previousKiosk) .. " - " .. ZO_FormatTime((previousKiosk) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR))

  -- If the last recalculated NPC has a deviation from the saved last one,
  -- then "reset" the current week and move the information back.
  if (shissuHistoryScanner["lastNPC"] ~= nil) then
    if (lastNPC > shissuHistoryScanner["lastNPC"] ) then
      shissuHistoryScanner["lastNPC"] = lastKiosk
      _addon.copyCurrentDateToLast()
    end
  else
    shissuHistoryScanner["lastNPC"] = lastNPC
  end


  if (firstEventTime > lastEventTime) then
    first = 1
    last = numEvents
    inc = 1
  end

  -- Process the event
  for eventId = first, last, inc do
    -- eventTime is seconds since event
    local eventType, eventTime, displayName, eventGold = GetGuildEventInfo(guildId, category, eventId)
    --[[
    timeStamp should end up being the time the event occured
    by deducting the seconds from the current time
    1596688008 - 11153 = 1596676855
    currentTime would have been a bit off at
    1596749208
    ]]--
    local timeStamp = GetTimeStamp() - eventTime
    --sf_internal.v(string.format("%s %s", "processEvents currentTime ", ShissuFramework["func"].currentTime()))
    --sf_internal.v(string.format("%s %s", "processEvents eventTime ", eventTime))
    --sf_internal.v(string.format("%s %s", "processEvents GetTimeStamp ", GetTimeStamp()))
    --sf_internal.v(string.format("%s %s", "processEvents timeStamp ", timeStamp))

    -- TimeStamp from the oldest event
    local oldestEvent = _addon.previousTime(guildName, category)

    --sf_internal.v("OLDEST: " .. GetDateStringFromTimestamp(oldestEvent) .. " - " .. ZO_FormatTime((oldestEvent) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR))

    -- Event time > 0
    -- oldest event > selected event
    if ( timeStamp > 0 ) and ( (oldestEvent == 0) or (oldestEvent > timeStamp) ) then
      -- if (oldestEvent == 0) or (oldestEvent > timeStamp) then
      if shissuHistoryScanner[guildName] ~= nil then
        if shissuHistoryScanner[guildName]["oldestEvent"] ~= nil then
          shissuHistoryScanner[guildName]["oldestEvent"][category] = timeStamp
        else
          shissuHistoryScanner[guildName]["oldestEvent"] = {}
          shissuHistoryScanner[guildName]["oldestEvent"][category] = timeStamp
        end
      end
      --end
    end

    if (timeStamp > lastScan) or (lastScan == 0) then
      -- When invited / joined the guild?
      if (category == GUILD_HISTORY_GENERAL) then
        if (eventType == GUILD_EVENT_GUILD_JOIN) then
          local timeJoined = 0

          if shissuHistoryScanner[guildName][displayName] ~= nil then
            timeJoined = shissuHistoryScanner[guildName][displayName].timeJoined or 0

            if (timeJoined < timeStamp) then
              shissuHistoryScanner[guildName][displayName].timeJoined = timeStamp
            end

          else
            _addon.createDisplayNameData(guildName, displayName)
            shissuHistoryScanner[guildName][displayName].timeJoined = timeStamp
          end
        end

        shissuHistoryScanner[guildName]["lastScans"][category] = timeStamp
      end

      -- Banking activities
      if (category == GUILD_HISTORY_BANK) then
        if (eventType == GUILD_EVENT_BANKGOLD_ADDED) or (eventType == GUILD_EVENT_BANKGOLD_REMOVED) or (eventType == GUILD_EVENT_BANKITEM_ADDED) or (eventType == GUILD_EVENT_BANKITEM_REMOVED) then
          local getData =  _addon.getData(eventType, guildName, displayName)

          local timeFirst = getData[1]
          local timeLast = getData[2]
          local total = getData[3]
          local last = getData[4]
          local currentNPC = getData[5]
          local previousNPC = getData[6]

         -- sf_internal.v(eventType)
         -- sf_internal.v(guildName)
         -- sf_internal.v(displayName)
         -- sf_internal.v(getData)
            --sf_internal.v(string.format("%s %s", "processEvents timeStamp ", timeStamp))
            --sf_internal.v(string.format("%s %s", "processEvents math.abs ", (timeLast - timeStamp)))
            --[[
            ranges I saw durring testing were from 0 to 10 and one
            occurance of 48500.
            I don't know the significance
            ]]--
            --[[
            the question is why does the result of mat.abs need to
            be greater then 2. Seconds maybe?
            ]]--
           if (timeLast < timeStamp) and (math.abs(timeLast - timeStamp) > 2) then
            _addon.createDisplayNameData(guildName, displayName)

            if shissuHistoryScanner[guildName][displayName][eventType] == nil then
              shissuHistoryScanner[guildName][displayName][eventType] = {}
            end

            -- this adds the gold from the history to the total gold scanned
            shissuHistoryScanner[guildName][displayName][eventType].total = total + eventGold
            -- this adds is the gold found from the last event scanned
            shissuHistoryScanner[guildName][displayName][eventType].last = eventGold
            -- this is the time stamp of the last event found
            shissuHistoryScanner[guildName][displayName][eventType].timeLast = timeStamp

            -- since lastNPC seems to mean since the Kiosk flipped for this week
            if timeStamp > lastNPC then
              --sf_internal.v("CURRENTNPC")
              --sf_internal.v(displayName)
              --sf_internal.v(currentNPC)
              --sf_internal.v(eventGold)
              shissuHistoryScanner[guildName][displayName][eventType].currentNPC = currentNPC + eventGold
              --sf_internal.v(shissuHistoryScanner[guildName][displayName][eventType].currentNPC)
            end

            -- since previousKiosk seems to mean since the previous week
            if timeStamp > previousKiosk and timeStamp < lastNPC then
              shissuHistoryScanner[guildName][displayName][eventType].previousNPC = previousNPC + eventGold
            end

           -- sf_internal.v(guildName)
           -- sf_internal.v(displayName)
           -- sf_internal.v(eventType)

             --[[
             these next two, "table" and 0 seem to take care of when
             there is no hisotry maybe?
             ]]--
            if (type(timeFirst) == "table") then
             -- sf_internal.v("TABLE")
              timeFirst = 0
            end

             -- sf_internal.v("2: " .. timeStamp)

            if (timeFirst == 0) then
              shissuHistoryScanner[guildName][displayName][eventType].timeFirst = timeStamp
            end

             --[[
             this seems to be saying if the oldest time is less
             then the current event found then assign it the current
             timestamp of the event found
             ]]--
            if ( timeFirst < timeStamp ) then
              shissuHistoryScanner[guildName][displayName][eventType].timeFirst = timeStamp
            end

          end
        end

        shissuHistoryScanner[guildName]["lastScans"][category] = timeStamp
      end
    end
  end
end

function _addon.historyResponseReceived(eventCode, guildId, category)
  if (category ~= GUILD_HISTORY_GENERAL) and (category ~= GUILD_HISTORY_BANK) and guildId ~= nil then return end

  local guildName = GetGuildName(guildId)

  local numEvents = GetNumGuildEvents(guildId, category)
  local _, firstEventTime = GetGuildEventInfo(guildId, category, 1)
  local _, lastEventTime = GetGuildEventInfo(guildId, category, numEvents)
  local lastScan = 0

  if (shissuHistoryScanner[guildName] == nil) then
    shissuHistoryScanner[guildName] = {}
  end

  if shissuHistoryScanner[guildName]["lastScans"] == nil then
    shissuHistoryScanner[guildName]["lastScans"] = {}
  end

  if (shissuHistoryScanner[guildName]["lastScans"][category] ~= nil) then
    lastScan = shissuHistoryScanner[guildName]["lastScans"][category]
  end

  --local lastScan = shissuHistoryScanner[guildName]["lastScans"][category]  or 0
  local timeStamp = GetTimeStamp()

  if ((timeStamp - firstEventTime) > lastScan and (timeStamp  - lastEventTime) > lastScan) or (lastScan == 0) then
    zo_callLater(_addon.openHistoryPage, _addon.scanInterval)
  else
    _addon.processEvents(guildId, category)
    _addon.scanNext()
  end
end

function _addon.openHistoryPage()
  local guildId = GetGuildId(_addon.guildIndex)

  local historyPage

  if (_addon.firstScan) then
    _addon.firstScan = false

    local guildName = GetGuildName(guildId)

    --_addon.createGuild(guildName)

    if shissuHistoryScanner[guildName] == nil then
      shissuHistoryScanner[guildName] = {}
      shissuHistoryScanner[guildName]["oldestEvents"] = {}
      shissuHistoryScanner[guildName]["lastScans"] = {}
    end

    historyPage = RequestMoreGuildHistoryCategoryEvents(guildId, _addon.category)
  end

  if (not historyPage) then
    _addon.processEvents(guildId, _addon.category)
    _addon.scanNext()
  end
end

function _addon.scanNext()
  if (_addon.category == GUILD_HISTORY_GENERAL) then
    -- Wenn GENERAL bei GILDE xyz schon vollständig offen ist.
    _addon.scan(_addon.guildIndex, GUILD_HISTORY_BANK)
  else
    if ( _addon.firstGuildScan == true ) then
      local guildId = GetGuildId(_addon.guildIndex)
      local guildName = GetGuildName(guildId)

      _addon.firstGuildScan = false

     -- d(blue.. "Shissu's" .. white .. "Guild Tools: " .. guildName .. " DONE")
    end

    local numGuilds = GetNumGuilds()

    if (_addon.guildIndex < numGuilds) then
      _addon.scan(_addon.guildIndex + 1, GUILD_HISTORY_GENERAL)
    else
      EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_GUILD_HISTORY_RESPONSE_RECEIVED)
      zo_callLater(_addon.scanAvailableGuilds, _addon.scanNewGuilds)
    end
  end
end

function _addon.scan(guildId, category)
  _addon.guildIndex = guildId
  _addon.category = category
  _addon.firstScan = true

  local guildId = GetGuildId(guildId)
  local guildName = GetGuildName(guildId)

  if (shissuHistoryScanner[guildName] == nil) then
    d(stdColor.. "Shissu's " .. white .. "HistoryScanner: " .. string.format(_L("SCAN"), red .. guildName .. white))

    shissuHistoryScanner[guildName] = {}
    shissuHistoryScanner[guildName]["oldestEvents"] = {}
    shissuHistoryScanner[guildName]["lastScans"] = {}

    _addon. firstGuildScan = true
  end

  zo_callLater(_addon.openHistoryPage, _addon.scanInterval)
end

function _addon.scanAvailableGuilds()
  local numGuilds = GetNumGuilds()

  if (numGuilds > 0) then
    EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_HISTORY_RESPONSE_RECEIVED, _addon.historyResponseReceived)
    _addon.scan(1, GUILD_HISTORY_GENERAL)
  else
    zo_callLater(_addon.scanAvailableGuilds, _addon.scanNewGuilds)
  end
end

function _addon.OnPlayerActivated(eventCode)
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, eventCode)
  zo_callLater(_addon.scanAvailableGuilds, _addon.scanInterval)
end

local function onAddOnLoaded(eventCode, addonName)
  if (addonName ~= _addon.Name) then return end

  -- KOPIE / Leeren alter SGT Var
  shissuHistoryScanner = shissuHistoryScanner or {}
 -- if ( shissuGT ~= nil ) then
  --  if ( shissuGT["History"] ~= nil ) then
  --    shissuHistoryScanner = deepcopy(shissuGT["History"])
  --    shissuGT["History"] = nil
  --  end
  --end
  -- KOPIE / Leeren alter SGT Var

  if ( shissuHistoryScanner["Kiosk"] ~= nil ) then
    shissuHistoryScanner["lastNPC"] = shissuHistoryScanner["Kiosk"]
    shissuHistoryScanner["Kiosk"] = nil
  end

  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED, _addon.OnPlayerActivated)
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
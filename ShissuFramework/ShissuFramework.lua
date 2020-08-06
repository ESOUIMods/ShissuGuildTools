local _addon = {}

_addon.Name = "ShissuFramework"
_addon.formattedName	= "|c82FA58Shissu|ceeeeee's Framework"
_addon.Version = "0.6.3"

_addon._settings = {}
sf_internal = {}

local logger = LibDebugLogger.Create(_addon.Name)
_addon.logger = logger
local SDLV = DebugLogViewer
if SDLV then sf_internal.viewer = true else sf_internal.viewer = false end

local function create_log(log_type, log_content)
  if log_type == "Debug" then
    _addon.logger:Debug(log_content)
  end
  if log_type == "Verbose" then
    _addon.logger:Verbose(log_content)
  end
end

local function emit_message(log_type, text)
  if(text == "") then
      text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent          = indent or "."
  table_history    = table_history or {}

  for k, v in pairs(t) do
    local vType = type(v)

    emit_message(log_type, indent.."("..vType.."): "..tostring(k).." = "..tostring(v))

    if(vType == "table") then
      if(table_history[v]) then
        emit_message(log_type, indent.."Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent.."  ", table_history)
      end
    end
  end
end

function _addon.dm(log_type, ...)
  if not _addon.logger then return end
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if(type(value) == "table") then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end

function sf_internal.v(...)
  if ... and sf_internal.viewer then
    _addon.dm("Debug", ...)
  else
    d(...)
  end
end

local stdColor = "|c82FA58"
local white = "|ceeeeee"

-- Einstellungen; Panelinformationen
function _addon.setPanel(standardName, formattedName, ver)
  local panel = {
    type    = "panel",
    displayName  = formattedName,
    name    = standardName,
    version = ver,
  }

  return panel
end

-- AddOn/Modul Loader
function _addon.initAddon(addOnName, initFunc, loadedName)
  if ( addOnName == nil ) then return false end

  if ( initFunc ~= nil ) then
    initFunc()

    if ( loadedName ~= nil ) then
      d(loadedName)
    end


    zo_callLater(function()
      if _addon._settings[addOnName] ~= nil then
        --
        --  ShissuFramework_Settings.RegisterAddonPanel("ShissuWelcome", ShissuFramework._settings["ShissuWelcome"].panel, ShissuFramework._settings["ShissuWelcome"].controls)
        ShissuFramework_Settings.RegisterAddonPanel(addOnName, _addon._settings[addOnName].panel, _addon._settings[addOnName].controls)
      end
    end, 1000);
  end
end

  -- Initialize Event
function _addon.EVENT_ADD_ON_LOADED (eventCode, addOnName)
  if addOnName ~= _addon.Name then return end

  -- Event entfernen um Ressourcen zu sparen
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)

  --zo_callLater(function()
  --  d(_addon.formattedName .. " " .. _addon.Version)
  --end, 1500);
end

ShissuFramework = _addon
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)

function markPlayer()
  local numCount = 0
  local waitOnEdit = "0"
  local found = 0

  local tamrizon = 3
  local tamrilando = 2
  local guild2_num = GetNumGuildMembers(tamrilando)

  EVENT_MANAGER:RegisterForUpdate("SGT_NOTE_SALE_EDIT", 50, function()
    if (waitOnEdit == "0") then
      numCount = numCount + 1
    end

    local memberData = { GetGuildMemberInfo(tamrilando, numCount) }
    local displayName = memberData[1]
    local note = memberData[2]

    for i=1, guild2_num do
      local memberData2 = { GetGuildMemberInfo(tamrizon, i) }
      local displayName2 = memberData2[1]

      if (displayName2 == displayName) then
        d(displayName)
        found = 1
        break
      end
    end

    if (waitOnEdit == "1") then
      d(note)
      d(string.find(note, "Tamrizon"))

      if string.find(note, "Tamrizon") then
        local newCount = 1
        EVENT_MANAGER:RegisterForUpdate("SGT_NOTE_SALE_EDIT_WAIT", 3000, function()

          if newCount > 2 then
            waitOnEdit = "0"
            found = 0
            EVENT_MANAGER:UnregisterForUpdate("SGT_NOTE_SALE_EDIT_WAIT")
          end

          newCount = newCount + 1
        end)
      end
    end

    if waitOnEdit == "0" and found == 1 then
      SetGuildMemberNote(tamrilando, numCount, "Tamrizon")
      waitOnEdit = "1"
    end
  end)
end

--- FOR A NEW ADDON, TESTING FUNCTION
-- /script checkGoldDeposits("Tamrilando", 2000)
-- /script sf_internal:checkGoldDeposits("To Carry Your Burdens", 2000)

-- Not offical, testing
function sf_internal:checkGoldDeposits(guildName, goldDeposit, removeReminder)
  local lastKiosk = ShissuFramework["globals"].last_kiosk_change
  --sf_internal.v(lastKiosk)
  local _history = shissuHistoryScanner

  --sf_internal.v(ShissuFramework["func"].getKioskTime())

  --sf_internal.v(ShissuLocalization["ShissuHistory"]["LAST_DEALER"] .. GetDateStringFromTimestamp(lastKiosk) .. " - " .. ZO_FormatTime((lastKiosk) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR))

  -- GuildId?
  local numGuild = GetNumGuilds()
  local guildId = nil

  for gId = 1, numGuild do
    if (guildName == GetGuildName(GetGuildId(gId))) then
      sf_internal.v(ShissuLocalization["ShissuHistory"]["FOUND"] .. guildName .. " (" .. GetGuildId(gId) .. ")")
      guildId = GetGuildId(gId)
      break
    end
  end

  --sf_internal.v(guildId)
  if (guildId ~= nil) then
    local reminderText = guildName .. " Reminder\n" .. goldDeposit .. " Gold"
    local numMember = GetNumGuildMembers(guildId)
    local numCount = 0
    local waitOnEdit = "0"
    local found = 0
    local payed = 0
    local notPayed = 0
    local noteExist = 0

    local waiting = 0

    EVENT_MANAGER:RegisterForUpdate("SGT_NOTE_SALE_EDIT", 50, function()
      if (waitOnEdit == "0") then
        numCount = numCount + 1
      end

      local memberData = { GetGuildMemberInfo(guildId, numCount) }
      local note = memberData[2]
      local displayName = memberData[1]

      if (waitOnEdit == "1") then
        if not (string.find(note, reminderText)) then
          local newCount = 1
          EVENT_MANAGER:RegisterForUpdate("SGT_NOTE_SALE_EDIT_WAIT", 5000, function()

            if newCount == 2 then
              waitOnEdit = "0"
              waiting = 0
              EVENT_MANAGER:UnregisterForUpdate("SGT_NOTE_SALE_EDIT_WAIT")
            end

            newCount = newCount + 1

          end)
        end
      end

      if (waitOnEdit == "2") then
        if waiting == 0 then
          sf_internal.v("WAITING")
          waiting = 1
        end

        if string.find(note, reminderText) then
          local newCount = 1
          EVENT_MANAGER:RegisterForUpdate("SGT_NOTE_SALE_EDIT_WAIT", 5000, function()

            if newCount == 2 then
              waitOnEdit = "0"
              waiting = 0
              EVENT_MANAGER:UnregisterForUpdate("SGT_NOTE_SALE_EDIT_WAIT")
            end

            newCount = newCount + 1

          end)
        end
      end

      if waitOnEdit == "0" then
        sf_internal.v(waitOnEdit .. " - " .. numCount .. " CHECK NAME: " .. displayName)       end

      -- Reminder an allen Namen entfernen
      if removeReminder == true then
        --reminderText = ", Thanks"

        if (string.find(note, reminderText) and waitOnEdit == "0") then
          note = string.gsub(note, reminderText, "")
          note = string.gsub(note, "\n", "")
          SetGuildMemberNote(guildId, numCount, note)

          found = found + 1

          waitOnEdit = "1"
        end
      end
      -- ________________

      -- Goldbetr�ge �berpr�fen und Reminder setzen
      if removeReminder == nil and waitOnEdit == "0" then
        if _history[guildName] then
          if _history[guildName][displayName]  then
            if _history[guildName][displayName][GUILD_EVENT_BANKGOLD_ADDED] then
              local lastTime = _history[guildName][displayName][GUILD_EVENT_BANKGOLD_ADDED].timeLast

              if (lastTime) then
                if (lastTime > lastKiosk) then
                  -- Zeit ist korrekt
                  payed = payed + 1
                  --d("--> OK")
                else
                  -- Letzte Einzahlung ist �lter als letzter NPC
                  local goldThisWeek = _history[guildName][displayName][GUILD_EVENT_BANKGOLD_ADDED].currentNPC

                  if (string.find(note, reminderText)) then
                    -- Reminder existiert schon = -> Spieler hat schon die Woche davor nicht bezahlt.
                    noteExist = noteExist + 1
                    notPayed = notPayed + 1
                  else
                    local gold = _history[guildName][displayName][GUILD_EVENT_BANKGOLD_ADDED].last
                    local goldWeek = gold / goldDeposit
                    local addTime = goldWeek * 604800

                    sf_internal.v(goldWeek)

                    if (goldWeek > 0 ) then
                      if lastTime + addTime > lastKiosk then
                        sf_internal.v("--> NAME (VORRAUSGEZAHLT): " .. displayName)

                        payed = payed + 1
                      else
                        sf_internal.v("--> NAME (NICHT VORRAUSGEZAHLT): " .. displayName)

                        if (string.len(note) > 0) then
                          note = note .. "\n" .. reminderText
                          SetGuildMemberNote(guildId, numCount, note)
                        else
                          SetGuildMemberNote(guildId, numCount, reminderText)
                        end

                        notPayed = notPayed + 1
                        waitOnEdit = "2"
                      end

                    elseif (lastTime < lastKiosk or gold == 0) then
                      sf_internal.v("--> NAME (NICHT GEZAHLT): " .. displayName)

                      if (string.len(note) > 0) then
                        note = note .. "\n" .. reminderText
                        SetGuildMemberNote(guildId, numCount, note)
                      else
                        SetGuildMemberNote(guildId, numCount, reminderText)
                      end

                      notPayed = notPayed + 1
                      waitOnEdit = "2"
                    end
                  end

                end
              end
            end
          end
        end
      end
      -- ________________

      -- Anzahl der Spieler erreicht
      -- Number of players reached
      if numMember == numCount then
        sf_internal.v("There were " .. found .. " Notes edited")
        sf_internal.v(notPayed .. " Players did not pay")
        sf_internal.v(noteExist .. " Players did not pay last week")
        sf_internal.v(payed .. " Players paid")

        EVENT_MANAGER:UnregisterForUpdate("SGT_NOTE_SALE_EDIT")
      end
    end)
  end
end

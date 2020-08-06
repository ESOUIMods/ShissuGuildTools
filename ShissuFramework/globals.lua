-- "globals", die andere Add-ons/Module nutzen.
local _globals = {}

-- Farben
_globals.stdColor = "|c82FA58"
_globals.white = "|ceeeeee"
_globals.blue = "|cAFD3FF"
_globals.red = "|cff7d77"
_globals.green = "|c77ff7a"
_globals.yellow = "|cf1ff77"
_globals.gray = "|cd5d1d1"
_globals.orange = "|cF5DA81"

-- Texturen
_globals.goldSymbol = "|t16:16:/esoui/art/guild/guild_tradinghouseaccess.dds|t"

-- EVENTS
_globals["ZOS"] = {
  ["History"] = GUILD_HISTORY_GENERAL,
  ["Joined"] = GUILD_EVENT_GUILD_JOIN,
  ["Bank"] = GUILD_HISTORY_BANK,
  ["GoldAdded"] = GUILD_EVENT_BANKGOLD_ADDED,
  ["GoldRemoved"] = GUILD_EVENT_BANKGOLD_REMOVED,
  ["ItemAdded"] = GUILD_EVENT_BANKITEM_ADDED,
  ["ItemRemoved"] = GUILD_EVENT_BANKITEM_REMOVED,
}

-- Dialogs
ESO_Dialogs["SGT_DIALOG"] = {
  title = { text = "TITEL", },
  mainText = { text = "TEXT", },
  buttons = {
    [1] = {
      text = SI_DIALOG_REMOVE,
      callback = function(dialog) end, },
    [2] = { text = SI_DIALOG_CANCEL, }
  }
}

ESO_Dialogs["SGT_EDIT"] = {
  title = { text = "TITEL", },
  mainText = { text = "TEXT", },
  editBox = {
    defaultText = "",
  },
  buttons = {
    [1] = {
      text = "OK",
      requiresTextInput = true,
      callback = function(dialog) end,
    },
    [2] = { text = SI_DIALOG_CANCEL, }
  }
}

ESO_Dialogs["SGT_RADIOBUTTONS"] = {
  title = { text = "TITEL", },
  mainText = { text = "TEXT", },

  radioButtons = {
    [1] = {
      text = "TEXT",
      data = true,
    },
  },

  buttons = {
    [1] = {
      text = SI_DIALOG_ACCEPT,
      callback =  function(dialog) end,
    },

    [2] = { text = SI_DIALOG_CANCEL, },
  }
}

local function days_last_kiosk()
  local days_last_kiosk
  if GetTimeStamp() > 1597172400 then -- proposed flip begining Tuesday Aug 11
    days_last_kiosk = 604800 -- 7 days
  else
    days_last_kiosk = 777600 -- 9 days
  end
  if GetWorldName() == 'EU Megaserver' then
    days_last_kiosk = days_last_kiosk - (3600 * 5)
  else
    days_last_kiosk = days_last_kiosk - (3600 * 6)
  end
  return days_last_kiosk
end

local _, weekCutoff = GetGuildKioskCycleTimes()
_globals.start_of_day = GetTimeStamp() - GetSecondsSinceMidnight() -- Today
_globals.yesterday = _globals.start_of_day - 86400 -- one day in seconds, yesterday
_globals.next_kiosk_change = weekCutoff -- the up comming change in the future
_globals.last_kiosk_change = weekCutoff - days_last_kiosk() -- since last kiosk flip, this week
_globals.previous_kiosk_change = _globals.last_kiosk_change - 604800 -- seven days in seconds, the previous kiosk flip, last week

ShissuFramework["globals"] = _globals
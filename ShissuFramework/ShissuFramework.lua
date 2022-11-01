--  -------------------
--  Shissu's Framework
--  -------------------
--
--  Framework, UI-Interfache with Flat-Design, Shissu's Libraries, Shissu's Addon-Management
--
--  (c) 2014 - Dezember 2020 by @Shissu [EU]
--
--  Author: Christian Flory (@Shissu, EU-Server) - esoui@flory.one
--  File: ShissuFramework.lua
--  Last Update: 17.12.2020
--  Distribution without license is prohibited!

local _addon = {}
_addon.Name = "ShissuFramework"
_addon.Version = "1.6.0"
_addon._settings = {}
_addon.functions = {}
_addon.templates = {}

sf_internal = {}
local logger
local SDLV

if LibDebugLogger then
  logger = LibDebugLogger.Create(_addon.Name)
  _addon.logger = logger
end
if DebugLogViewer then
  SDLV = DebugLogViewer
  if SDLV then sf_internal.viewer = true else sf_internal.viewer = false end
end

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

local _fileList = {
  ["i18n/en.lua"]                   = function() return ShissuLocalization ~= nil end,

  ["functions/fileintegrity.lua"]   = function() return _addon["fileIntegrity"] ~= nil end,
  ["functions/general.lua"]         = function() return _addon["func"] ~= nil end,

  ["functions/chatsystem.lua"]      = function() return _addon["functions"]["chat"] ~= nil end,
  ["functions/datatypes.lua"]       = function() return _addon["functions"]["datatypes"] ~= nil end,
  ["functions/date.lua"]            = function() return _addon["functions"]["date"] ~= nil end,
  ["functions/datatypes.lua"]       = function() return _addon["functions"]["datatypes"] ~= nil end,

  ["modules/fileintegrity.lua"]     = function() return _addon["_settings"]["ShissuFileIntegrity"] ~= nil end,
  ["modules/chatcommands.lua"]      = function() return _addon["_settings"]["ShissuStandardCommands"] ~= nil end,
  ["modules/language.lua"]          = function() return _addon["_settings"]["ShissuLanguageChanger"] ~= nil end,

  ["settings/checkbox.lua"]         = function() return _addon["templates"]["checkbox"] ~= nil end,
  ["settings/colorpicker.lua"]      = function() return _addon["templates"]["colorpicker"] ~= nil end,
  ["settings/combobox.lua"]         = function() return _addon["templates"]["combobox"] ~= nil end,
  ["settings/description.lua"]      = function() return _addon["templates"]["description"] ~= nil end,
  ["settings/editbox.lua"]          = function() return _addon["templates"]["editbox"] ~= nil end,
  ["settings/title.lua"]            = function() return _addon["templates"]["title"] ~= nil end,
  ["settings/slider.lua"]           = function() return _addon["templates"]["slider"] ~= nil end,
  ["settings/slidereditbox.lua"]    = function() return _addon["templates"]["sliderEditbox"] ~= nil end,
  ["settings/textbox.lua"]          = function() return _addon["templates"]["textbox"] ~= nil end,

  ["interface/coloredbutton.lua"]   = function() return _addon["templates"]["coloredButton"] ~= nil end,
}

local stdColor = "|c82FA58"
local white = "|ceeeeee"

-- Einstellungen; Panelinformationen
function _addon.setPanel(standardName, formattedName, ver, lastUpdate)
  if lastUpdate == nil then
    lastUpdate = "n/A"
  end

  local panel = {
    type    = "panel",
    displayName  = formattedName,
    name    = standardName,
    version = ver,
    lastUpdate = lastUpdate
  }

  return panel
end

-- AddOn/Modul Loader
function _addon.initAddon(addOnName, initFunc, loadedName)
  if ( addOnName == nil ) then return false end

  if ( initFunc ~= nil ) then
    initFunc()

    zo_callLater(function()
      if _addon._settings[addOnName] ~= nil then

      ShissuFramework_Settings.RegisterAddonPanel(addOnName, _addon._settings[addOnName].panel, _addon._settings[addOnName].controls)
      end
    end, 1000);
  end
end


-- Initialize Event
function _addon.EVENT_ADD_ON_LOADED (eventCode, addOnName)
  if addOnName ~= _addon.Name then return end

  zo_callLater(function()
    if(not ShissuFramework["fileIntegrity"].check(_fileList)) then return end
  end, 150)

  -- Event entfernen um Ressourcen zu sparen
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

ShissuFramework = _addon
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)

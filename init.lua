
-- Public API
mines = {}

-- Private API
_mines = {}

_mines.MODPATH = minetest.get_modpath("mines")
_mines.GAMEMODE = ""
_mines.VERSION = "0.1-dev"


dofile(_mines.MODPATH.."/toolbelt.lua")

-- This attempts to detect the gamemode (MTG or one of the MCLs)
if not minetest.registered_nodes["default:stone"] then
    if not minetest.registered_nodes["mcl_core:stone"] then
        _mines.GAMEMODE = "N/A"
    else
        -- Attempt to determine if it's MCL5 or MCL2
        if not minetest.registered_nodes["mcl_deepslate:deepslate"] then
            _mines.GAMEMODE = "MCL2"
        else
            _mines.GAMEMODE = "MCL5"
        end
    end
else
    _mines.GAMEMODE = "MTG"
end

_mines.tools.log("Running gamemode: ".._mines.GAMEMODE)
_mines.tools.log("Running version:  ".._mines.VERSION)

_mines.store = minetest.get_mod_storage()

-- Assign settings (from minetest.conf)
_mines.log_debug = minetest.settings:get_bool("mines_log_debug") or false
_mines.log_notices = minetest.settings:get_bool("mines_log_notices") or false
_mines.process_tick = tonumber(minetest.settings:get("mines_process_tick")) or 1
_mines.autofill_air = minetest.settings:get_bool("mines_autofill_air") or true

-- Initalize API
dofile(_mines.MODPATH.."/api.lua")

-- Dump debug information
if _mines.log_debug then
    _mines.tools.log("- DEBUG OUTPUT -")
    _mines.tools.log("mines_log_debug = "..tostring(_mines.log_debug))
    _mines.tools.log("mines_log_notices = "..tostring(_mines.log_notices))
    _mines.tools.log("mines_process_tick = "..tostring(_mines.process_tick))
    _mines.tools.log("mines_autofill_air = "..tostring(_mines.autofill_air))
else
    _mines.tools.log("Skipping DEBUG OUTPUT...")
end

-- Now to initalize chat commands
dofile(_mines.MODPATH.."/chat_cmd.lua")

-- Now do the globalstep at our mines_process tick rate and regenerate mines that need/trigger regen

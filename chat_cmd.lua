
-- Main formspec
local mainMnu = function (name)
    local formspec = {
        "size[9, 9]",
        "label[0.5,0.5;Mines Setup]",
        "field[0.5,2;4,0.8;name;Name;]",
        "button[3,8.5;3,0.8;save;Save & Quit]",
        "button[6,8.5;3,0.8;exit;Quit]"
    }
    return table.concat(formspec, "")
end

minetest.register_chatcommand("mines_setup", {
    privs = { -- TODO: Add my own priv so mods could gain access to modify mine info
        shout = true,
        server = true
    },
    description = "Central mines command, primarily for setup and editing mine areas",
    func = function (name)
        -- TODO #1 Formspec
        minetest.show_formspec(name, "mines:mine_setup", mainMnu(name))
    end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mines:mine_setup" then
        return
    end

    if fields.save then
        local pname = player:get_player_name()
        _mines.tools.log(""..pname.." chose '"..fields.name.."' for mine name.")
    elseif fields.exit then
    end
end)

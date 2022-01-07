
-- Stores mines that are being developed
local dev_mines = {}

-- Main formspec
local mainMnu = function (name)
    local formspec = ""..
    "size[9, 9]"..
    "label[0.5,0.5;Mines Setup]"..
    "field[0.5,2;4,0.8;name;Name;]"..
    "button[0.5,3;3,0.8;pos1;Positon 1]"..
    "tooltip[pos1;Sets Position 1]"..
    "button[4.5,3;3,0.8;pos2;Positon 2]"..
    "tooltip[pos2;Sets Position 2]"..
    "textarea[0.5,4.5;7,4.5;nodelist;"..minetest.formspec_escape("node:string=percent + newline")..";]"..
    "button_exit[6,8.5;3,0.8;exit;Quit]"
    if dev_mines[name] ~= nil then
        local mine = dev_mines[name]
        formspec = ""..
        "size[9, 9]"..
        "label[0.5,0.5;Mines Editor]"..
        "field[0.5,2;4,0.8;name;Name;"..mine.name.."]"

        if mine.pos1 ~= nil then
            formspec = formspec ..
            "button[0.5,3;3,0.8;pos1;"..mine.pos1.."]"..
            "tooltip[pos1;Sets Position 1]"
        else
            formspec = formspec ..
            "button[0.5,3;3,0.8;pos1;Positon 1]"..
            "tooltip[pos1;Sets Position 1]"
        end
        if mine.pos2 ~= nil then
            formspec = formspec ..
            "button[4.5,3;3,0.8;pos2;"..mine.pos2.."]"..
            "tooltip[pos2;Sets Position 2]"
        else
            formspec = formspec ..
            "button[4.5,3;3,0.8;pos2;Positon 2]"..
            "tooltip[pos2;Sets Position 2]"
        end
        if mine.nodelist ~= nil and mines.nodelist ~= "" then
            formspec = formspec ..
            "textarea[0.5,4.5;7,4.5;nodelist;"..minetest.formspec_escape("node:string=percent + newline")..";"..minetest.formspec_escape(table.concat(mine.nodelist, "\n")).."]"
        else
            formspec = formspec ..
            "textarea[0.5,4.5;7,4.5;nodelist;"..minetest.formspec_escape("node:string=percent + newline")..";]"
        end
        -- Only show the create button once everything is filled in
        if mine.name ~= nil and mine.pos1 ~= nil and mine.pos2 ~= nil and mine.nodelist ~= nil then
            formspec = formspec ..
            "button_exit[0.5,8.5;3,0.8;create;Create]"..
            "tooltip[create;Creates a mine given the form information]"
        end
        formspec = formspec ..
        "button_exit[6,8.5;3,0.8;exit;Quit]"
    end
    return formspec
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

    if fields.name then
        local pname = player:get_player_name()
        _mines.tools.log(""..pname.." chose '"..fields.name.."' for mine name.")
        if dev_mines[pname] == nil then
            local mine = {
                name = fields.name
            }
            dev_mines[pname] = mine
        else
            local mine = dev_mines[pname] 
            mine.name = fields.name
            dev_mines[pname] = mine
        end
    end
    if fields.pos1 then
        local pos = player:get_pos()
        local pname = player:get_player_name()
        if dev_mines[pname] ~= nil then
            dev_mines[pname].pos1 = _mines.tools.pos2str(pos)
            _mines.tools.log(""..pname.." set pos1 to ".._mines.tools.pos2str(pos).." for mine called '"..dev_mines[pname].name.."'.")
            minetest.show_formspec(pname, "mines:mine_setup", mainMnu(pname)) -- Update the formspec
        end
    end
    if fields.pos2 then
        local pos = player:get_pos()
        local pname = player:get_player_name()
        if dev_mines[pname] ~= nil then
            dev_mines[pname].pos2 = _mines.tools.pos2str(pos)
            _mines.tools.log(""..pname.." set pos2 to ".._mines.tools.pos2str(pos).." for mine called '"..dev_mines[pname].name.."'.")
            minetest.show_formspec(pname, "mines:mine_setup", mainMnu(pname)) -- Update the formspec
        end
    end
    if fields.nodelist then
        local pname = player:get_player_name()
        local mine = dev_mines[pname]
        local nodes = _mines.tools.split(fields.nodelist, "\n")
        if mine ~= nil then
            mine.nodelist = nodes
            _mines.tools.log(""..pname.." sets "..tostring(#nodes).." nodes for mine called '"..mine.name.."'.")
        end
    end
    if fields.create then
        local pname = player:get_player_name()
        local mine = dev_mines[pname]
        if mine ~= nil then
            mines.create_mine(mine.name, mine.pos1, mine.pos2, mine.nodelist, 60)
            local sizex = math.abs(_mines.tools.str2pos(mine.pos1).x - _mines.tools.str2pos(mine.pos2).x)
            local sizey = math.abs(_mines.tools.str2pos(mine.pos1).y - _mines.tools.str2pos(mine.pos2).y)
            local sizez = math.abs(_mines.tools.str2pos(mine.pos1).z - _mines.tools.str2pos(mine.pos2).z)
            local size = {x = sizex, y = sizey, z = sizez}
            _mines.tools.log(""..pname.." creates '"..mine.name.."' with as size of ".._mines.tools.pos2str(size).." and "..tostring(#mine.nodelist).." nodes.")
            dev_mines[pname] = nil
        end
    end
end)

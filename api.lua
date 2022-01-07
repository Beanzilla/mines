
local api = mines

-- Creates a mine given it's name, it's positions, it's list of nodes and their percents, and it's rate at which to regenerate in
api.create_mine = function (mine_name, posA, posB, node_list, regen)
    if _mines.tools.addPercent(node_list) > 100 then
        _mines.tools.log("Percent exceeds 100, got "..tonumber(_mines.tools.addPercent(node_list)).."%")
        return {success=false, errmsg="Percent exceeds 100, got "..tonumber(_mines.tools.addPercent(node_list)).."%", val=nil}
    end
    local m = minetest.deserialize(_mines.store:get_string("mines")) or {}
    m[mine_name] = {
        nodes= node_list, -- "node:name=percent", ...
        posA= posA, -- Point 1
        posB= posB, -- Point 2
        regen= regen, -- How many "ticks" till this mine regenerates
        timer=0, -- Current time (Set to regen when 0 or below 0, then spawn in terrain)
        tp= "", -- If defined, where to place players who were in the mine while it was about to regenerate
        -- Should I also add owner? (maybe that as a priv?)
        -- Just like spawning to this mine via /mines <mine_name> (omit mine_name to get list of mines) 
        -- Using priv for spawning to particular mines? (maybe)
    }
    _mines.store:set_string("mines", minetest.serialize(m))
    return {success=true, errmsg="", val=nil}
end

-- Removes a mine and ALL it's data, just given the mine's name
api.remove_mine = function (mine_name)
    local m = minetest.deserialize(_mines.store:get_string("mines")) or {}
    if _mines.tools.tableContainsValue(m, mine_name) then
        local idx = 1
        for ind, val in pairs(m) do
            if ind == mine_name then
                break
            end
            idx = idx + 1
        end
        table.remove(m, idx)
        _mines.store:set_string("mines", minetest.serialize(m))
        return {success=true, errmsg="", val=nil}
    end
    _mines.tools.log("Failed removing mine called '"..mine_name.."', wasn't found.")
    return {success=false, errmsg="Failed removing mine called '"..mine_name.."', wasn't found.", val=nil}
end

-- Returns ALL of the mine's data, just given the mine's name
api.info_mine = function (mine_name)
    local m = minetest.deserialize(_mines.store:get_string("mines")) or {}
    if _mines.tools.tableContainsValue(m, mine_name) then
        return {success=true, errmsg="", val=m[mine_name]}
    end
    _mines.tools.log("Failed getting info on mine called '"..mine_name.."', wasn't found.")
    return {success=false, errmsg="Failed getting info on mine called '"..mine_name.."', wasn't found.", val=nil}
end

-- Sets the teleport point for spawning to a public mine and used to teleport players out of a mine that's regenerating
-- Just give it the mine's name and the position
api.set_mine_tp = function (mine_name, pos)
    local m = minetest.deserialize(_mines.store:get_string("mines")) or {}
    if _mines.tools.tableContainsValue(m, mine_name) then
        m[mine_name].tp = _mines.tools.pos2str(pos)
        _mines.store:set_string("mines", minetest.serialize(m))
        return {success=true, errmsg="", val=nil}
    end
    _mines.tools.log("Failed setting mine teleport on mine called '"..mine_name.."', wasn't found.")
    return {success=false, errmsg="Failed setting mine teleport on mine called '"..mine_name.."', wasn't found.", val=nil}
end

-- Adds a node to a mine, given mine's name, node's itemstring and node's percent chance to be spawned in
api.add_node = function (mine_name, node, perc)
    local m = minetest.deserialize(_mines.store:get_string("mines")) or {}
    if _mines.tools.tableContainsValue(m, mine_name) then
        local tmp_nodes = m[mine_name].nodes or {}
        table.insert(tmp_nodes, tostring(node).."="..tostring(_mines.tools.makePercent(perc)))
        local tmp_perc = _mines.tools.addPercent(tmp_nodes)
        if tmp_perc > 100 then
            _mines.tools.log("Percent exceeds 100, got "..tostring(tmp_perc).."%")
            return {success=false, errmsg="Percent exceeds 100, got "..tostring(tmp_perc).."%", val=nil}
        end
        m[mine_name].nodes = tmp_nodes
        _mines.store:set_string("mines", minetest.serialize(m))
        return {success=true, errmsg="", val=nil}
    end
    _mines.tools.log("Failed adding a node into mine called '"..mine_name.."', wasn't found.")
    return {success=false, errmsg="Failed adding a node into mine called '"..mine_name.."', wasn't found.", val=nil}
end

-- Removes a node from a mine, given mine's name and node's itemstring
api.remove_node = function (mine_name, node)
    local m = minetest.deserialize(_mines.store:get_string("mines")) or {}
    if _mines.tools.tableContainsValue(m, mine_name) then
        local tmp_nodes = m[mine_name].nodes or {}
        local idx = -1
        for idex, value in ipairs(tmp_nodes) do
            tmp_val = _mines.tools.split(value, "=")
            if _mines.tools.contains(tmp_val, node) then
                idx = idex
            end
        end
        if idx ~= -1 then
            table.remove(tmp_nodes, idex)
            m[mine_name].nodes = tmp_nodes
            _mines.store:set_string("mines", minetest.serialize(m))
            return {success=true, errmsg="", val=nil}
        else
            _mines.tools.log("Failed removing node '"..node.."' from '"..mine_name.."', as node wasn't found.")
            return {success=false, errmsg="Failed removing node '"..node.."' from '"..mine_name.."', as node wasn't found.", val=nil}
        end
    end
    _mines.tools.log("Failed adding a node into mine called '"..mine_name.."', wasn't found.")
    return {success=false, errmsg="Failed adding a node into mine called '"..mine_name.."', wasn't found.", val=nil}
end

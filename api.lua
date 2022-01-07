
local api = mines

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
    }
    _mines.store:set_string("mines", minetest.serialize(m))
    return {success=true, errmsg="", val=nil}
end

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

api.info_mine = function (mine_name)
    local m = minetest.deserialize(_mines.store:get_string("mines")) or {}
    if _mines.tools.tableContainsValue(m, mine_name) then
        return {success=true, errmsg="", val=m[mine_name]}
    end
    _mines.tools.log("Failed getting info on mine called '"..mine_name.."', wasn't found.")
    return {success=false, errmsg="Failed getting info on mine called '"..mine_name.."', wasn't found.", val=nil}
end

api.set_mine_tp = function (mine_name, pos)
    local m = minetest.deserialize(_mines.store:get_string("mines")) or {}
    if _mines.tools.tableContainsValue(m, mine_name) then
        m[mine_name].tp = _mines.tools.pos2str(pos)
        _mines.store:set_string("mines", minetest.serialize(m))
        return {success=true, errmsg="", val=nil}
    end
    _mines.tools.log("Failed setting mine teleport on mine called '"..mine_name.."', wasn't found.")
    return {success=false, errmsg="Failed setting mine teleport on mine called '"..mine_name.."', wasn't found."}
end

api.add_node = function (mine_name, node, perc)
    local m = minetest.deserialize(_mines.store:get_string("mines")) or {}
    if _mines.tools.tableContainsValue(m, mine_name) then
        local tmp = m[mine_name].nodes or {}
        table.insert(tmp, tostring(node).."="..tostring(_mines.tools.makePercent(perc)))
        local tmp_perc = _mines.tools.addPercent(tmp)
        if tmp_perc > 100 then
            _mines.tools.log("Percent exceeds 100, got "..tostring(tmp_perc).."%")
            return {success=false, errmsg="Percent exceeds 100, got "..tostring(tmp_perc).."%", val=nil}
        end
        m[mine_name].nodes = tmp
        _mines.store:set_string("mines", minetest.serialize(m))
        return {success=true, errmsg="", val=nil}
    end
    _mines.tools.log("Failed adding a node into mine called '"..mine_name.."', wasn't found.")
    return {success=false, errmsg="Failed adding a node into mine called '"..mine_name.."', wasn't found."}
end

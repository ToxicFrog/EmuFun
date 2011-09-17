function emufun.loadgames()
    eprintf("Reading game library: ")
    emufun.root = node.new(arg[2] or os.getenv("GAMEDIR") or emufun.GAMEDIR)
    if not emufun.root:type() then
        -- can't find game directory, oops
        eprintf("failed!\n")
        return emufun.filenotfound("Directory is missing or inaccessible")
    end
    
    -- we use a filter here that excludes files, so that you can - for example
    -- keep emufun.love in the same root directory your media categories are
    -- in.
    local function filter_type(path, item)
        return lfs.attributes(path, "mode") == "directory"
    end
    
    emufun.root:populate(filter_type)
    for sys in emufun.root:children() do
        sys:populate()
    end
    
    if not emufun.root[1] then
        -- we couldn't find anything in the gamedir!
        eprintf("failed!\n")
        return emufun.filenotfound("Directory is empty")
    end
    eprintf("done\n")
    
    return emufun.gamelist()
end

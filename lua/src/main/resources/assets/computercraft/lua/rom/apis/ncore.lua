--[[
Description:
    Determines if the argument is a modem.
    "When I see a bird that walks like a duck and swims like a duck and quacks like a duck, I call that bird a duck." --James Whitcomb Riley
--]]
function isModem(modem)
    function helper(tbl,key)
        return tbl[key] and "function" == type(tbl[key])
    end

    if modem then
        if "table" == type(modem) then
            if not helper(modem, "isOpen") then return false end
            if not helper(modem, "open") then return false end
            if not helper(modem, "close") then return false end
            if not helper(modem, "closeAll") then return false end
            if not helper(modem, "transmit") then return false end
            if not helper(modem, "isWireless") then return false end
            return true
        end
    end
    return false
end

--[[
Description:
    Takes as input any wrapped modem, and opens it for communication without having to specify which side it is on.
    This is a convienience for opening on the computer's channel and the broadcast channel.
    It should be noted that the computer id is the channel, which is why modems are not secure
TODO:
    Validate that what is passed in is a wrapped modem
Source:
    Taken from the rednet api by dan200 for the open function, which takes a side as input instead.
--]]
function openModem(modem)
    if not isModem(modem) then
        error("A modem must be passed in to be opened.", 2)
    end
    modem.open(os.getComputerID())
    modem.open(rednet.CHANNEL_BROADCAST)
end

--[[
Description:
    Takes as input any wrapped modem, and opens it for communication without having to specify which side it is on.
    This is a convienience for opening on the computer's channel and the broadcast channel.
    It should be noted that the computer id is the channel, which is why modems are not secure
TODO:
    Validate that what is passed in is a wrapped modem
Source:
    Taken from the rednet api by dan200 for the close function, which takes a side as input instead
--]]
function closeModem(modem)
    if not isModem(modem) then
        error("A modem must be passed in to be closed.", 2)
    end
    modem.close(os.getComputerID())
    modem.close(rednet.CHANNEL_BROADCAST)
end

--[[
Description:
    Returns true if what was passed in is a modem that is open for communicating on the standard channels.
Source:
    Taken from the rednet api by dan200 for the isOpen function, which takes a side as input instead.
--]]
function isOpenModem(modem)
    if not isModem(modem) then
        return false
    end
    return modem.isOpen(os.getComputerID()) and modem.isOpen(CHANNEL_BROADCAST)
end

--[[
Description:
    Wrapper around the wrap function in the rednet api by dan200. This function embeds extra details
    in the returned table. Everything else about the return value is the same as that returned by
    peripheral.wrap
--]]
function pwrap( _sSide, _pType )
    local p = peripheral.wrap( _sSide )
    if p then
        _pType = _pType or peripheral.getType( _sSide )
        local miscInfo = { pside = _sSide, ptype = _pType }
        p.pinfo = miscinfo
    end
    return p
end

--[[
Description:
    Looks for all peripherals of the specified type, which can further be qualified by passing in about
    function taking a side and the wrapped peripheral as arguments. This uses pwrap to embed some
    extra information into the wrapped peripheral for later use.
Source:
    Taken from the peripheral api by dan200 for the find function.
--]]
function pfind( sType, fnFilter )
    if type( sType ) ~= "string" or (fnFilter ~= nil and type( fnFilter ) ~= "function") then
        error( "Expected string, [function]", 2 )
    end
    local tResults = {}
    for n,sName in ipairs( peripheral.getNames() ) do
        if peripheral.getType( sName ) == sType then
            local wrapped = pwrap( sName, sType )
            if fnFilter == nil or fnFilter( sName, wrapped ) then
                table.insert( tResults, wrapped )
            end
        end
    end
    return table.unpack( tResults )
end

--[[
Description:
    The function print_r takes anything as input, and pretty prints it to the console.
Source:
    Taken from https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
--]]
function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

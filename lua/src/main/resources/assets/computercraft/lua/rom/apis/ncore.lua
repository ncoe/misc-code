------------------------------------------------------------------------------------------------------------------------
-- Debug Helpers
------------------------------------------------------------------------------------------------------------------------

DEBUG_FLAG = "debug_flag"

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

------------------------------------------------------------------------------------------------------------------------
-- Event Handling API
------------------------------------------------------------------------------------------------------------------------

--- string: the letter types
EVENT_CHAR = "char"
--- number: keycode; boolean: being held
EVENT_KEY = "key"
--- number: keycode
EVENT_KEY_UP = "key_up"
--- string: clipboard text
EVENT_PASTE = "paste"
--- number: value returned by os.startTimer
EVENT_TIMER = "timer"
--- number: Value returned by os.setAlarm
EVENT_ALARM = "alarm"
--- number: taskID; boolean success; string: error; any: param1 etc...
EVENT_TASK_COMPLETE = "task_complete"
--- no args
EVENT_REDSTONE = "redstone"
--- no args
EVENT_TERMINATE = "terminate"
--- string: side
EVENT_DISK = "disk"
--- string: side
EVENT_DISK_EJECT = "disk_eject"
--- string: side
EVENT_PERIPHERAL = "peripheral"
--- string: side
EVENT_PERIPHERAL_DETACH = "peripheral_detach"
--- number: senderID; any: message; string: protocol or number: distance travelled
EVENT_REDNET_MESSAGE = "rednet_message"
--- string: side; number: frequency; number: reply frequency; any: message; number: distance travelled
EVENT_MODEM_MESSAGE = "modem_message"
--- string: url of site; table: text of site
EVENT_HTTP_SUCCESS = "http_success"
--- string: url of site
EVENT_HTTP_FAILURE = "http_failure"
--- number: mouse button; number: x; number: y
EVENT_MOUSE_CLICK = "mouse_click"
--- number: mouse button; number: x; number: y
EVENT_MOUSE_UP = "mouse_up"
--- number: scroll dir (-1=up 1=down); number: x; number: y
EVENT_MOUSE_SCROLL = "mouse_scroll"
--- number: mouse button; number: x; number: y
EVENT_MOUSE_DRAG = "mouse_drag"
--- string: side; number: x; number: y
EVENT_MONITOR_TOUCH = "monitor_touch"
--- string: side
EVENT_MONITOR_RESIZE = "monitor_resize"
--- no args
EVENT_TERM_RESIZE = "term_resize"
--- no args
EVENT_TURTLE_INVENTORY = "turtle_inventory"

--- A table to hold the event names and functions to call when the events are raised
registeredEvents = {}

--- Registers an event function to the event that should trigger it. Returns the function for convienience.
function registerEvent(eventName, eventFunc)
    if "string" ~= type(eventName) then
        error("Expected the event name to be a string", 2)
    end
    if "function" ~= type(eventFunc) then
        error("Expected to be provided a function to call", 2)
    end

    if _G[DEBUG_FLAG] then
        print("Registering an event for: "..eventName)
    end

    local eventArray = registeredEvents[eventName]
    if eventArray then
        table.insert(eventArray, eventFunc)
    else
        registeredEvents[eventName] = { eventFunc }
    end

    return eventFunc
end

--- Stops using a function to listen to an event. Returns true if the function was found in the registered event handlers.
function cancelEvent(eventFunc, eventName)
    if "function" ~= type(eventFunc) then
        error("Expected to be provided a function to call", 2)
    end

    local function helper(en,needle,haystack)
        local removed = false
        if needle and haystack then
            for idx,ef in pairs(haystack) do
                if needle == ef then
                    if _G[DEBUG_FLAG] then
                        print("Cancelling an event for: "..eventName)
                    end

                    table.remove(haystack,idx)
                    removed = true
                    break
                end
            end
        end
        return removed
    end

    local removed = false
    if eventName then
        if "string" ~= type(eventName) then
            error("Expected the event name to be a string", 2)
        end

        local eventArray = registeredEvents[eventName]
        removed = helper(eventName, eventFunc, eventArray)
        if removed and 0 == table.getn(eventArray) then
            registeredEvents[eventName] = nil
        end
    else
        for en,eventArray in pairs(registeredEvents) do
            removed = helper(en, eventFunc, eventArray) or removed
            if removed and 0 == table.getn(eventArray) then
                registeredEvents[en] = nil
            end
        end
    end

    return removed
end

--- Listens for events, and dispatches them to the provided functions. Can also be terminated by raising a "kill-9" event.
function runEventLoop()
    if _G[DEBUG_FLAG] then
        print("--- Starting event loop ---")
    end

    while true do
        -- pullEventRaw is being used to also allow for termination code
        local event = { os.pullEventRaw() }

        if _G[DEBUG_FLAG] then
            print_r(event)
        end

        local eventName = event[1]
        local funcArray = registeredEvents[eventName]
        if funcArray then
            for _,eventFunc in pairs(funcArray) do
                eventFunc(unpack(event))
            end
        end

        -- Fun fact: If you do not break on "terminate", then the loop will execute until the computer is shutdown.
        if "terminate" == eventName or "kill-9" == eventName then
            break
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
-- ComputerCraft additional API defintions
------------------------------------------------------------------------------------------------------------------------

--[[
Description:
    Determines if the argument is a modem.
    "When I see a bird that walks like a duck and swims like a duck and quacks like a duck, I call that bird a duck." --James Whitcomb Riley
--]]
function isModem(modem)
    local function helper(tbl,key)
        return tbl[key] and "function" == type(tbl[key])
    end

    if modem then
        if "table" == type(modem) then
            if modem.pinfo then
                return "modem" == modem.pinfo.ptype
            end

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
        p.pinfo = { pside = _sSide, ptype = _pType }
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
    for _,sName in ipairs( peripheral.getNames() ) do
        if peripheral.getType( sName ) == sType then
            local wrapped = pwrap( sName, sType )
            if fnFilter == nil or fnFilter( sName, wrapped ) then
                table.insert( tResults, wrapped )
            end
        end
    end
    return table.unpack( tResults )
end

--[[
--This program demonstrates the event api that has been built into ncore.
--]]

local loaded = ncore or os.loadAPI("ncore")
assert(loaded, "Unable to access required API: ncore")

function key_event_1(en,key,_)
    assert(ncore.EVENT_KEY==en, "This is a key event handler")

    if key then
        local name = keys.getName(key)
        if name then
            print("You pressed key: " .. name)
        end
    end

    ncore.registerEvent(ncore.EVENT_KEY, key_event_2)
    ncore.cancelEvent(key_event_1, ncore.EVENT_KEY)
end

function key_event_2(en,key,_)
    assert(ncore.EVENT_KEY==en, "This is a key event handler")

    if key then
        local name = keys.getName(key)
        if name then
            print("I saw you press: " .. name)
        end
    end

    ncore.registerEvent(ncore.EVENT_KEY, key_event_1)
    ncore.cancelEvent(key_event_2, ncore.EVENT_KEY)
end

function char_event(_,key)
    print(key)
end

function terminate_event()
    print("Banzai!!")
end

ncore.registerEvent(ncore.EVENT_KEY, key_event_1)
ncore.registerEvent(ncore.EVENT_CHAR, char_event)
ncore.registerEvent(ncore.EVENT_TERMINATE, terminate_event)

ncore.runEventLoop()

print("Thats all folks")

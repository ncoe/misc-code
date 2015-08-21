--[[
This is a simple program that can either be used as part of a resource pack, or as a normal program.
This program will open a modem if one exists and broadcast a message to all listening computers. If
the API that it depends on is not loaded automatically by being in a resource pack, it will be loaded
with a call to loadAPI instead.
--]]

local m = assert(peripheral.find("modem"), "Could not find a modem attached. Please attach a modem before running this program.")

local loaded = ncore or os.loadAPI("ncore")
assert(loaded, "Unable to access required API: ncore")

ncore.openModem(m)
rednet.broadcast("hey, listen", "navi")
ncore.closeModem(m)

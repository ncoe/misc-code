--This script is originally from modifications done by neonerZ to a script origonally done by BigSHinyToys from ComputerCraft.info
--Original link can be found here:
--http://www.computercraft.info/forums2/index.php?/topic/3088-how-to-guide-gps-global-position-system/page__p__28333#entry28333
--------------------------------------------------------------------------

local loaded = ncore or os.loadAPI("ncore")
assert(loaded, "Unable to access required API: ncore")

ncore.requireTurtle()

--------------------------------------------------------------------------
--- Handle globals and argument parsing
--------------------------------------------------------------------------

local height = 255
local function printUsage()
    print("")
    print( "Usages:" )
    print( "gps-deploy <x> <z>" )
    print( "Example: gps-deploy 1 1")
    print( "gps-deploy locate")
    print( "if you have working GPS use this")
    print( "to find out the coords over GPS")
end

local tArgs = { ... }

local xcord, ycord, zcord
if tArgs[1] == "locate" then
    print("Locating GPS signal...")
    xcord, ycord, zcord = gps.locate(5, false)
    if xcord == nil then
        print("")
        print("No GPS signal detected, please rerun manually")
        return
    end
    print("gps-deploy ", xcord, " ", ycord, " ", zcord)
    xcord = tonumber(xcord)
    ycord = tonumber(ycord)
    zcord = tonumber(zcord)
else
    if #tArgs < 2 then
        printUsage()
        return
    end
    xcord = tonumber(tArgs[1])
    zcord = tonumber(tArgs[2])
end

--------------------------------------------------------------------------
--- Check for require items in the inventory
--------------------------------------------------------------------------

local computer = false
local modem = false
local diskdrive = false
local disk = false

-- References
-- ComputerCraft:CC-Computer:0      Normal Computer
-- ComputerCraft:CC-Computer:16384  Advanced Computer
-- ComputerCraft:CC-Peripheral:0    Disk Drive
-- ComputerCraft:CC-Peripheral:1    Wireless Modem
-- ComputerCraft:diskExpanded:0     Floppy Disk (several colors of it)
-- ComputerCraft:disk:0             Floppy Disk
-- EnderStorage:enderChest:*        Ender chest, metadata encodes the colors

local tempCnt = ncore.countItem("ComputerCraft:CC-Computer", 0)
tempCnt = tempCnt + ncore.countItem("ComputerCraft:CC-Computer", 16384)
if tempCnt < 4 then
    print("Please place at least 4 computers into the inventory")
    computer = true
end

if not ncore.hasItem("ComputerCraft:CC-Peripheral", 1, 4) then
    print("Please place at least 4 wireless modems into the inventory")
    modem = true
end

if not ncore.hasItem("ComputerCraft:disk") and not ncore.hasItem("ComputerCraft:diskExpanded") then
    print("Please place a disk into the inventory")
    disk = true
end

-- TODO figure out if it is possible to detect equipped items
if not ncore.hasItem("ComputerCraft:CC-Peripheral", 0, 1) then
    print("Please place a disk drive into the\n", "  inventory -mining turtle-")
    print("Please place 4 disk drives into the\n", "  inventory -standard turtle-")
    diskdrive = true
end

if computer or modem or diskdrive or disk then
    print("Please fix above issues to continue")
    return
end

print("TODO -- Do work to deploy the new GPS satellite")

print("Finished")

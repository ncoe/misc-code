--This script is originally from modifications done by neonerZ to a script origonally done by BigSHinyToys from ComputerCraft.info
--Original link can be found here:
--http://www.computercraft.info/forums2/index.php?/topic/3088-how-to-guide-gps-global-position-system/page__p__28333#entry28333
--------------------------------------------------------------------------
-- NOTE: Assumes that the turtle is facing the positive z-axis
--------------------------------------------------------------------------

local DEBUG = false
local loaded = ncore or os.loadAPI("ncore")
assert(loaded, "Unable to access required API: ncore")

ncore.requireTurtle()

--------------------------------------------------------------------------
--- Handle globals and argument parsing
--------------------------------------------------------------------------

local function printUsage()
    print("")
    print("Usages:")
    print("gps-deploy <x> <z>")
    print("Example: gps-deploy 1 1")
    print("gps-deploy locate")
    print("if you have working GPS use this")
    print("to find out the coords over GPS")
end

local tArgs = { ... }

local xcord, zcord
if tArgs[1] == "locate" then
    print("Locating GPS signal...")
    local ycord
    xcord, ycord, zcord = gps.locate(5, false)
    if xcord == nil then
        print("")
        print("No GPS signal detected, please rerun manually")
        return
    end
    print("gps-deploy ", xcord, " ", ycord, " ", zcord)
    xcord = tonumber(xcord)
    zcord = tonumber(zcord)
else
    if #tArgs < 2 then
        printUsage()
        return
    end
    xcord = tonumber(tArgs[1])
    zcord = tonumber(tArgs[2])
end

if DEBUG then
    print("Deploying constallation centered on (", xcord, ",", zcord, ")")
end

--------------------------------------------------------------------------
--- Check for require items in the inventory
--------------------------------------------------------------------------

local computer = false
local modem = false
local diskdrive = false
local disk = false

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

if      not ncore.hasItem("ComputerCraft:disk")
        and not ncore.hasItem("ComputerCraft:diskExpanded")
then
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

-- Set the coordinate for deployment
local set = {}
set[1] = { x = tonumber(xcord),     z = tonumber(zcord) + 3, y = 254 }
set[2] = { x = tonumber(xcord) - 3, z = tonumber(zcord),     y = 251 }
set[3] = { x = tonumber(xcord),     z = tonumber(zcord) - 3, y = 254 }
set[4] = { x = tonumber(xcord) + 3, z = tonumber(zcord),     y = 251 }

if DEBUG then
    print("Constallation positions:\n")
    ncore.print_r(set)
end

-- Begin climb
local altitude = -1
local limit = 1000
while ncore.moveUp() and altitude < limit do
    altitude = altitude + 1
end
ncore.moveDown()

-- TODO: This may assume that the turtle is facing a specific direction
-- Deploy, assumes facing +Z direction
for sat = 1, 4 do
    if not ncore.moveForward(2) then
        print("L1. Could not move forward 2")
        return
    end

    -- Pick a computer, any computer
    if not ncore.placeItem("ComputerCraft:CC-Computer") then
        if not ncore.placeItem("ComputerCraft:CC-Computer", 16384) then
            print("L2. Failed to find a computer to place.")
            return
        end
    end

    if not ncore.moveBackward() then
        print("L3. Could not move backward")
        return
    end

    -- Modem
    if not ncore.placeItem("ComputerCraft:CC-Peripheral", 1) then
        print("L4. Could not find a modem to place")
        return
    end

    if not ncore.moveDown() then
        print("L5. Could not move down")
        return
    end
    if not ncore.moveForward() then
        print("L6. Could not move forward")
        return
    end

    -- Disk Drive
    if not ncore.placeItem("ComputerCraft:CC-Peripheral") then
        print("L7. Could not place a disk drive")
        return
    end

    -- Insert a disk
    if      not ncore.selectItem("ComputerCraft:disk")
            and not ncore.selectItem("ComputerCraft:diskExpanded")
    then
        print("L8. Could not select a disk")
        return
    end
    if not turtle.drop() then
        print("L9. Could not insert a disk")
        return
    end

    -- make a custom disk that starts up the gps host application
    -- with the correct coordinates and copy it over. Also makes
    -- a startup script so the computers will start back up properly
    -- after chunk unloading
    -- NOTE: disk2 is the how the turtle places programs where the computer can copy them from
    --       disk is local to what an individual computer can see

    fs.delete("disk2/startup")
    local file = fs.open("disk2/startup", "w")
    file.write([[
fs.copy("disk/install", "startup")
fs.delete("disk/startup")
print("sleep in 10")
sleep(10)
os.reboot()
]])
    file.flush()
    file.close()

    file = fs.open("disk2/install", "w")
    file.write([[shell.run("gps", "host", ]] .. set[sat].x .. ", " .. set[sat].y .. ", " .. set[sat].z .. [[)]])
    file.flush()
    file.close()

    turtle.turnLeft()
    if not ncore.moveForward() then
        print("LA. Could not move forward")
        return
    end
    if not ncore.moveUp() then
        print("LB. Could not move up")
        return
    end
    turtle.turnRight()
    if not ncore.moveForward() then
        print("LC. Could not move forward")
        return
    end
    turtle.turnRight()

    peripheral.call("front", "turnOn")

    if not ncore.moveDown() then
        print("LD. Could not move down")
        return
    end

    -- Eject the disk
    if not turtle.suck() then
        print("LE. Could not eject disk")
        return
    end

    if not turtle.dig() then
        print("LF. Could not reclaim disk drive")
    end
    if not ncore.moveUp() then
        print("LG. Could not move up")
        return
    end
    -- reboot would be here
    turtle.turnRight()
    if not ncore.moveForward(3) then
        print("LH. Could not move forward 3")
        return
    end
    turtle.turnLeft()
    if not ncore.moveForward() then
        print("LI. Could not move forward")
        return
    end

    if sat == 1 or sat == 3 then
        if not ncore.moveDown(3) then
            print("LJ. Could not move down 3")
            return
        end
    elseif sat == 2 or sat == 4 then
        if not ncore.moveUp(3) then
            print("LK. Could not move up 3")
            return
        end
    else
        print("Reached unreachable code");
    end
end

ncore.moveDown(altitude)
print("Finished")

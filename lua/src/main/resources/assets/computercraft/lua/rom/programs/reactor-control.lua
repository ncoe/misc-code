local MAX_REACTOR_POWER_STORAGE = 10000000
local MAX_TURBINE_POWER_STORAGE =  1000000

function fmtNum(val)
    assert("number"==type(val))
    return math.floor(100*val)/100
end

function debugCurrentStats(r)
    if r and r.getConnected() then
        es = r.getEnergyStored()
        ep = r.getEnergyProducedLastTick()

        fa = r.getFuelAmount()
        fax = r.getFuelAmountMax()

        print("Active: " .. tostring(r.getActive()))
        print("Energy Produced: " .. ep)
        print("Energy stored: " .. es)
        pes = 100 * es / MAX_REACTOR_POWER_STORAGE
        print(string.format("%%Energy: %s", fmtNum(pes)))
        print("Fuel amount: " .. fa)
        pfa = 100 * fa / fax
        print(string.format("%%Fuel: %s", fmtNum(pfa)))
        print()
        print("Press [q] to terminate...")
    end
end

function manageReactorStep(r)
    if r and r.getConnected() then
        ps = r.getEnergyStored() / MAX_REACTOR_POWER_STORAGE

        if r.getActive() then
            if ps > 0.9 then
                r.setAllControlRodLevels(100)
                r.setActive(false)
            elseif ps > 0.8 then
                r.setAllControlRodLevels(95)
            elseif ps > 0.2 then
                level = math.floor(150*ps-25)
                r.setAllControlRodLevels(level)
            end
        else
            if ps < 0.2 then
                r.setActive(true)
                r.setAllControlRodLevels(0)
            end
        end
    end
end

----------------------------------------------------------------------------------------------------

local rtor = assert(peripheral.find("BigReactors-Reactor"), "Could not find a reactor on the network. Connect a modem to a reactor computer port before running.")
if not rtor.getConnected() then
    print("The reactor is not connected, quiting")
    return
end

if rtor.isActivelyCooled() then
    local turb = assert(peripheral.find("BigReactors-Turbine"), "Could not find a turbine on the network. Connect a modem to a turbine computer port before continuing.")
    if not turb.getConnected() then
        print("The turbine is not connected, quiting")
        return
    end

    print("Turbines are not yet supported, quiting.")
    return
end

local done = false
repeat
    manageReactorStep(rtor)
    shell.run("clear")
    debugCurrentStats(rtor)

    local timer,key = os.startTimer(0.5)
    local event = os.pullEventRaw()
    if "terminate"==event or ("key"==event --[[and keys.q==key--]]) then
        rtor.setAllControlRodLevels(100)
        done = true
    end
until done





--[[
getConnected
    Returns true if the computer is connected to a valid reactor
getEnergyProducedLastTick
    Either energy or fluid produced
isActivelyCooled
    Used to seperate energy reactors(false) from steam reactors(true)
    
keep heat below  200C for no penalty on fuel consumption
keep heat below 1000C for a 10% penalty on fuel consumption
keep heat below 2000C for a 66% penalty on fuel consumption

energy max for a reactor is 10_000_000
energy max for a turbine is  1_000_000

http://br.sidoh.org/#reactor-design?length=6&width=6&height=5&activelyCooled=false&controlRodInsertion=48&layout=2O2E4O2E2O2E2X4E2X2E2O2E4O2E2O
666.46C     6686.17RF/t    0.07mB/t    427.27%     97931.86RF/mB
http://br.sidoh.org/#reactor-design?length=7&width=7&height=5&activelyCooled=false&controlRodInsertion=20&layout=3OE6OE6OE3O3EX3E3OE6OE6OE3O
197.58C     2356.30RF/t    0.11mB/t    100.00%     21136.45RF/mB
http://br.sidoh.org/#reactor-design?length=8&width=8&height=5&activelyCooled=false&controlRodInsertion=24&layout=3O2E6O2E6O2E3O3E2X6E2X3E3O2E6O2E6O2E3O
686.14C     9845.54RF/t    0.09mB/t    449.19%    104037.61RF/mB
http://br.sidoh.org/#reactor-design?length=9&width=9&height=5&activelyCooled=false&controlRodInsertion=52&layout=3O3E6O3E6O3E3O3E3X6EXEX6E3X3E3O3E6O3E6O3E3O
727.26C    13115.11RF/t    0.12mB/t    466.27%    113849.24RF/mB
http://br.sidoh.org/#reactor-design?length=10&width=10&height=5&activelyCooled=false&controlRodInsertion=41&layout=4O2E8O2E8O2E8O2X4O3EX2EX6EX2EX3E4O2X8O2E8O2E8O2E4O
650.88C    13454.17RF/t    0.15mB/t    440.39%    113824.04RF/mB
http://br.sidoh.org/#reactor-design?length=12&width=12&height=5&activelyCooled=false&controlRodInsertion=82&layout=2O8E4O8E2O3E6X5EX6EX4EX6EX4EX2E2X2EX4EX2E2X2EX4EX6EX4EX6EX5E6X3E2O8E4O8E2O
623.79C    18497.85RF/t    0.15mB/t    469.64%    123140.47RF/mB
http://br.sidoh.org/#reactor-design?length=18&width=18&height=5&activelyCooled=false&controlRodInsertion=83&layout=4O10E8O10E8O10E8O10X4O3EX4O2E4OX6EX4O2E4OX6EX4O2E4OX6EX4O2X4OX6EX3EX2EX3EX6EX3EX2EX3EX6EX4O2X4OX6EX4O2E4OX6EX4O2E4OX6EX4O2E4OX3E4O10X8O10E8O10E8O10E4O
528.71C    27778.96RF/t    0.23mB/t    492.93%    119877.63RF/mB

y=150x-25=25(6x-1)
--]]

--[[
Reactor documentation
--------------------------
Method Name
            Arguments
            Return Type
            Description 


getActive
            None
            Boolean
            Returns true if the reactor is active (consuming fuel and generating power), false otherwise.
setActive
            Boolean: active?
            None
            Sets the reactor to be active if the argument is true, or inactive if the argument is false


getCasingTemperature
            None
            Integer
            Returns the temperature of the Multiblock Reactor's casing/frame, in degrees Centigrade.


getConnected
            None
            Boolean
            Returns true if the computer port is connected to a valid Multiblock Reactor.


getControlRodLevel
            Integer: control rod index
            Integer
            Returns an integer indicating how far the specified control rod is inserted into the reactor, range is from 0 (not inserted) to 100 (fully inserted)
getControlRodName
            Integer: control rod index
            String
            Returns the user-set name for the specified control rod, as a string. String is empty if the name is not set
getNumberOfControlRods
            None
            Integer
            Returns the number of control rods attached to this reactor. This is one more than the maximum control rod index.
setAllControlRodLevels
            Integer: insertion level (0-100)
            None
            Sets all control rods to the specified insertion level. Range is from 0 (not inserted) to 100 (fully inserted)
setControlRodLevel
            Integer: control rod index, Integer: insertion level (0-100)
            None
            Sets the specified control rod (first argument) to the specified insertion level (second argument). Insertion level range is from 0 to 100, as above.


getCoolantAmount
            None
            Integer
            Returns the amount of coolant fluid contained in the Multiblock Reactor's coolant tank, in milli-buckets (mB)
getCoolantAmountMax
            None
            Integer
            Returns to maximum amount of coolant fluid which can be contained in the Multiblock Reactor's coolant tank, in milli-buckets (mB)
getCoolantType
            None
            String or Nil
            Returns the Fluid Dictionary name of the type of fluid contained in the Multiblock Reactor's coolant tank, or Nil if the tank is empty.


getEnergyProducedLastTick
            None
            Float
            Returns an estimate of the Redstone Flux (RF) energy generated in the past tick.
                If the reactor is actively cooled, returns the amount of hot fluid produced in the past tick, in milli-Buckets (mB).
getEnergyStored
            None
            Integer
            Returns the amount of energy stored in the Multiblock Reactor's internal energy buffer, in Redstone Flux (RF) units


getFuelAmount
            None
            Integer
            Returns the total amount of fuel contained in the reactor, in milli-buckets (mB)
getFuelAmountMax
            None
            Integer
            Returns the total amount of fuel + waste which can be contained in the reactor at one time, in milli-buckets (mB)
getFuelConsumedLastTick
            None
            Float
            Returns the amount of fuel consumed last tick, in milli-buckets (mB). Note that fractional milliBuckets can be consumed, so this can return, for example, 0.5
getFuelReactivity
            None
            Integer
            Returns the reactivity level of the reactor's fuel. 100 = 100 percent
getFuelTemperature
            None
            Integer
            Returns the temperature of the Multiblock Reactor's fuel, in degrees Centigrade.
doEjectFuel
            None
            None
            Instruct the reactor to attempt to eject any Fuel in the reactor via its access ports. The reactor will favor access ports set to Out. 1 ingot of Fuel will be ejected per 1000 mB currently in the reactor. If there is less than 1000 mB of Fuel in the reactor, nothing will happen.


getHotFluidAmount
            None
            Integer
            Returns the amount of superheated fluid contained in the Multiblock Reactor's hot-fluid tank, in milli-buckets (mB)
getHotFluidAmountMax
            None
            Integer
            Returns to maximum amount of hot fluid fluid which can be contained in the Multiblock Reactor's hot fluid tank, in milli-buckets (mB)
getHotFluidProducedLastTick
            None
            Float
            Returns the amount of hot fluid produced in the past tick, in milli-Buckets (mB).
                If the reactor is passively cooled, always returns 0.
getHotFluidType
            None
            String or Nil
            Returns the Fluid Dictionary name of the type of fluid contained in the Multiblock Reactor's hot-fluid tank, or Nil if the tank is empty.


isActivelyCooled
            None
            Boolean
            Returns true if the Multiblock Reactor is in "active cooling" mode, false otherwise


getWasteAmount
            None
            Integer
            Returns the total amount of waste contained in the reactor, in milli-buckets (mB)
doEjectWaste
            None
            None
            Instruct the reactor to attempt to eject any waste in the reactor via its access ports. The reactor will favor access ports set to Out. 1 ingot of waste will be ejected per 1000 mB currently in the reactor. If there is less than 1000 mB of waste in the reactor, nothing will happen.


getMinimumCoordinate
            None
            Integer Tuple
            Returns the smallest value Cartesian Coordinates(X,Y,Z) that contains some portion of the reactor in question. Can be accessed via: local xmin,ymin,zmin = reactor.getMinimumCoordinate()
getMaximumCoordinate
            None
            Integer Tuple
            Returns the largest value Cartesian Coordinates(X,Y,Z) that contains some portion of the reactor in question. Can be accessed via: local xmax,ymax,zmax = reactor.getMaximumCoordinate() 



All optimal end game designs use 37 Enderium coil blocks (3 blocks short of 5 full rings) with a supply of 2000mB/t of steam. 
Width   Height   Cyanite   Total Vol.   Empty Vol.     RPM    RF/t   RF/t/m^3   RF/t/cyan   Comment
    5       27       547         675           83   1797.4   24077      35.67        44     Highest energy per cubic metre.
    7       17       529         833          243   1797.4   24077      28.9         45.5   Highest energy per cyanite ingot.
   13       11       739        1859          963   1797.4   24077      12.95        32.5   Highest energy per height.

The first example above with the highest energy per cubic metre needs:
-  80 Turbine Rotor Blades
-  25 Turbine Rotor Shafts
-  37 Enderium Blocks
- 108 Turbine Housing
~ 318 Turbine Glass
- 1 each: Turbine Power Port, Turbine Controller, Turbine Fluid Port, Tubine Rotor Bearing
--]]



--[[
Turbine documentation
--------------------------
Method Name
    Arguments
    Return Type
    Description

getActive
            None
            Boolean
            Returns true if the turbine is active (consuming hot fluid and generating power), false otherwise.
setActive
            Boolean: active?
            None
            Sets the reactor to be active if the argument is true, or inactive if the argument is false

getConnected
            None
            Boolean
            Returns true if the computer port is connected to a valid Multiblock Turbine.

getEnergyProducedLastTick
            None
            Float
            Returns the amount of energy the Multiblock Turbine produced in the last tick, in Redstone Flux (RF) units
getEnergyStored
            None
            Integer
            Returns the amount of energy stored in the Multiblock Turbine's internal energy buffer, in Redstone Flux (RF) units

getFluidAmountMax
            None
            Integer
            Returns the maximum amount of fluid which the Turbine's fluid tanks may contain, in milli-buckets (mB)
getFluidFlowRate
            None
            Integer
            Returns the amount of hot fluid which the turbine consumed in the last tick, in milli-buckets (mB)
getFluidFlowRateMax
            None
            Integer
            Returns the user setting governing the maximum desired amount of fluid for the Multiblock Turbine to consume per tick, in milli-buckets (mB)
getFluidFlowRateMaxMax
            None
            Integer
            Returns the maximum permissible user setting for the desired fluid flow rate, in milli-buckets (mB). Normally returns 2000 mB
setFluidFlowRateMax
            Integer: flow rate (0 through FluidFlowRateMaxMax)
            None
            Sets the player's desired maximum rate at which the Multiblock Turbine will consume intake fluids. Range is from 0 (not inserted) to the return value of getFluidFlowRateMaxMax (normally 2000).

getInductorEngaged
            None
            Boolean
            Returns true if the Multiblock Turbine's induction coils are engaged, false otherwise.
setInductorEngaged
            Boolean: engaged?
            None
            Activates or deactivates the Multiblock Turbine's induction coils. When inactive, power will not be generated and less energy will be removed from the turbine's rotor.

getInputAmount
            None
            Integer
            Returns the amount of fluid contained in the Multiblock Turbine's hot-fluid intake tank, in milli-buckets (mB)
getInputType
            None
            String or Nil
            Returns the Fluid Dictionary name of the fluid contained in the Multiblock Turbine's hot-fluid intake tank, or Nil if the tank is empty

getOutputAmount
            None
            Integer
            Returns the amount of fluid contained in the Multiblock Turbine's effluent outlet tank, in milli-buckets (mB)
getOutputType
            None
            String or Nil
            Returns the Fluid Dictionary name of the fluid contained in the Multiblock Turbine's effluent outlet tank, or Nil if the tank is empty

getRotorSpeed
            None
            Float
            Returns the rotational velocity of the Multiblock Turbine's rotor, in Rotations Per Minute (RPMs)

setVentAll
            None
            None
            Sets the Multiblock Turbine to always vent its condensed/cooled fluids, so the turbine will never create condensed fluid when processing hot fluids. This is identical to pressing the "Vent: All" button in the turbine's GUI.
setVentOff
            None
            None
            Sets the Multiblock Turbine to never vent its condensed/cooled fluids. This is identical to pressing the "Vent: None" button in the turbine's GUI.
setVentOverflow
            None
            None
            Sets the Multiblock Turbine to vent its condensed/cooled fluids if they cannot be placed in the condensed fluid (outlet) tank. This is identical to pressing the "Vent: Overflow" button in the turbine's GUI.
--]]

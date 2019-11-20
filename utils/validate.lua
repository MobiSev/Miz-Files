local missionUtils = require("missionUtils")

local missionDir = arg[1]
if missionDir == nil then
    missionDir = "Cau-PVP-Dynamic-Objectives-Sling-CaptureAirfield-V6.4"
    --print("No mission dir specified")
    --os.exit(1)
end

missionUtils.loadMission(missionDir)

local function validateClientGroup(group)
    local errors = {}
    local groupName = missionUtils.getDictionaryValue(group.name)
    if #group.units ~= 1 then
        table.insert(errors, string.format("'%s' should only have 1 unit, but has %d", groupName, #group.units))
    end
    local unit = group.units[1]
    local unitName = missionUtils.getDictionaryValue(unit.name)
    if missionUtils.isTransportType(unit.type) and unitName ~= groupName then
        table.insert(errors, string.format("Group '%s' must contain unit with same name, but was '%s'", groupName, unitName))
    end
    for _, error in ipairs(errors) do
        print("ERROR: " .. error)
    end
    return #errors == 0
end

print("Checking client slots for problems")

local transportPilotNames = {}
missionUtils.iterGroups(function(group)
    if missionUtils.isClientGroup(group) then
        local unit = group.units[1]
        if validateClientGroup(group) and missionUtils.isTransportType(unit.type) then
            table.insert(transportPilotNames, missionUtils.getDictionaryValue(unit.name))
        end
    end
end)

-- luacheck: read_globals mission
local pickupZones = missionUtils.getZoneNames(mission, " pickup$")
local logisticsZones = missionUtils.getZoneNames(mission, " logistics$")

local function printTable(variableName, tbl)
    table.sort(tbl)
    print("-- " .. tonumber(#tbl) .. " entries\n" .. variableName .. " = {")
    for _, value in ipairs(tbl) do
        print("    \"" .. value .. "\",")
    end
    print("}\n")
end

print("\n\nThe following variables should be put into CTLD_config.lua\n\n")

printTable("ctld.pickupZones", pickupZones)
printTable("ctld.logisticUnits", logisticsZones)
printTable("ctld.transportPilotNames", transportPilotNames)

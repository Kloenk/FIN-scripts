
-- Config
scanner_in_nick = "scanner in"
scanner_out_nick = "scanner out"

num_stations = 4

panel_nick = "panel"
-- Positions on controll panel. Screen, Stop Button, reset, restart
panel_pos = {
    0, 10,
    10, 10,
    10, 8,
    10, 0
}

-- Script
-- setup scanners

scanner_in = component.proxy(component.findComponent(scanner_in_nick)[1])
scanner_out = component.proxy(component.findComponent(scanner_out_nick)[1])


if scanner_in == nil or scanner_out == nil then
    print("Could not find scanners")
	computer.shutdown()
end

event.listen(scanner_in)
event.listen(scanner_out)


local getLastVehicle = scanner_in.getLastVehicle
local setColor = scanner_in.setColor

local current_vehicles = 0
local enable_self_driving = false
local working = true

-- setup panel
local panel = component.proxy(component.findComponent(panel_nick)[1])
local panel_screen = nil
local panel_stop_button = nil
local panel_stop_reset = nil
local panel_reset = nil

function PanelGetModule(panel, offset, name, listen)
    local listen = listen or false
    local module = panel:getModule(panel_pos[offset], panel_pos[offset + 1])
    if module ~= nil then
        print("Found:", name)
        if listen then
            event.listen(module)
        end
    end
    return module
end

if panel ~= nil then
    print("Found: panel")

    panel_screen = PanelGetModule(panel, 1, "screen")

    panel_stop_button = PanelGetModule(panel, 3, "stop button", true)

    panel_stop_reset = PanelGetModule(panel, 5, "stop reset button", true)

    panel_reset = PanelGetModule(panel, 7, "reset button", true)
end


-- Vehicle update
function vehicle_enter_in(vehicle)
    print("Vehicle entered: ", current_vehicles)
    if not working or current_vehicles > num_stations then
        enable_self_driving = vehicle.is_self_driving
        vehicle.is_self_driving = false
    end
    current_vehicles = current_vehicles + 1
end

function vehicle_enter_out(_)
    print("vehicle left")
    if current_vehicles > 0 then
        current_vehicles = current_vehicles - 1
    end
    local in_vehicle = getLastVehicle(scanner_in)
    if in_vehicle ~= nil  then
        in_vehicle.is_self_driving = enable_self_driving
    end
end

function update_colors()
    if not working or current_vehicles > num_stations then
        setColor(scanner_in, 0.949, 0.149, 0.168, 0.75) -- red
    elseif current_vehicles == 0 then
        setColor(scanner_in, 0.949, 0.854, 0.149, 0.5) -- yellow
    else
        setColor(scanner_in, 0.149, 0.949, 0.196, 0.5) -- green
    end
end

-- Panel update
function update_controll_panel()
    print(working)
    if panel_screen ~= nil then
        if working then
            panel_screen.text = current_vehicles
            panel_screen.size = 100
        else
            panel_screen.text = "Stopped"
            panel_screen.size = 90
        end
    end
end

-- main
function update()
    update_colors()
	update_controll_panel()
end

setColor(scanner_out, 0.058, 0.462, 0.901, 0.5)
update()
while true do
    local event, sender, data = event.pull()
    print(event)
    if event == "OnVehicleEnter" then
        if sender == scanner_in then
            vehicle_enter_in(data)
        else
            vehicle_enter_out(data)
        end
    elseif event == "Trigger" then
        if sender == panel_stop_button then
            print("Emergency Stopp")
            working = false
        elseif sender == panel_stop_reset then
            print("Reseting")
            working = true
        elseif sender == panel_reset then
            print("rebooting")
            computer.reset()
        end
    end
    update()

end
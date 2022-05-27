
-- Config
scanner_in_nick = "scanner in"
scanner_out_nick = "scanner out"
num_stations = 4

-- Script

scanner_in = component.proxy(component.findComponent(scanner_in_nick))
scanner_out = component.proxy(component.findComponent(scanner_out_nick))

event.listen(scanner_in)
event.listen(scanner_out)

local getLastVehicle = scanner_in.getLastVehicle
local setColor = scanner_in.setColor

current_vehicles = 0
enable_self_driving = false

function vehicle_enter_in(vehicle)
    if current_vehicles > num_stations then
        enable_self_driving = vehicle.is_self_driving
        vehicle.is_self_driving = false
    end
    current_vehicles = current_vehicles + 1
end

function vehicle_enter_out(_)
    current_vehicles = current_vehicles - 1
    local in_vehicle = getLastVehicle(scanner_in)
    if in_vehicle ~= nil  then
        in_vehicle.is_self_driving = enable_self_driving
    end
end

function update_colors()
    if current_vehicles == 0 then
        setColor(scanner_in, 0.949, 0.854, 0.149, 0.5)
    elseif current_vehicles < num_stations then
        setColor(scanner_in, 0.149, 0.949, 0.196, 0.5)
    else
        setColor(scanner_in, 0.949, 0.149, 0.168, 0.75)
    end
end

setColor(scanner_out, 0.058, 0.462, 0.901, 0.5)
while true do
    local event, sender, data = event.pull()
    if event == "OnVehicleEnterOnVehicleEnter" then
        if sender == scanner_in then
            vehicle_enter_in(data)
        else
            vehicle_enter_out(data)
        end
    end
    update_colors()

end
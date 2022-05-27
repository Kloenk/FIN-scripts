local doDebug = false
local debug = function (x) end
if doDebug then
  debug = function (x) print(x) end
end

function getDefaultOptions(options)
  if options == nil then
    options = {}
  elseif type(options) == "boolean" then
    options = {listen=options}
  end
  return options
end

-- Get one component by name
function getComponent(name, options)
  local options = getDefaultOptions(options)
  local id = component.findComponent(name)[1]
  if id == nil then
    if options.required or (options.required == nil) then
      computer.panic("Cannot find: " .. name)
    end
    debug("Did not find " .. name)
    return nil
  end

  local c = component.proxy(id)
  if options.listen then
    debug("Listening on " .. name)
    event.listen(c)
  end
  debug("Found component: " .. name)
  return c
end

-- get module from optional panel
function getModule(panel, x, y, options)
  local checkValue = function(value)
    if value == nil then
      if options.required then
        computer.panic("Did not find module: x=" .. x .. ", y=" .. y)
      end
    end
  end
  local options = getDefaultOptions(options)

  if panel == nil and (options.required or false) then
    checkValue(panel)
    return nil
  end

  local module = panel:getModule(x, y)
  if module == nil then
    checkValue(module)
    return nil
  end

  if options.listen then
    event.listen(module)
    debug("Listening on module: x=" .. x .. ", y=" .. y)
  end
  debug("Found module: x=" .. x .. ", y=" .. y)
  return module
end

local CSimple1 = getComponent("Container Simple 1")
local CSimple2 = getComponent("Container Simple 2")
local CSimpleS12 = getComponent("Splitter Simple 12", true)
local CSimpleS1234 = getComponent("Splitter Simple 1234", true)
local CSimple1Items = {"Iron Rod", "Iron Plate", "Concrete", "Cable", "Wire"}
local CSimple2Items = {"Screw", "Quickwire", "Quartz Crystal", "Silica", "Color Cartridge"}

local panel = getComponent("Panel", {required=false})

local PReset = getModule(panel, 0, 0, true)
local PStop = getModule(panel, 1, 1, true)
local POnOff = getModule(panel, 0, 2, true)
local PStatus = getModule(panel, 1, 2)
local PTraffic = getModule(panel, 2, 2)
local working = true
local stop = false

local FISetColor = PTraffic.setColor
local CSGetInput = CSimpleS12.getInput
local FCSTransferItem = CSimpleS12.transferItem

local CGetInventories = CSimple1.getInventories
--local ISort = CGetInventories(CSimple1, 1)[1].sort
local IGetStack = CGetInventories(CSimple1, 1)[1].getStack
--local IGetStack = Inventory.getStack

function contains(list, entry)
  for _, value in ipairs(list) do
    if value == entry then
      return true
     end
  end
  return false
end

function checkContainerSpace(container)
  local inv = CGetInventories(container, 1)[1]
  local size = inv.size

  --ISort(inv)
  return IGetStack(inv, size-1).count == 0
end

function moveToContainer(splitter, container, idx)
  if checkContainerSpace(container) then
    FCSTransferItem(splitter, idx)
  else
    FCSTransferItem(splitter, 1)
  end
end

function runCSimpleS12()
  local item = CSGetInput(CSimpleS12).type
  if item == nil then
    -- debug("Splitter Empty")
    return
  end
  -- debug("Found: " .. item.name)

  if contains(CSimple1Items, item.name) then
    moveToContainer(CSimpleS12, CSimple1, 0)
  elseif contains(CSimple2Items, item.name) then
    moveToContainer(CSimpleS12, CSimple2, 2)
  else
    computer.beep(10)
    print("Cannot route", item.name)
    FCSTransferItem(CSimpleS12, 1)
  end
end

function runCSimpleS1234()
  local item = CSGetInput(CSimpleS1234).type
  if item == nil then
    return
  end

  if contains(CSimple1Items, item.name) or contains(CSimple2Items, item.name) then
    FCSTransferItem(CSimpleS1234, 0)
  elseif false then -- TODO: 
    FCSTransferItem(CSimpleS1234, 2)
  else
    FCSTransferItem(CSimpleS1234, 1)
  end
end

function runAll()
  runCSimpleS12()
  runCSimpleS1234()
end

function runItemRequest(s)
  if not working then
    return
  end
  FISetColor(PTraffic, 0.909, 0.819, 0.066, 0.75)

  if s == CSimpleS12 then
    runCSimpleS12()
  elseif s == CSimpleS1234 then
    runCSimpleS1234()
  end
end

-- Panel
function initButtons()
  FISetColor(PTraffic, 0.909, 0.819, 0.066, 0)
  working = POnOff.state
  updateButtons()
end

function updateButtons()
  if working and not stop then
    POnOff:setColor(0, 1, 0, 1)
    FISetColor(PStatus, 0, 1, 0, 1)
    PReset:setColor(0, 0, 0, 0)
  elseif stop then
    POnOff:setColor(0, 0, 0, 0)
    FISetColor(PStatus, 1, 0, 0, 1)
    PReset:setColor( 1, 0, 0, 1)
  else
    POnOff:setColor(1, 0, 0, 1)
    FISetColor(PStatus, 0, 0, 0, 0)
    PReset:setColor(0, 0, 0, 0)
  end
end

function emergencyStop()
  computer.beep(10)
  working = false
  stop = true
end

function handleTrigger(sender)
  if sender == PReset then
    computer.beep(10)
    event.pull(0.0)
    computer.reset()
  elseif sender == PStop and not stop then
    emergencyStop()
  end
  updateButtons()
end

function handleChangeState(sender, value)
  if sender == POnOff and not stop then
    working = value
    if value then
      runAll()
    end
  end
  updateButtons()
end

-- main

function loop(timeout)
  local e, s, v = event.pull(timeout)
  if e == nil then
    runAll()
    return
  end
  
  if e == "ItemRequest" then
    runItemRequest(s)
  elseif e == "ItemOutputted" then
    FISetColor(PTraffic, 0.909, 0.819, 0.066, 0)
  elseif e == "Trigger" then
    handleTrigger(s)
  elseif e == "ChangeState" then
    handleChangeState(s, v)
  else
    debug("Unhandled event: " .. e)
  end
end

function main()
  initButtons()
  runAll()
  while true do
    loop(20)
  end
end

computer.beep(10)
main()
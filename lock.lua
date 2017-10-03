local copas = require("copas")

-------------------------------------------------------------------------------

local function acquire(l)
  while l.locked and ( (not l.reentrant) or (l.current ~= coroutine.running()) ) do
    table.insert(l.queue, (coroutine.running()))
    copas.sleep(-1)
  end
  l.locked  = true
  l.current = coroutine.running()
end

local function release(l)
  if l.locked then
    l.current = nil
    l.locked  = false
    local co = table.remove(l.queue, 1)
    if co then
      copas.wakeup(co)
    end
  end
end

local meta = {
  __index = {
    acquire = acquire,
    release = release,
  }
}

-------------------------------------------------------------------------------
local Module = {}

function Module.create(init, reentrant)
  local l = {
    locked    = init,
    reentrant = reentrant,
    current   = nil,
    queue     = {},
  }
  return setmetatable(l, meta)
end

return Module

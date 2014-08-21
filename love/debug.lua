-- Debug functions for love.
love.debug = {}

local debug_flags = Set.new()

function love.debug.flags()
    return debug_flags:items()
end

function love.debug.getFlag(flag)
    return debug_flags:containsAny(flag, 'all')
end

function love.debug.setFlag(flag)
    return debug_flags:add(flag)
end

function love.debug.unsetFlag(flag)
    return debug_flags:remove(flag)
end

function love.debug.printIf(flag, ...)
    if love.debug.getFlag(flag) then
      return love.debug.print('['..flag..']', ...)
    end
end

function love.debug.print(...)
    local timestamp = os.date("[%Y-%m-%d %X] ")
    local args = {...} or {}
    for k,v in pairs(args) do
        if(type(v) == 'table') then args[k] = inspect(v) end
    end
    return io.write(timestamp, table.concat(args, " "), "\n")
end

function love.processevents()
    -- Process events.
    love.event.pump()

    -- Process Input events into queue
    if Input then
        Input:processEventQueue(function(event, states)
            for i,state in ipairs(states) do
                love.event.push(event, state)
            end
        end)
    end

    -- Process love events
    for e,a,b,c,d in love.event.poll() do
        if(e == "quit")then
            if not love.quit or not love.quit() then
                love.audio.stop()
                return
            end
        end
        love.handlers[e](a,b,c,d)
    end

    return true
end

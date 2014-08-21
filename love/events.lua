function love.processevents()
    -- Pump events from the engine into the queue
    love.event.pump()

    -- Pump inputman events into queue
    if love.inputman then
        love.inputman.processEventQueue(function(event, states)
            for i,state in ipairs(states) do
                love.event.push(event, state)
            end
        end)
    end

    -- Process love events
    for e,a,b,c,d in love.event.poll() do
        if(e == "quit")then
            if not love.quit or not love.quit() then return end
        end
        love.handlers[e](a,b,c,d)
    end

    return true
end

function love.run()
    love.math.setRandomSeed(os.time())
    love.event.pump()
    if love.load then love.load(arg) end
    love.timer.step()

    local t = 0
    local dt = 0
    local updateCount = 0
    local frameCount = 0
    local internalRate = 1/60
    local nextTime = 0
    local updateRate = 0
    local maxFrameskip = 4

    -- Main loop
    while true do
        -- Tick-count/running time
        love.timer.step()
        dt = love.timer.getDelta()
        t = t + dt

        -- Update at constant speed. Game will slow if maxFrameskip exceeded
        updateRate = 0
        while(t >= nextTime and updateRate < maxFrameskip ) do
            -- events.lua : love.processevents()
            if love.processevents and not love.processevents() then
                -- Quit signal received!
                love.audio.stop()
                love.soundman:killThread()
                love.inputman:killThread()
                love.timer.sleep(0.05)
                return
            end

            -- update.lua : love.update(dt)
            if love.update then love.update(internalRate) end
            nextTime = nextTime + internalRate
            updateCount = updateCount + 1
            updateRate = updateRate + 1
        end

        -- Draw and present graphics
        if love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()

            -- draw.lua : love.draw()
            if love.draw then love.draw() end

            -- Print optional debug information
            if(debugInfo and #debugInfo > 0) then
                local printtable = {}
                for k,v in pairs(debug) do
                    insert(printtable, k .. ": " .. v .. "\n")
                end
                local r,g,b,a = love.graphics.getColor()
                love.graphics.setColor(0,0,0)
                love.graphics.print(table.concat(printtable), 1, 1)
                love.graphics.setColor(r,g,b,a)
                love.graphics.print(table.concat(printtable))
            end

            -- Present the graphics
            love.graphics.present()
            frameCount = frameCount + 1
        end

        -- Print the thread debug queues maybe
        if love.debug.getFlag('sound') then love.soundman:printDebugQueue() end
        if love.debug.getFlag('input') then love.inputman:printDebugQueue() end

        love.timer.sleep(0.001)
    end
end

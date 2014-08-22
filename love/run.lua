function love.run()
    -- Main loop variables
    local t = 0
    local dt = 0
    local updateCount = 0
    local frameCount = 0
    local internalRate = 1/60
    local nextTime = 0
    local updateRate = 0
    local maxFrameskip = 4

    -- Imports!
    local insert = table.insert
    local concat = table.concat

    -- Seed all the PRNGs!
    math.randomseed(os.time())
    love.math.setRandomSeed(os.time(), os.time())
    for i=1,10 do math.random(); love.math.random() end

    -- load.lua : Load the game!
    love.event.pump()
    love.load(arg)

    -- Begin the timer!
    love.timer.step()

    -- Main loop (fixed-rate update with unlocked FPS and frameskip)
    while true do
        -- Tick-count/running time
        love.timer.step()
        dt = love.timer.getDelta()
        t = t + dt

        -- Update at constant rate. Game will slow if maxFrameskip exceeded
        updateRate = 0
        while(t >= nextTime and updateRate < maxFrameskip ) do
            -- events.lua : love.processevents()
            if not love.processevents() then
                -- Quit signal received!
                love.audio.stop()
                love.soundman.killThread()
                love.inputman.killThread()
                love.timer.sleep(0.05) -- thread/sound device cleanup
                return -- quit process
            end

            -- update.lua : love.update(dt)
            love.update(internalRate)
            nextTime = nextTime + internalRate
            updateCount = updateCount + 1
            updateRate = updateRate + 1
        end

        -- Draw and present graphics
        if love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()

            -- draw.lua : love.draw()
            love.viewport.pushScale()
            local debugInfo = love.draw()
            love.viewport.popScale()

            -- Print optional debug information
            if(debugInfo) then
                local printtable = {}
                if(type(debugInfo) == 'table') then
                    for k,v in pairs(debugInfo) do
                        insert(printtable, k .. ": " .. v .. "\n")
                    end
                else
                    insert(printtable, debugInfo)
                end
                local r,g,b,a = love.graphics.getColor()
                love.graphics.setColor(0,0,0)
                love.graphics.print(concat(printtable), 1, 1)
                love.graphics.setColor(r,g,b,a)
                love.graphics.print(concat(printtable))
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

--
--  main.lua
--  Main entry-point for the file.
--

-- conf.lua -- Initial configuration (already loaded)
--   Exports:
--     love.conf(t) - ran already
--     conf (table of love configuration settings)


--
--  Load libraries and such here.
--
Class      = require('vendor/class')
Inspect    = require('vendor/inspect')
JSON       = require('vendor/dkjson')
Set        = require('vendor/set')
math.round = require('vendor/round')

Viewport = require('libs/viewport')
Inputman = require('libs/inputman')
Soundman = require('libs/soundman')

-- load.lua -- Loaded on game start
--   Exports:
--     love.load()
--       view (Viewport instance)
--       input (Inputman instance)
--       sound (Soundman instance)
require('load')

-- update.lua -- Update method
--   Exports:
--     love.update(dt)
require('update')

-- draw.lua -- Draw method
--   Exports:
--     love.draw()
require('draw')

-- input.lua -- Input callbacks
--   Exports:
--     love.inputpressed(state, value)
--     love.inputreleased(state, value)
require('input')

-- events.lua -- Love2d Event processing
--   Exports:
--     love.processevents()
require('events')

-- misc.lua -- Miscellaneous Love2d events
--   Exports:
--     love.threaderror(thread, errorstr)
require('misc')

-- run.lua -- Main loop
--   Exports:
--     love.run()
require('run')

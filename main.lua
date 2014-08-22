--
--  main.lua
--  Main entry-point for the file.
--

--  ========================
--
--  GLOBAL LIBRARIES/CLASSES
--
--  ========================
Class = require('vendor/nomoon/class')
Set   = require('vendor/nomoon/set')
JSON  = require('vendor/dkjson')

-- Kikito's best libraries
kikito = {
    anim8   = require('vendor/kikito/anim8'),
    bump    = require('vendor/kikito/bump'),
    inspect = require('vendor/kikito/inspect'),
    loader  = require('vendor/kikito/love-loader'),
    md5     = require('vendor/kikito/md5'),
    sha1    = require('vendor/kikito/sha1'),
    tween   = require('vendor/kikito/tween')
}

-- Parts of the HUMP library
hump = {
    GS     = require('vendor/hump/gamestate'),
    Signal = require('vendor/hump/signal'),
    Timer  = require('vendor/hump/timer'),
    Vector = require('vendor/hump/vector')
}

-- Helper methods
inspect    = kikito.inspect
math.round = require('vendor/nomoon/round')
--[[ .... ]] require('vendor/deepcopy') -- table.deepcopy
table.copy = table.deepcopy

--  ========================
--
--  LÖVE2D ENGINE/GAME STUFF
--
--  ========================

-- This table can store important "global" objects for the game
-- (and keep the global namespace cleaner)
game = {}

-- conf.lua -- Initial configuration (already loaded)
--   Exports:
--     love.conf(t) - ran already
--     conf (table of love configuration settings)

-- debug.lua -- Debug flags/output for Love2d
--   Exports:
--     love.debug, etc. (see file)
require('love/debug')
love.debug.setFlag('all') -- Comment this out to stop seeing everything.

-- load.lua -- Loaded on game start
--   Exports:
--     love.load()
require('love/load')

-- update.lua -- Update method
--   Exports:
--     love.update(dt)
require('love/update')

-- draw.lua -- Draw method
--   Exports:
--     love.viewport -- Viewport singleton
--     love.draw()
require('love/draw')

-- input.lua -- Input callbacks
--   Exports:
--     love.inputman -- InputMan singleton
--     love.inputpressed(state, value)
--     love.inputreleased(state, value)
--     love.joystickadded(k)
--     love.joystickremoved(j)
require('love/input')

-- sound.lua -- Sound methods
--   Exports:
--     love.soundman -- SoundMan singleton
require('love/sound')

-- events.lua -- Love2d Event processing
--   Exports:
--     love.processevents()
require('love/events')

-- misc.lua -- Miscellaneous Love2d events
--   Exports:
--     love.threaderror(thread, errorstr)
require('love/misc')

-- run.lua -- Main loop
--   Exports:
--     love.run()
require('love/run')

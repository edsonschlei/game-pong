
local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720

local VIRTUAL_WIDTH = 432
local VIRTUAL_HEIGHT = 243

local MIDDLE_X = 0
local MIDDLE_Y = 0

local push = require 'push'

--[[
    Load the default values and initial configurations
]]
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })

    local font = love.graphics.getFont( )
    local hello_pong = love.graphics.newText(font, "Hello Pong!")
    local hp_tw_half = hello_pong:getWidth() / 2
    print(hp_tw_half)
    MIDDLE_X = VIRTUAL_WIDTH / 2 - hp_tw_half
    MIDDLE_Y = VIRTUAL_HEIGHT / 2 - 6
end

function love.draw()
    push:apply('start')
    love.graphics.print("Hello Pong!", MIDDLE_X, MIDDLE_Y)
    push:apply('end')
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end



local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720

local VIRTUAL_WIDTH = 432
local VIRTUAL_HEIGHT = 243

local GAME_NAME_POSITION_X = 0
local GAME_NAME_POSITION_Y = 0

local GAME_AREA_Y = 20
local GAME_AREA_X = 5
local GAME_AREA_WIDTH = VIRTUAL_WIDTH - (GAME_AREA_X * 2)
local GAME_AREA_HEIGHT = VIRTUAL_HEIGHT - (GAME_AREA_Y * 2)

local PADDLE_WIDTH = 10
local PADDLE_HEIGHT = 30

local MAX_PADDLE_Y = VIRTUAL_HEIGHT - (GAME_AREA_Y + PADDLE_HEIGHT)
local MIN_PADDLE_Y = GAME_AREA_Y

local LEFT_PADDLE_X = GAME_AREA_X
local RIGHT_PADDLE_X = VIRTUAL_WIDTH - (GAME_AREA_X + PADDLE_WIDTH)

local BALL_SIZE = 20

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

    local smallFont = love.graphics.newFont('04B03.TTF', 8)
    love.graphics.setFont(smallFont)

    local font = love.graphics.getFont( )
    local hello_pong = love.graphics.newText(font, "Hello Pong!")
    local hp_tw_half = hello_pong:getWidth() / 2
    print(hp_tw_half)
    GAME_NAME_POSITION_X = VIRTUAL_WIDTH / 2 - hp_tw_half
    GAME_NAME_POSITION_Y = 7
end

--[[
    Draw the elements on the screen.
]]
function love.draw()
    push:apply('start')

    -- it clears the screen with the defined collor
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    -- it shows the name of the game
    love.graphics.print("Hello Pong!", GAME_NAME_POSITION_X, GAME_NAME_POSITION_Y)

    -- it draws the pong ball
    local half_ball = BALL_SIZE / 2
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - half_ball, VIRTUAL_HEIGHT / 2 - half_ball, BALL_SIZE, BALL_SIZE)

    -- it draws the fame area
    love.graphics.rectangle('line', GAME_AREA_X , GAME_AREA_Y, GAME_AREA_WIDTH, GAME_AREA_HEIGHT)

    -- it draws the left padle
    love.graphics.rectangle('fill', LEFT_PADDLE_X, MIN_PADDLE_Y, PADDLE_WIDTH, PADDLE_HEIGHT)

    -- it draws the right padle
    love.graphics.rectangle('fill', RIGHT_PADDLE_X, MAX_PADDLE_Y, PADDLE_WIDTH, PADDLE_HEIGHT)

    push:apply('end')
end

--[[
    catch the key events
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end


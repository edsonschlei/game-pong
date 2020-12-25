Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720

local VIRTUAL_WIDTH = 432
local VIRTUAL_HEIGHT = 243

local GAME_AREA_Y = 20
local GAME_AREA_X = 5

local PADDLE_WIDTH = 10
local PADDLE_HEIGHT = 30

local BALL_SIZE = 6

local PADDLE_SPEED = 200


--[[
    Load the default values and initial configurations
]]
function love.load()
    math.randomseed(os.time())

    -- define render style
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- define virtual screen and window properties
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })

    -- create fonts
    scoreFont = love.graphics.newFont('04B03.TTF', 32)
    smallFont = love.graphics.newFont('04B03.TTF', 8)

    -- initial game score
    player1Score = 0
    player2Score = 0

    gameAreaWidth = VIRTUAL_WIDTH - (GAME_AREA_X * 2)
    gameAreaHeight = VIRTUAL_HEIGHT - (GAME_AREA_Y * 2)

    local maxPaddleY = VIRTUAL_HEIGHT - (GAME_AREA_Y + PADDLE_HEIGHT)
    local minPaddleY = GAME_AREA_Y

    local leftPaddleX = GAME_AREA_X
    local rightPaddleX = VIRTUAL_WIDTH - (GAME_AREA_X + PADDLE_WIDTH)

    player1ScoreX = VIRTUAL_WIDTH / 2 - 50
    player2ScoreX = VIRTUAL_WIDTH / 2 + 30
    playerScoreY = VIRTUAL_HEIGHT / 3

    local player1Y = minPaddleY
    local player2Y = maxPaddleY

    paddle1 = Paddle(leftPaddleX, player1Y, PADDLE_WIDTH, PADDLE_HEIGHT, minPaddleY, maxPaddleY)
    paddle2 = Paddle(rightPaddleX, player2Y, PADDLE_WIDTH, PADDLE_HEIGHT, minPaddleY, maxPaddleY)

    -- ball intial position
    local half_ball = BALL_SIZE / 2
    local ballX = VIRTUAL_WIDTH / 2 - half_ball
    local ballY = VIRTUAL_HEIGHT / 2 - half_ball
    ball = Ball(ballX, ballY, BALL_SIZE, BALL_SIZE)

    gameState = 'start'

    -- calculate the game name position
    love.graphics.setFont(smallFont)
    local font = love.graphics.getFont()
    local hello_pong = love.graphics.newText(font, "Hello Pong!")
    local hp_tw_half = hello_pong:getWidth() / 2
    gameNamePositionX = VIRTUAL_WIDTH / 2 - hp_tw_half
    gameNamePositionY = 7
end

--[[
    Draw the elements on the screen.
]]
function love.draw()
    push:apply('start')

    -- it clears the screen with the defined collor
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    -- it shows the name of the game
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.print("Hello Pong - Press Enter to Start!", gameNamePositionX, gameNamePositionY)
        -- present the game score
        love.graphics.setFont(scoreFont)
        love.graphics.print(player1Score, player1ScoreX, playerScoreY)
        love.graphics.print(player2Score, player2ScoreX, playerScoreY)
    elseif gameState == 'play' then
        love.graphics.print("Hello Pong - Playing!", gameNamePositionX, gameNamePositionY)
    end

    -- it draws the fame area
    love.graphics.rectangle('line', GAME_AREA_X , GAME_AREA_Y, gameAreaWidth, gameAreaHeight)

    -- it draws the pong ball
    ball:render()

    -- it draws the left padle
    paddle1:render()

    -- it draws the right padle
    paddle2:render()

    push:apply('end')
end

--[[
    Calculate the new state of the game
]]
function love.update(dt)
    --  update player 1 paddle
    if love.keyboard.isDown('w') then
        paddle1.dy = - PADDLE_SPEED
    elseif love.keyboard.isDown('s')  then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0;
    end

    --  update player 2 paddle
    if love.keyboard.isDown('up') then
        paddle2.dy = - PADDLE_SPEED
    elseif love.keyboard.isDown('down')  then
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0;
    end

    paddle1:update(dt)
    paddle2:update(dt)

    -- update the ball position
    if gameState == 'play' then
        ball:update(dt)
    end
end

--[[
    catch the key events
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        -- start the game when enter/return is pressed
        if gameState == 'start' then
            gameState = 'play'
        elseif gameState == 'play' then
            gameState = 'start'
            ball:reset()
        end
    end
end


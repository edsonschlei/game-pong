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

local PADDLE_WIDTH = 5
local PADDLE_HEIGHT = 20

local BALL_SIZE = 6

local PADDLE_SPEED = 200

local GAME_STATE_START = 'start'
local GAME_STATE_SERVE = 'serve'
local GAME_STATE_PLAY = 'play'


--[[
    Load the default values and initial configurations
]]
function love.load()
    math.randomseed(os.time())

    love.window.setTitle('Pong')

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

    -- serving player
    servingPlayer = math.random(2)

    gameAreaWidth = VIRTUAL_WIDTH - (GAME_AREA_X * 2)
    gameAreaHeight = VIRTUAL_HEIGHT - (GAME_AREA_Y * 2)

    minBallY = GAME_AREA_Y
    print('Min Ball Y:' .. tostring(minBallY))
    maxBallY = VIRTUAL_HEIGHT - GAME_AREA_Y - BALL_SIZE
    print('Max Ball Y:' .. tostring(maxBallY))

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

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    gameState = GAME_STATE_START
end

--[[
    Draw the elements on the screen.
]]
function love.draw()
    push:apply('start')

    -- it clears the screen with the defined collor
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    -- it draws the fame area
    love.graphics.rectangle('line', GAME_AREA_X , GAME_AREA_Y, gameAreaWidth, gameAreaHeight)

    -- it shows the name of the game
    love.graphics.setFont(smallFont)

    if gameState == GAME_STATE_START then
        love.graphics.printf('Welcome to Pong!', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to choose the serve player', 0, 42, VIRTUAL_WIDTH, 'center')
    elseif gameState == GAME_STATE_SERVE then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s turn!", 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter to Serve!', 0, 42, VIRTUAL_WIDTH, 'center')
    end

    -- show score only when the game is stopped
    if not (gameState == GAME_STATE_PLAY) then
        -- present the game score
        love.graphics.setFont(scoreFont)
        love.graphics.print(player1Score, player1ScoreX, playerScoreY)
        love.graphics.print(player2Score, player2ScoreX, playerScoreY)
    end

    -- it draws the pong ball
    ball:render()

    -- it draws the left padle
    paddle1:render()

    -- it draws the right padle
    paddle2:render()

    -- display FPS
    displayFPS()

    push:apply('end')
end

--[[
    Calculate the new state of the game
]]
function love.update(dt)

    if gameState == GAME_STATE_PLAY then

        if ball.x <= paddle1.x then
            player2Score = player2Score + 1
            servingPlayer = 1
            gameState = GAME_STATE_SERVE
            ball:reset()
            ball.dx = 100
        end

        if ball.x >= paddle2.x + paddle2.width then
            player1Score = player1Score + 1
            servingPlayer = 2
            gameState = GAME_STATE_SERVE
            ball:reset()
            ball.dx = -100
        end

        if ball:collides(paddle1) then
            -- diflect ball to the right
            ball.dx = -ball.dx
            ball.x = paddle1.x + paddle1.width + 1
        end

        if ball:collides(paddle2) then
            -- diflect ball to the left
            ball.dx = -ball.dx
            ball.x = paddle2.x - ball.width -1
        end

        -- detect top game area
        if ball.y <= minBallY then
            ball.dy = -ball.dy
            ball.y = minBallY + 1
        end

        -- detect collision on the bottom game area
        if ball.y >= maxBallY then
            ball.dy = -ball.dy
            ball.y = maxBallY - 1
        end

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

        -- update paddles position
        paddle1:update(dt)
        paddle2:update(dt)

        -- update the ball position
        ball:update(dt)
    end
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
end

--[[
    catch the key events
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        -- start the game when enter/return is pressed
        if gameState == GAME_STATE_START then
            gameState = GAME_STATE_SERVE
        elseif gameState == GAME_STATE_SERVE then
            gameState = GAME_STATE_PLAY
        end
    end
end


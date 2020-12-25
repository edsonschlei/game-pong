
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

local push = require 'push'

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

    scoreFont = love.graphics.newFont('04B03.TTF', 32)
    smallFont = love.graphics.newFont('04B03.TTF', 8)

    player1Score = 0
    player2Score = 0

    gameNamePositionX = 0
    gameNamePositionY = 0

    gameAreaWidth = VIRTUAL_WIDTH - (GAME_AREA_X * 2)
    gameAreaHeight = VIRTUAL_HEIGHT - (GAME_AREA_Y * 2)

    maxPaddleY = VIRTUAL_HEIGHT - (GAME_AREA_Y + PADDLE_HEIGHT)
    minPaddleY = GAME_AREA_Y

    leftPaddleY = GAME_AREA_X
    rightPaddleX = VIRTUAL_WIDTH - (GAME_AREA_X + PADDLE_WIDTH)

    player1ScoreX = VIRTUAL_WIDTH / 2 - 50
    player2ScoreX = VIRTUAL_WIDTH / 2 + 30
    playerScoreY = VIRTUAL_HEIGHT / 3

    player1Y = minPaddleY
    player2Y = maxPaddleY

    -- ball intial position
    ballInitialization()

    gameState = 'start'

    -- calculate the game name position
    love.graphics.setFont(smallFont)
    local font = love.graphics.getFont()
    local hello_pong = love.graphics.newText(font, "Hello Pong!")
    local hp_tw_half = hello_pong:getWidth() / 2
    -- print(hp_tw_half)
    gameNamePositionX = VIRTUAL_WIDTH / 2 - hp_tw_half
    gameNamePositionY = 7
end

--[[
    Init the ball position and move direction
]]
function ballInitialization()
    -- ball intial position
    local half_ball = BALL_SIZE / 2
    ballX = VIRTUAL_WIDTH / 2 - half_ball
    ballY = VIRTUAL_HEIGHT / 2 - half_ball

    -- ball delta X
    ballDX = math.random(2) == 1 and -100 or 100
    ballDY = math.random(-50, 50)
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

    -- it draws the pong ball
    love.graphics.rectangle('fill', ballX, ballY, BALL_SIZE, BALL_SIZE)

    -- it draws the fame area
    love.graphics.rectangle('line', GAME_AREA_X , GAME_AREA_Y, gameAreaWidth, gameAreaHeight)

    -- it draws the left padle
    love.graphics.rectangle('fill', leftPaddleY, player1Y, PADDLE_WIDTH, PADDLE_HEIGHT)

    -- it draws the right padle
    love.graphics.rectangle('fill', rightPaddleX, player2Y, PADDLE_WIDTH, PADDLE_HEIGHT)


    push:apply('end')
end

function love.update(dt)
    --  update player 1 paddle
    if love.keyboard.isDown('w') then
        print('w')
        player1Y = math.max(minPaddleY, player1Y - PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('s')  then
        print('d')
        player1Y = math.min(maxPaddleY, player1Y + PADDLE_SPEED * dt)
    end

    --  update player 2 paddle
    if love.keyboard.isDown('up') then
        print('up')
        player2Y = math.max(minPaddleY, player2Y - PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('down')  then
        print('down')
        player2Y = math.min(maxPaddleY, player2Y + PADDLE_SPEED * dt)
    end

    if gameState == 'play' then
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
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
            ballInitialization()
        end
    end
end


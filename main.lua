--[[
    Author: Edson Elmar Schlei
    edson.schlei@gmail.com

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on
    modern systems.
]]

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'
require 'PlayerIA'

local AUTHOR_NAME = 'Edson Schlei'
local AUTHOR_EMAIL = '(edson.schlei@gmail.com)'
local GAME_VERSION = '1.10'

local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

local GAME_AREA_Y = 20
local GAME_AREA_X = 5

local PADDLE_WIDTH = 5
local PADDLE_HEIGHT = 20

local BALL_SIZE = 6

PADDLE_SPEED = 200

local VICTORY_SCORE = 10

local GAME_STATE_START = 'start'
local GAME_STATE_SERVE = 'serve'
local GAME_STATE_PLAY = 'play'
local GAME_STATE_VICTORY = 'victory'


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
        resizable = true
    })

    -- create fonts
    scoreFont = love.graphics.newFont('04B03.TTF', 32)
    smallFont = love.graphics.newFont('04B03.TTF', 8)
    victoryFont = love.graphics.newFont('04B03.TTF', 24)

    -- https://freesound.org/
    sounds = {
        ['paddle_hit'] = love.audio.newSource('audios/paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('audios/point_scored.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('audios/wall_hit.wav', 'static'),
        ['win_game'] = love.audio.newSource('audios/win_game.wav', 'static')
    }

    -- initial game score
    player1Score = 0
    player2Score = 0

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

    player1 = Paddle(leftPaddleX, player1Y, PADDLE_WIDTH, PADDLE_HEIGHT, minPaddleY, maxPaddleY)
    player2 = Paddle(rightPaddleX, player2Y, PADDLE_WIDTH, PADDLE_HEIGHT, minPaddleY, maxPaddleY)

    -- ball intial position
    local half_ball = BALL_SIZE / 2
    local ballX = VIRTUAL_WIDTH / 2 - half_ball
    local ballY = VIRTUAL_HEIGHT / 2 - half_ball
    ball = Ball(ballX, ballY, BALL_SIZE, BALL_SIZE)

    playerIA = PlayerIA(player2, ball)

    -- serving player
    servingPlayer = math.random(2)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    winningPlayer = 0

    gameState = GAME_STATE_START
end

function love.resize(w,h)
    push:resize(w,h)
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

    -- prints the game state
    printGameState()

    -- it draws the pong ball
    ball:render()

    -- it draws the left padle
    player1:render()

    -- it draws the right padle
    player2:render()

    -- display FPS
    displayFPS()

    -- draw author name
    drawAuthorAndVersion()

    push:apply('end')
end

function printGameState()
    if gameState == GAME_STATE_START then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to choose the serve player!', 0, 42, VIRTUAL_WIDTH, 'center')
    elseif gameState == GAME_STATE_SERVE then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s turn!", 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter to Serve!', 0, 42, VIRTUAL_WIDTH, 'center')
    elseif gameState == GAME_STATE_VICTORY then
        love.graphics.setFont(victoryFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. " wins!", 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press enter to restart!', 0, 60, VIRTUAL_WIDTH, 'center')
    end

    -- show score only when the game is stopped
    printScore()
end

function printScore()
    if not (gameState == GAME_STATE_PLAY) then
        -- present the game score
        love.graphics.setFont(scoreFont)
        love.graphics.print(player1Score, player1ScoreX, playerScoreY)
        love.graphics.print(player2Score, player2ScoreX, playerScoreY)
    else
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player 1 -> ' .. tostring(player1Score) .. ' x ' .. tostring(player2Score) .. ' <- Player 2', 0, 5, VIRTUAL_WIDTH, 'center')
    end
end


--[[
    Calculate the new state of the game
]]
function love.update(dt)

    if gameState == GAME_STATE_PLAY then

        if ball.x <= player1.x then
            player2Score = player2Score + 1
            servingPlayer = 1
            gameState = GAME_STATE_SERVE
            ball:reset()
            ball.dx = 100
            sounds['point_scored']:play()
            if player2Score >= VICTORY_SCORE then
                gameState = GAME_STATE_VICTORY
                winningPlayer = 2
                sounds['win_game']:play()
            end
        end

        if ball.x >= player2.x + player2.width then
            player1Score = player1Score + 1
            servingPlayer = 2
            gameState = GAME_STATE_SERVE
            ball:reset()
            ball.dx = -100
            sounds['point_scored']:play()
            if player1Score >= VICTORY_SCORE then
                gameState = GAME_STATE_VICTORY
                winningPlayer = 1
                sounds['win_game']:play()
            end
         end

        if ball:collides(player1) then
            -- diflect ball to the right
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + player1.width + 1

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(player2) then
            -- diflect ball to the left
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx
            ball.x = player2.x - ball.width -1

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- detect top game area
        if ball.y <= minBallY then
            ball.dy = -ball.dy
            ball.y = minBallY + 1
            sounds['wall_hit']:play()
        end

        -- detect collision on the bottom game area
        if ball.y >= maxBallY then
            ball.dy = -ball.dy
            ball.y = maxBallY - 1
            sounds['wall_hit']:play()
        end

        --  update player 1 paddle
        if love.keyboard.isDown('w') then
            player1.dy = - PADDLE_SPEED
        elseif love.keyboard.isDown('s')  then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0;
        end

        --  update player 2 paddle
        playerIA:update(dt)

        -- update paddles position
        player1:update(dt)
        player2:update(dt)

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
            -- before switching to play, initialize ball's velocity based
            -- on player who last scored
            ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
            else
                ball.dx = -math.random(140, 200)
            end
        elseif gameState == GAME_STATE_SERVE then
            gameState = GAME_STATE_PLAY
        elseif gameState == GAME_STATE_VICTORY then
            gameState = GAME_STATE_START
            player1Score = 0
            player2Score = 0
        end
    end
end

function drawAuthorAndVersion()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.printf(AUTHOR_NAME .. ' ' .. AUTHOR_EMAIL .. ' v' .. GAME_VERSION, 0, VIRTUAL_HEIGHT - 15, VIRTUAL_WIDTH, 'right')
    love.graphics.setColor(1, 1, 1, 1)
    
end

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

MIDDLE_X = 0
MIDDLE_Y = 0

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })

    font = love.graphics.getFont( )
    hello_pong = love.graphics.newText(font, "Hello Pong!")
    hp_tw_half = hello_pong:getWidth() / 2
    print(hp_tw_half)
    MIDDLE_X = WINDOW_WIDTH / 2 - hp_tw_half
    MIDDLE_Y = WINDOW_HEIGHT / 2 - 6
end

function love.draw()
    love.graphics.print("Hello Pong!", MIDDLE_X, MIDDLE_Y)
end


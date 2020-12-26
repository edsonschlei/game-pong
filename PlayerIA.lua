
PlayerIA = Class{}

local DIFICULT_LEVEL = 25

function PlayerIA:init(player, ball)
    self.player = player
    self.ball = ball
    self.player.dy = -PADDLE_SPEED
end

function PlayerIA:update(dt)
    -- self:keyboard()
    self:possibleToWin()
    -- self:alwaysWin()
    -- self:pingPong()
end

--[[
    The player is controlled by the keyboard.
]]
function PlayerIA:keyboard()
    if love.keyboard.isDown('up') then
        self.player.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        self.player.dy = PADDLE_SPEED
    else
        self.player.dy = 0
    end
end

--[[
    The DIFICULT_LEVEL define the times that the player go to
    the wrong direction
]]
function PlayerIA:possibleToWin()
    if self.ball.dx > 0 then
        if math.abs(self.ball.y - self.player.y) < 1 then
            self.player.dy = 0
        elseif self.player.y > self.ball.y then
            self.player.dy = math.random(100) >= DIFICULT_LEVEL and -PADDLE_SPEED or PADDLE_SPEED
        else
            self.player.dy = math.random(100) >= DIFICULT_LEVEL and PADDLE_SPEED or -PADDLE_SPEED
        end
    else
        self.player.dy = 0
    end
end

--[[
    It allways win the game
]]
function PlayerIA:alwaysWin()
    if self.ball.dx > 0 then
        if self.ball.y == self.player.y then
            self.player.dy = 0
        elseif self.player.y > self.ball.y then
            self.player.dy = -PADDLE_SPEED
        else
            self.player.dy = PADDLE_SPEED
        end
    else
        self.player.dy = 0
    end
end

--[[
    Go up and down without stop
]]
function PlayerIA:pingPong()
    if self.player.dy <= 0 then
        if self.player.y <= 0 then
            self.player.dy = PADDLE_SPEED
        end
    else
        if self.player.y + self.player.height >= VIRTUAL_HEIGHT then
            self.player.dy = -PADDLE_SPEED
        end
    end
end


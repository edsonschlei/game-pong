Ball = Class{}

function Ball:init(x,y, width, height)
    self.initX = x
    self.initY = y
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self:reset()
end

--[[
    Updathe the x y position of the ball
]]
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

--[[
    Render the ball
]]
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

--[[
    Reset the ball position and move direction
]]
function Ball:reset()
    self.x = self.initX
    self.y = self.initY
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50) * 1.5
end
Paddle = Class{}

function Paddle:init(x, y, width, height, minY, maxY)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.minY = minY
    self.maxY = maxY
    self.dy = 0
end

--[[
    Update y value based on the defined dy value
]]
function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(self.minY, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(self.maxY, self.y + self.dy * dt)
    end
end

--[[
    Render the paddle
]]
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
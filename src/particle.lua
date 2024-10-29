local Config = require("config")
local Utils = require("src.utils")

local Particle = {}
Particle.__index = Particle

function Particle.new(x, y)
    return setmetatable({
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        isDragged = false,
        lastX = x,
        lastY = y,
        color = Config.COLORS[math.random(#Config.COLORS)]
    }, Particle)
end

function Particle:update(dt, particles)
    if self.isDragged then
        local mx, my = love.mouse.getPosition()
        self.vx = (mx - self.lastX) / dt
        self.vy = (my - self.lastY) / dt
        self.x, self.y = mx, my
        self.lastX, self.lastY = mx, my
    else
        self.vy = self.vy + Config.GRAVITY * dt
        self.vx = self.vx * Config.FRICTION
        self.vy = self.vy * Config.FRICTION
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        -- Wall and floor collisions with refined bounce effect
        if self.x < Config.PARTICLE_SIZE then
            self.vx = math.abs(self.vx) * Config.BOUNCE_DAMPING
            self.x = Config.PARTICLE_SIZE
        elseif self.x > Config.WINDOW_WIDTH - Config.PARTICLE_SIZE then
            self.vx = -math.abs(self.vx) * Config.BOUNCE_DAMPING
            self.x = Config.WINDOW_WIDTH - Config.PARTICLE_SIZE
        end

        if self.y > Config.WINDOW_HEIGHT - Config.PARTICLE_SIZE then
            self.vy = -math.abs(self.vy) * Config.BOUNCE_DAMPING
            self.y = Config.WINDOW_HEIGHT - Config.PARTICLE_SIZE
        elseif self.y < Config.PARTICLE_SIZE then
            self.vy = math.abs(self.vy) * Config.BOUNCE_DAMPING
            self.y = Config.PARTICLE_SIZE
        end
    end

    -- Refined collision handling for inertia
    for _, other in ipairs(particles) do
        if other ~= self then
            Utils.handleCollision(self, other)
        end
    end
end

function Particle:draw()
    if self.isDragged then
        love.graphics.setColor(Config.OUTLINE_COLOR)
        love.graphics.circle("line", self.x, self.y, Config.PARTICLE_SIZE + 2)
    end

    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, Config.PARTICLE_SIZE)

    if Config.DEBUG_MODE then
        self:drawDebugInfo()
    end
end

function Particle:drawDebugInfo()
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(self.x, self.y, self.x + self.vx * 0.1, self.y + self.vy * 0.1)
end

return Particle

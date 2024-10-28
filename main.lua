local Config = {
    WINDOW_WIDTH = 800,
    WINDOW_HEIGHT = 600,
    PARTICLE_SIZE = 15,
    GRAVITY = 9.81 * 60,
    FRICTION = 0.995,
    BOUNCE_DAMPING = 0.7,
    COLORS = {
        {1, 0.3, 0},    -- Deep orange
        {1, 0.5, 0},    -- Regular orange
        {1, 0.6, 0.2},  -- Light orange
        {1, 0.7, 0.3}   -- Pale orange
    }
}

-- Particle class
local Particle = {}
Particle.__index = Particle

function Particle.new(x, y)
    return setmetatable({
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        isDragged = false,
        lastX = x,    -- Track previous position for throwing
        lastY = y,
        color = Config.COLORS[math.random(#Config.COLORS)]
    }, Particle)
end

function Particle:update(dt)
    if self.isDragged then
        -- Calculate velocity based on mouse movement
        local mx, my = love.mouse.getPosition()
        self.vx = (mx - self.lastX) / dt
        self.vy = (my - self.lastY) / dt
        
        -- Update position to match mouse exactly
        self.x = mx
        self.y = my
        
        -- Store current position for next frame
        self.lastX = mx
        self.lastY = my
    else
        -- Apply gravity when not dragged
        self.vy = self.vy + Config.GRAVITY * dt
        
        -- Apply friction
        self.vx = self.vx * Config.FRICTION
        self.vy = self.vy * Config.FRICTION
        
        -- Update position
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
        
        -- Store position for next frame
        self.lastX = self.x
        self.lastY = self.y
    end
    
    -- Bounce off walls
    if self.x < Config.PARTICLE_SIZE then
        self.x = Config.PARTICLE_SIZE
        self.vx = -self.vx * Config.BOUNCE_DAMPING
    elseif self.x > Config.WINDOW_WIDTH - Config.PARTICLE_SIZE then
        self.x = Config.WINDOW_WIDTH - Config.PARTICLE_SIZE
        self.vx = -self.vx * Config.BOUNCE_DAMPING
    end
    
    if self.y < Config.PARTICLE_SIZE then
        self.y = Config.PARTICLE_SIZE
        self.vy = -self.vy * Config.BOUNCE_DAMPING
    elseif self.y > Config.WINDOW_HEIGHT - Config.PARTICLE_SIZE then
        self.y = Config.WINDOW_HEIGHT - Config.PARTICLE_SIZE
        self.vy = -self.vy * Config.BOUNCE_DAMPING
    end
end

function Particle:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, Config.PARTICLE_SIZE)
    if self.isDragged then
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", self.x, self.y, Config.PARTICLE_SIZE)
    end
end

function Particle:isMouseOver(mx, my)
    local dx = mx - self.x
    local dy = my - self.y
    return (dx * dx + dy * dy) <= Config.PARTICLE_SIZE * Config.PARTICLE_SIZE
end

-- Particle System
local ParticleSystem = {
    particles = {},
    draggedParticle = nil
}

function ParticleSystem:update(dt)
    for _, particle in ipairs(self.particles) do
        particle:update(dt)
    end
end

function ParticleSystem:draw()
    for _, particle in ipairs(self.particles) do
        particle:draw()
    end
    
    -- Draw particle count
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Particles: " .. #self.particles, 10, 10)
end

-- Love2D callbacks
function love.load()
    love.window.setMode(Config.WINDOW_WIDTH, Config.WINDOW_HEIGHT)
    love.window.setTitle("Physics Simulator - Click & Throw!")
end

function love.update(dt)
    -- Limit dt to prevent physics issues
    dt = math.min(dt, 1/60)
    ParticleSystem:update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    ParticleSystem:draw()
end

-- Mouse input handlers
function love.mousepressed(x, y, button)
    if button == 1 then
        -- Check if clicking existing particle
        for _, particle in ipairs(ParticleSystem.particles) do
            if particle:isMouseOver(x, y) then
                particle.isDragged = true
                ParticleSystem.draggedParticle = particle
                -- Initialize last position to current position
                particle.lastX = x
                particle.lastY = y
                return
            end
        end
        -- Create new particle if didn't hit existing one
        table.insert(ParticleSystem.particles, Particle.new(x, y))
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and ParticleSystem.draggedParticle then
        ParticleSystem.draggedParticle.isDragged = false
        ParticleSystem.draggedParticle = nil
    end
end

-- Keyboard input handlers
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        ParticleSystem.particles = {}
    end
end

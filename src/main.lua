local Config = require("config")
local Particle = require("particle")

local particles = {}

function love.load()
  love.window.setMode(Config.WINDOW_WIDTH, Config.WINDOW_HEIGHT)
  love.window.setTitle("Particle Collision Simulation")

  for i = 1, 10 do
    table.insert(particles, Particle.new(math.random(Config.WINDOW_WIDTH), math.random(Config.WINDOW_HEIGHT)))
  end
end

function love.update(dt)
  for _, particle in ipairs(particles) do
    particle:update(dt, particles)
  end
end

function love.draw()
  for _, particle in ipairs(particles) do
    particle:draw()
  end

  -- FPS counter
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)

  -- Checkbox for toggling debug mode
  love.graphics.rectangle("line", 10, 40, 15, 15)
  if Config.DEBUG_MODE then
    love.graphics.rectangle("fill", 10, 40, 15, 15)
  end
  love.graphics.print("Debug Mode (Press 'D' to toggle)", 30, 40)
end

function love.mousepressed(x, y, button)
  if button ~= 1 then return end

  -- Check if the checkbox was clicked
  if x >= 10 and x <= 25 and y >= 40 and y <= 55 then
    Config.DEBUG_MODE = not Config.DEBUG_MODE
    return
  end

  -- Check if a particle was clicked
  for _, particle in ipairs(particles) do
    local dx, dy = x - particle.x, y - particle.y
    if dx * dx + dy * dy < Config.PARTICLE_SIZE * Config.PARTICLE_SIZE then
      particle.isDragged = true
      particle.lastX, particle.lastY = x, y
      return
    end
  end
end

function love.mousereleased(_, _, button)
  if button == 1 then
    for _, particle in ipairs(particles) do
      particle.isDragged = false
    end
  end
end

function love.keypressed(key)
  if key == "d" then
    Config.DEBUG_MODE = not Config.DEBUG_MODE
  end
end

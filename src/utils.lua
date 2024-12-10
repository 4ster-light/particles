local Config = require("config")

local Utils = {}

function Utils.handleCollision(p1, p2)
  local dx = p2.x - p1.x
  local dy = p2.y - p1.y
  local distance = math.sqrt(dx * dx + dy * dy)

  if distance < Config.PARTICLE_SIZE * 2 then
    local overlap = Config.PARTICLE_SIZE * 2 - distance
    local nx, ny = dx / distance, dy / distance
    p1.x = p1.x - nx * overlap / 2
    p1.y = p1.y - ny * overlap / 2
    p2.x = p2.x + nx * overlap / 2
    p2.y = p2.y + ny * overlap / 2

    -- Calculate relative velocity
    local relVelX = p2.vx - p1.vx
    local relVelY = p2.vy - p1.vy
    local dotProduct = relVelX * nx + relVelY * ny

    -- Only respond if particles are moving towards each other
    if dotProduct < 0 then
      local impulse = 2 * dotProduct / (1 + 1)
      p1.vx = p1.vx + impulse * nx
      p1.vy = p1.vy + impulse * ny
      p2.vx = p2.vx - impulse * nx
      p2.vy = p2.vy - impulse * ny
    end
  end
end

return Utils

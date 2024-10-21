using LinearAlgebra

function update_position(p::Particle, dt::Float64)::Particle
    x, y = p.position
    vx, vy = p.velocity

    vy -= GRAVITY * dt

    new_x = x + vx * dt
    new_y = y + vy * dt
    
    Particle(p.mass, (new_x, new_y), (vx, vy), p.radius)
end

function handle_wall_collision(p::Particle, box_size::Float64)::Particle
    x, y = p.position
    vx, vy = p.velocity

    if x - p.radius < 0
        x = p.radius
        vx = -vx * WALL_RESTITUTION
    elseif x + p.radius > box_size
        x = box_size - p.radius
        vx = -vx * WALL_RESTITUTION
    end

    if y - p.radius < 0
        y = p.radius
        vy = -vy * WALL_RESTITUTION
    elseif y + p.radius > box_size
        y = box_size - p.radius
        vy = -vy * WALL_RESTITUTION
    end

    Particle(p.mass, (x, y), (vx, vy), p.radius)
end

function handle_particle_collision(p1::Particle, p2::Particle)::Tuple{Particle, Particle}
    dx = p1.position[1] - p2.position[1]
    dy = p1.position[2] - p2.position[2]
    dist = sqrt(dx^2 + dy^2)

    if dist < p1.radius + p2.radius
        normal = [dx, dy] / dist
        relative_velocity = [p1.velocity[1] - p2.velocity[1], p1.velocity[2] - p2.velocity[2]]
        
        velocity_along_normal = dot(relative_velocity, normal)
        
        if velocity_along_normal > 0
            return p1, p2
        end
        
        impulse = (-(1 + PARTICLE_RESTITUTION) * velocity_along_normal) / (1/p1.mass + 1/p2.mass)
        impulse_vector = impulse * normal
        
        new_v1 = (p1.velocity[1] + impulse_vector[1] / p1.mass, p1.velocity[2] + impulse_vector[2] / p1.mass)
        new_v2 = (p2.velocity[1] - impulse_vector[1] / p2.mass, p2.velocity[2] - impulse_vector[2] / p2.mass)
        
        new_p1 = Particle(p1.mass, p1.position, new_v1, p1.radius)
        new_p2 = Particle(p2.mass, p2.position, new_v2, p2.radius)
        
        return new_p1, new_p2
    else
        return p1, p2
    end
end

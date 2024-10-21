function initialize_particles(n::Int, box_size::Float64, speed::Float64)::Vector{Particle}
    particles = Vector{Particle}()

    for _ in 1:n
        x = rand() * box_size
        y = rand() * box_size
        angle = 2 * π * rand()
        vx = speed * cos(angle)
        vy = speed * sin(angle)
        mass = 1.0 + rand() * 5.0
        push!(particles, Particle(mass, (x, y), (vx, vy)))
    end

    particles
end

function update_particle(p::Particle, dt::Float64, box_size::Float64)::Particle
    sub_dt = dt / SUBSTEPS

    for _ in 1:SUBSTEPS
        p = update_position(p, sub_dt)
        p = handle_wall_collision(p, box_size)
    end

    p
end

function simulate(particles::Vector{Particle}, num_steps::Int, dt::Float64, box_size::Float64)::Vector{Vector{Tuple{Float64,Float64}}}
    positions = Vector{Vector{Tuple{Float64,Float64}}}()

    for _ in 1:num_steps
        new_positions = [(p.position) for p in particles]
        push!(positions, new_positions)

        particles = [update_particle(p, dt, box_size) for p in particles]

        for i in 1:length(particles)
            for j in (i+1):length(particles)
                particles[i], particles[j] = handle_particle_collision(particles[i], particles[j])
            end
        end
    end

    positions
end

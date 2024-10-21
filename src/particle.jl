struct Particle
    mass::Float64
    position::Tuple{Float64,Float64}
    velocity::Tuple{Float64,Float64}
    radius::Float64
end

function Particle(mass::Float64, position::Tuple{Float64,Float64}, velocity::Tuple{Float64,Float64})
    Particle(mass, position, velocity, PARTICLE_RADIUS)
end
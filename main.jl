include("src/particle.jl")
include("src/physics.jl")
include("src/simulation.jl")
include("src/visualization.jl")

# Constants
const GRAVITY = 9.81
const BOX_SIZE = 100.0
const TIME_STEP = 0.1
const PARTICLE_RADIUS = 1.0
const SUBSTEPS = 10
const WALL_RESTITUTION = 0.9
const PARTICLE_RESTITUTION = 0.9

# Simulation parameters
const NUM_PARTICLES = 20
const SPEED = 15.0
const NUM_STEPS = 500

# Run the simulation
particles = initialize_particles(NUM_PARTICLES, BOX_SIZE, SPEED)
positions = simulate(particles, NUM_STEPS, TIME_STEP, BOX_SIZE)

# Visualize the results
visualize_simulation(positions, BOX_SIZE)

println()
println("Simulation complete ✅.")
println("Check the generated GIF file 📹.")

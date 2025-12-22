import Foundation

// Screen and viewport constants
let SCREEN_WIDTH: Int32 = 1200
let SCREEN_HEIGHT: Int32 = 800

// Particle physics constants
let PARTICLE_RADIUS: Float = 3.0
let PARTICLE_MIN_DISTANCE: Float = PARTICLE_RADIUS * 2.0
let MAX_PARTICLES: Int = 4096
let GRAVITY: Float = 400.0
let FRICTION: Float = 0.8
let BOUNCE_DAMPING: Float = 0.25
let RESTITUTION: Float = 0.1
let TANGENTIAL_DAMPING: Float = 0.02

// Velocity and collision constants
let MAX_VELOCITY: Float = 800.0
let VELOCITY_THRESHOLD: Float = 30.0
let MIN_VELOCITY_FOR_COLLISION: Float = 0.5

// Grid and collision detection constants
let CELL_SIZE: Float = PARTICLE_MIN_DISTANCE * 2.5
let GRID_WIDTH: Int = Int(SCREEN_WIDTH / Int32(CELL_SIZE)) + 2
let GRID_HEIGHT: Int = Int(SCREEN_HEIGHT / Int32(CELL_SIZE)) + 2
let MAX_PARTICLES_PER_CELL: Int = 256
let COLLISION_DISTANCE_THRESHOLD: Float = PARTICLE_MIN_DISTANCE * 1.5
let COLLISION_DISTANCE_SQ: Float = COLLISION_DISTANCE_THRESHOLD * COLLISION_DISTANCE_THRESHOLD

// Simulation constants
let SOLVER_PASSES: Int = 1
let SPAWN_RATE: Int = 3
let SLEEPING_THRESHOLD: Int = 15
let VELOCITY_SLEEP_THRESHOLD: Float = 0.1

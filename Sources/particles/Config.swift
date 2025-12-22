import Foundation

struct Config {
    // Screen and viewport constants
    static let SCREEN_WIDTH: Int32 = 1200
    static let SCREEN_HEIGHT: Int32 = 800

    // Particle physics constants
    static let PARTICLE_RADIUS: Float = 3.0
    static let PARTICLE_MIN_DISTANCE: Float = PARTICLE_RADIUS * 2.0
    static let MAX_PARTICLES: Int = 4096
    static let GRAVITY: Float = 400.0
    static let FRICTION: Float = 0.8
    static let BOUNCE_DAMPING: Float = 0.25
    static let RESTITUTION: Float = 0.1
    static let TANGENTIAL_DAMPING: Float = 0.02

    // Velocity and collision constants
    static let MAX_VELOCITY: Float = 800.0
    static let VELOCITY_THRESHOLD: Float = 30.0
    static let MIN_VELOCITY_FOR_COLLISION: Float = 0.5

    // Grid and collision detection constants
    static let CELL_SIZE: Float = PARTICLE_MIN_DISTANCE * 2.5
    static let GRID_WIDTH: Int = Int(SCREEN_WIDTH / Int32(CELL_SIZE)) + 2
    static let GRID_HEIGHT: Int = Int(SCREEN_HEIGHT / Int32(CELL_SIZE)) + 2
    static let MAX_PARTICLES_PER_CELL: Int = 256
    static let COLLISION_DISTANCE_THRESHOLD: Float = PARTICLE_MIN_DISTANCE * 1.5
    static let COLLISION_DISTANCE_SQ: Float =
        COLLISION_DISTANCE_THRESHOLD * COLLISION_DISTANCE_THRESHOLD

    // Simulation constants
    static let SOLVER_PASSES: Int = 1
    static let SPAWN_RATE: Int = 3
    static let SLEEPING_THRESHOLD: Int = 15
    static let VELOCITY_SLEEP_THRESHOLD: Float = 0.1
}

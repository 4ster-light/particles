import Foundation
import Raylib

class PhysicsEngine {
	static func handleBoundaryCollisions(particle: inout Particle) {
		let x = particle.position.x
		let y = particle.position.y
		let r = particle.radius
		let screenWidth = Float(SCREEN_WIDTH)
		let screenHeight = Float(SCREEN_HEIGHT)

		// Bottom collision
		if y + r >= screenHeight {
			particle.position.y = screenHeight - r
			particle.velocity.x *= FRICTION
			particle.velocity.y *= -BOUNCE_DAMPING

			if abs(particle.velocity.y) < VELOCITY_THRESHOLD {
				particle.velocity.y = 0.0
			}
			return
		}

		// Left collision
		if x - r <= 0.0 {
			particle.position.x = r
			particle.velocity.x *= -BOUNCE_DAMPING
			return
		}

		// Right collision
		if x + r >= screenWidth {
			particle.position.x = screenWidth - r
			particle.velocity.x *= -BOUNCE_DAMPING
		}
	}

	static func clampVelocity(velocity: inout Vector2) {
		let speedSq = velocity.x * velocity.x + velocity.y * velocity.y
		if speedSq > MAX_VELOCITY * MAX_VELOCITY {
			let speed = sqrt(speedSq)
			let scale = MAX_VELOCITY / speed
			velocity.x *= scale
			velocity.y *= scale
		}
	}
}

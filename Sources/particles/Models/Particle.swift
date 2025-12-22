import Foundation
import Raylib

struct Particle {
	var position: Vector2
	var velocity: Vector2
	var color: Color
	var radius: Float
	var sleepingFrames: Int = 0

	init(position: Vector2, color: Color, radius: Float = Config.PARTICLE_RADIUS) {
		self.position = position
		self.velocity = Vector2(x: 0, y: 0)
		self.color = color
		self.radius = radius
	}

	mutating func resetSleepingCounter() {
		self.sleepingFrames = 0
	}

	func isSleeping() -> Bool {
		return sleepingFrames > Config.SLEEPING_THRESHOLD
	}
}

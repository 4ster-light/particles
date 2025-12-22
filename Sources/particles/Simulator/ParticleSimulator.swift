import Foundation
import Raylib

class ParticleSimulator {
	private var particles: [Particle] = []
	private var grid: SpatialGrid
	private var rng: RandomGenerator
	private var frameCount: Int = 0

	init(maxParticles: Int = MAX_PARTICLES) {
		self.grid = SpatialGrid(width: GRID_WIDTH, height: GRID_HEIGHT)
		self.rng = RandomGenerator()
		self.particles.reserveCapacity(maxParticles)
	}

	func update(deltaTime: Float) {
		// Spawn particles
		if Raylib.isMouseButtonDown(.left) && particles.count < MAX_PARTICLES {
			var spawnCount = SPAWN_RATE
			if Float(particles.count) > Float(MAX_PARTICLES) * 0.85 {
				spawnCount = SPAWN_RATE / 2
			}

			if spawnCount > 0 {
				let mousePos = Raylib.getMousePosition()
				let maxToSpawn = MAX_PARTICLES - particles.count
				let actualSpawn = min(spawnCount, maxToSpawn)

				for _ in 0..<actualSpawn {
					let offset = Vector2(
						x: rng.next() * 10.0,
						y: rng.next() * 10.0
					)

					let particle = Particle(
						position: Vector2(x: mousePos.x + offset.x, y: mousePos.y + offset.y),
						color: ColorPalette.randomSandColor(rng)
					)
					particles.append(particle)
				}
			}
		}

		let particleCount = particles.count

		// Update each particle
		for i in 0..<particleCount {
			particles[i].velocity.y += GRAVITY * deltaTime
			particles[i].velocity.x *= 0.999

			// Fast velocity clamp
			let speedSq =
				particles[i].velocity.x * particles[i].velocity.x + particles[i].velocity.y
				* particles[i].velocity.y
			if speedSq > MAX_VELOCITY * MAX_VELOCITY {
				let speed = sqrt(speedSq)
				let scale = MAX_VELOCITY / speed
				particles[i].velocity.x *= scale
				particles[i].velocity.y *= scale
			}

			// Update position
			particles[i].position.x += particles[i].velocity.x * deltaTime
			particles[i].position.y += particles[i].velocity.y * deltaTime

			// Boundary collisions
			PhysicsEngine.handleBoundaryCollisions(particle: &particles[i])

			// Update sleeping state - aggressive sleeping for very slow particles
			if speedSq < VELOCITY_SLEEP_THRESHOLD * VELOCITY_SLEEP_THRESHOLD {
				particles[i].sleepingFrames = min(
					particles[i].sleepingFrames + 3, SLEEPING_THRESHOLD + 10)
			} else if speedSq < MIN_VELOCITY_FOR_COLLISION * MIN_VELOCITY_FOR_COLLISION {
				particles[i].sleepingFrames += 1
			} else {
				particles[i].sleepingFrames = 0
			}
		}

		// Rebuild spatial grid
		grid.clear()
		for i in 0..<particleCount {
			grid.insert(particleIdx: i, pos: particles[i].position)
		}

		// Collision detection - only for moving particles
		for _ in 0..<SOLVER_PASSES {
			for i in 0..<particleCount {
				if particles[i].isSleeping() { continue }
				resolveCollisions(particleIdx: i)
			}
		}

		frameCount += 1
	}

	func draw() {
		Raylib.beginDrawing()
		Raylib.clearBackground(.black)

		for i in 0..<particles.count {
			let p = particles[i]
			Raylib.drawCircleV(p.position, p.radius, p.color)
		}

		let fps = Raylib.getFPS()
		Raylib.drawText("Hold LEFT CLICK to pour sand", 10, 10, 20, .white)
		Raylib.drawText("Particles: \(particles.count)/\(MAX_PARTICLES)", 10, 35, 20, .white)
		Raylib.drawText("FPS: \(fps)", 10, 60, 20, .white)
		Raylib.drawText("Particle Simulator - Swift", 10, Int32(SCREEN_HEIGHT) - 30, 20, .gray)

		Raylib.endDrawing()
	}

	var particleCount: Int {
		return particles.count
	}

	private func resolveCollisions(particleIdx: Int) {
		guard particleIdx < particles.count else { return }
		guard !particles[particleIdx].isSleeping() else { return }

		let p = particles[particleIdx]
		let minDistSq = PARTICLE_MIN_DISTANCE * PARTICLE_MIN_DISTANCE

		grid.forNearby(pos: p.position) { j in
			guard j > particleIdx else { return }
			guard j < self.particles.count else { return }

			let dx = p.position.x - self.particles[j].position.x
			let dy = p.position.y - self.particles[j].position.y
			let distSq = dx * dx + dy * dy

			// Early exit: particle too far away or not colliding
			if distSq >= minDistSq || distSq < 1e-10 { return }

			let distance = sqrt(distSq)
			let nx = dx / distance
			let ny = dy / distance

			// Gentle separation
			let overlap = PARTICLE_MIN_DISTANCE - distance
			let sepX = nx * overlap * 0.15
			let sepY = ny * overlap * 0.15
			self.particles[particleIdx].position.x += sepX
			self.particles[particleIdx].position.y += sepY
			self.particles[j].position.x -= sepX
			self.particles[j].position.y -= sepY

			// Relative velocity
			let relX = self.particles[particleIdx].velocity.x - self.particles[j].velocity.x
			let relY = self.particles[particleIdx].velocity.y - self.particles[j].velocity.y
			let velDot = relX * nx + relY * ny

			if velDot >= 0.0 { return }

			// Impulse resolution
			var impulseScalar = -(1.0 + RESTITUTION) * velDot * 0.5
			impulseScalar = max(-50.0, min(50.0, impulseScalar))
			let impX = nx * impulseScalar
			let impY = ny * impulseScalar

			self.particles[particleIdx].velocity.x += impX
			self.particles[particleIdx].velocity.y += impY
			self.particles[j].velocity.x -= impX
			self.particles[j].velocity.y -= impY

			// Reset sleeping frame counters on collision
			self.particles[particleIdx].sleepingFrames = 0
			self.particles[j].sleepingFrames = 0

			// Tangential damping
			let velDotP =
				self.particles[particleIdx].velocity.x * nx + self.particles[particleIdx].velocity.y
				* ny
			let velDotO = self.particles[j].velocity.x * nx + self.particles[j].velocity.y * ny
			let tangPx = self.particles[particleIdx].velocity.x - nx * velDotP
			let tangPy = self.particles[particleIdx].velocity.y - ny * velDotP
			let tangOx = self.particles[j].velocity.x - nx * velDotO
			let tangOy = self.particles[j].velocity.y - ny * velDotO

			self.particles[particleIdx].velocity.x -= tangPx * TANGENTIAL_DAMPING
			self.particles[particleIdx].velocity.y -= tangPy * TANGENTIAL_DAMPING
			self.particles[j].velocity.x -= tangOx * TANGENTIAL_DAMPING
			self.particles[j].velocity.y -= tangOy * TANGENTIAL_DAMPING
		}
	}
}

import Foundation
import Raylib

class SpatialGrid {
	private struct GridCell {
		var indices: [Int] = []
		var generation: Int = 0
	}

	private var grid: [GridCell]
	private var width: Int
	private var height: Int
	private var currentGeneration: Int = 0

	private func getGridIndex(_ x: Int, _ y: Int) -> Int {
		let clampedX = max(0, min(x, width - 1))
		let clampedY = max(0, min(y, height - 1))
		return clampedY * width + clampedX
	}

	init(width: Int, height: Int) {
		self.width = width
		self.height = height
		self.grid = Array(repeating: GridCell(), count: width * height)
	}

	func clear() {
		currentGeneration &+= 1
	}

	func insert(particleIdx: Int, pos: Vector2) {
		let cellX = Int(pos.x / CELL_SIZE)
		let cellY = Int(pos.y / CELL_SIZE)
		let idx = getGridIndex(cellX, cellY)

		if grid[idx].generation != currentGeneration {
			grid[idx].generation = currentGeneration
			grid[idx].indices.removeAll(keepingCapacity: true)
		}

		if grid[idx].indices.count < MAX_PARTICLES_PER_CELL {
			grid[idx].indices.append(particleIdx)
		}
	}

	func forNearby(pos: Vector2, callback: (Int) -> Void) {
		let cellX = Int(pos.x / CELL_SIZE)
		let cellY = Int(pos.y / CELL_SIZE)

		for dx in -1...1 {
			for dy in -1...1 {
				let idx = getGridIndex(cellX + dx, cellY + dy)
				if grid[idx].generation == currentGeneration {
					for particleIdx in grid[idx].indices {
						callback(particleIdx)
					}
				}
			}
		}
	}
}

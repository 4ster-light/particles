import Foundation

class RandomGenerator {
	private var generator = SystemRandomNumberGenerator()

	func next() -> Float {
		return Float.random(in: -1.0...1.0, using: &generator)
	}

	func next(min: Float, max: Float) -> Float {
		return min + (next() + 1.0) * 0.5 * (max - min)
	}
}

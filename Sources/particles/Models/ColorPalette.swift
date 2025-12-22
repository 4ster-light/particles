import Foundation
import Raylib

class ColorPalette {
	private static let sandColors: [Color] = [
		Color(r: 194, g: 178, b: 128, a: 255),
		Color(r: 218, g: 165, b: 32, a: 255),
		Color(r: 160, g: 142, b: 95, a: 255),
		Color(r: 139, g: 126, b: 102, a: 255),
		Color(r: 205, g: 192, b: 176, a: 255),
	]

	static func randomSandColor(_ rng: RandomGenerator) -> Color {
		let idx = Int(rng.next(min: 0, max: 5))
		return sandColors[min(idx, 4)]
	}
}

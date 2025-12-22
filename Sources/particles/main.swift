import Foundation
import Raylib

let simulator = ParticleSimulator()

Raylib.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Particle Simulator - Swift")
Raylib.setTargetFPS(60)

while !Raylib.windowShouldClose {
	let deltaTime = Raylib.getFrameTime()
	simulator.update(deltaTime: deltaTime)
	simulator.draw()
}

Raylib.closeWindow()

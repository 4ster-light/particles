# Particle Simulator - Swift Edition

A high-performance particle physics simulator built with Swift and Raylib.

## Features

- Interactive particle spawning with mouse clicks
- Real-time physics simulation with gravity and collisions
- Spatial grid optimization for efficient collision detection
- Sand particle visualization with varied colors
- FPS counter and particle count display

## Requirements

- Swift 6+
- Raylib 4+

## Building & Running

### Using Swift Package Manager

```bash
swift build -c release
swift run -c release
```

## Controls

- **Left Mouse Button**: Hold to spawn sand particles
- **Close Window**: Press the window close button to exit

## Technical Details

- **Particles**: Up to 4096 particles simulated simultaneously
- **Physics**: Gravity, friction, collision response with damping
- **Optimization**: Spatial grid acceleration structure (25×16 cells)
- **Sleeping Particles**: Optimization skips updating particles with minimal
  motion
- **Collision Solver**: Impulse-based response with iterative refinement

## Performance

Target 60 FPS with smooth particle interactions and physics.

## License

MIT

## Sponsor

If you like this project, consider supporting me by buying me a coffee.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/B0B41HVJUR)

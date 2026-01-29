# Particle Simulator

A high-performance particle physics simulator built with Deno, vanilla
TypeScript, HTML5 Canvas, and Vite.

## Features

- Interactive particle spawning with mouse click and drag
- Real-time physics simulation with gravity, friction, and collisions
- Spatial grid optimization for efficient O(1) collision detection
- Accurate impulse-based collision resolution
- Beautiful sand particle visualization with 16-color palette
- Rich HUD with real-time performance metrics and statistics
- Intelligent sleeping system for performance optimization
- Supports up to 4096 particles at 60 FPS

## Requirements

- **Deno 2.6.7+** (with npm integration)
- Modern web browser with HTML5 Canvas support

## Quick Start

```bash
deno task dev
deno task build
deno task preview
```

The dev server will open at `http://localhost:5173`

## Controls

| Control               | Action                         |
| --------------------- | ------------------------------ |
| **Left Click + Drag** | Spawn sand particles at cursor |
| **Space**             | Clear all particles            |
| **P**                 | Pause/Resume simulation        |

## HUD Display

### Top-Right (Performance)

- **FPS**: Frames per second (60-frame rolling average)
- **Frame**: Milliseconds per frame

### Bottom-Left (Particle Information)

- **Particles**: Current count / maximum (4096)
- **Active**: Number of awake particles being simulated
- **Memory**: JavaScript heap usage in MB

### Bottom-Right (Physics Metrics)

- **Collisions**: Collision count detected this frame
- **Avg Velocity**: Average particle velocity
- **Max Velocity**: Fastest particle velocity

## Technical Details

### Physics

- Gravity acceleration: 400 px/s²
- Air friction coefficient: 0.8
- Bounce damping: 0.25
- Max particle velocity: 800 px/s
- Restitution coefficient: 0.1

### Collision Detection

- Spatial grid with cells of 15×15 pixels
- Generation-based clearing for O(1) reset
- 3×3 cell neighborhood search
- Impulse-based resolution with momentum conservation

### Optimization

- Particle sleeping after 15 frames of inactivity
- Generation-based grid clearing (no iteration needed)
- Inline vector math (no library overhead)
- Efficient collision filtering

### Performance

- Target: 60 FPS with 4096 particles
- Frame budget: <16.67ms
- Bundle size: ~4.8 KB gzipped
- Zero runtime dependencies

## Architecture

```txt
src/
├── app.ts              Entry point with Application initialization
├── main.ts             Application lifecycle and event handling
├── particle-system.ts  Particle simulation and physics
├── physics-engine.ts   Physics calculations
├── spatial-grid.ts     Collision acceleration structure
├── renderer.ts         Canvas 2D rendering
├── hud.ts              Statistics and metrics display
├── config.ts           Configuration constants
├── types.ts            TypeScript interfaces
└── utils.ts            Math utilities and color palette
```

## Configuration

Edit `src/config.ts` to customize physics parameters:

```typescript
MAX_PARTICLES: 4096; // Maximum particles
GRAVITY: 400.0; // Gravity acceleration
PARTICLE_RADIUS: 3.0; // Particle size in pixels
BOUNCE_DAMPING: 0.25; // Energy loss on collision
FRICTION: 0.8; // Air resistance
MAX_VELOCITY: 800.0; // Speed limit
SLEEPING_THRESHOLD: 15; // Frames before sleep
```

## License

MIT

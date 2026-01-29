export interface Vector2 {
  x: number;
  y: number;
}

export interface Particle {
  position: Vector2;
  velocity: Vector2;
  color: string;
  radius: number;
  sleepingFrames: number;
}

export interface PhysicsStats {
  collisionsThisFrame: number;
  avgVelocity: number;
  maxVelocity: number;
  activeBodies: number;
}

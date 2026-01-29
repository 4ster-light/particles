import { CONFIG } from "@/config.ts";
import type { Particle, Vector2 } from "@/types.ts";
import { Vec2 } from "@/utils.ts";

export class PhysicsEngine {
  static handleBoundaryCollisions(particle: Particle): void {
    const { x, y } = particle.position;
    const r = particle.radius;
    const screenWidth = CONFIG.SCREEN_WIDTH;
    const screenHeight = CONFIG.SCREEN_HEIGHT;

    if (y + r >= screenHeight) {
      particle.position.y = screenHeight - r;
      particle.velocity.x *= CONFIG.FRICTION;
      particle.velocity.y *= -CONFIG.BOUNCE_DAMPING;

      if (Math.abs(particle.velocity.y) < CONFIG.VELOCITY_THRESHOLD) {
        particle.velocity.y = 0;
      }
      return;
    }

    if (x - r <= 0) {
      particle.position.x = r;
      particle.velocity.x *= -CONFIG.BOUNCE_DAMPING;
      return;
    }

    if (x + r >= screenWidth) {
      particle.position.x = screenWidth - r;
      particle.velocity.x *= -CONFIG.BOUNCE_DAMPING;
    }
  }

  static clampVelocity(velocity: Vector2): void {
    Vec2.clamp(velocity, CONFIG.MAX_VELOCITY);
  }

  static isSleeping(particle: Particle): boolean {
    return particle.sleepingFrames > CONFIG.SLEEPING_THRESHOLD;
  }

  static resetSleepingCounter(particle: Particle): void {
    particle.sleepingFrames = 0;
  }
}

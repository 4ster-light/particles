import { CONFIG } from "@/config.ts";
import type { Particle, PhysicsStats } from "@/types.ts";
import { getRandomSandColor, random, Vec2 } from "@/utils.ts";
import { SpatialGrid } from "@/spatial-grid.ts";
import { PhysicsEngine } from "@/physics-engine.ts";

export class ParticleSystem {
  private particles: Particle[] = [];
  private grid: SpatialGrid;
  private stats: PhysicsStats;

  constructor() {
    this.grid = new SpatialGrid();
    this.stats = {
      collisionsThisFrame: 0,
      avgVelocity: 0,
      maxVelocity: 0,
      activeBodies: 0,
    };
  }

  spawnParticles(x: number, y: number, count: number): void {
    const maxCanSpawn = Math.min(
      count,
      CONFIG.MAX_PARTICLES - this.particles.length,
    );

    for (let i = 0; i < maxCanSpawn; i++) {
      const particle: Particle = {
        position: {
          x: x + random(-10, 10),
          y: y + random(-10, 10),
        },
        velocity: Vec2.zero(),
        color: getRandomSandColor(),
        radius: CONFIG.PARTICLE_RADIUS,
        sleepingFrames: 0,
      };
      this.particles.push(particle);
    }
  }

  update(deltaTime: number): void {
    this.stats.collisionsThisFrame = 0;
    this.stats.avgVelocity = 0;
    this.stats.maxVelocity = 0;
    this.stats.activeBodies = 0;

    const count = this.particles.length;

    for (let i = 0; i < count; i++) {
      const p = this.particles[i];

      p.velocity.y += CONFIG.GRAVITY * deltaTime;
      p.velocity.x *= 0.999;

      PhysicsEngine.clampVelocity(p.velocity);

      p.position.x += p.velocity.x * deltaTime;
      p.position.y += p.velocity.y * deltaTime;

      PhysicsEngine.handleBoundaryCollisions(p);

      const speedSq = Vec2.magnitudeSq(p.velocity);

      if (speedSq < CONFIG.VELOCITY_SLEEP_THRESHOLD ** 2) {
        p.sleepingFrames = Math.min(
          p.sleepingFrames + 3,
          CONFIG.SLEEPING_THRESHOLD + 10,
        );
      } else if (speedSq < CONFIG.MIN_VELOCITY_FOR_COLLISION ** 2) {
        p.sleepingFrames += 1;
      } else {
        p.sleepingFrames = 0;
      }

      const speed = Math.sqrt(speedSq);
      this.stats.avgVelocity += speed;
      this.stats.maxVelocity = Math.max(this.stats.maxVelocity, speed);

      if (!PhysicsEngine.isSleeping(p)) {
        this.stats.activeBodies += 1;
      }
    }

    this.stats.avgVelocity = count > 0 ? this.stats.avgVelocity / count : 0;

    this.grid.clear();
    for (let i = 0; i < count; i++) {
      const p = this.particles[i];
      this.grid.insert(i, p.position.x, p.position.y);
    }

    for (let pass = 0; pass < CONFIG.SOLVER_PASSES; pass++) {
      for (let i = 0; i < count; i++) {
        if (!PhysicsEngine.isSleeping(this.particles[i])) {
          this.resolveCollisions(i);
        }
      }
    }
  }

  private resolveCollisions(particleIdx: number): void {
    const p = this.particles[particleIdx];
    const minDistSq = CONFIG.PARTICLE_MIN_DISTANCE ** 2;

    this.grid.forNearby(p.position.x, p.position.y, (j) => {
      if (j <= particleIdx || j >= this.particles.length) return;

      const other = this.particles[j];
      const dx = p.position.x - other.position.x;
      const dy = p.position.y - other.position.y;
      const distSq = dx * dx + dy * dy;

      if (distSq >= minDistSq || distSq < 1e-10) return;

      const distance = Math.sqrt(distSq);
      const nx = dx / distance;
      const ny = dy / distance;

      const overlap = CONFIG.PARTICLE_MIN_DISTANCE - distance;
      const sepX = nx * overlap * 0.15;
      const sepY = ny * overlap * 0.15;

      p.position.x += sepX;
      p.position.y += sepY;
      other.position.x -= sepX;
      other.position.y -= sepY;

      const relX = p.velocity.x - other.velocity.x;
      const relY = p.velocity.y - other.velocity.y;
      const velDot = relX * nx + relY * ny;

      if (velDot >= 0) return;

      let impulseScalar = -(1 + CONFIG.RESTITUTION) * velDot * 0.5;
      impulseScalar = Math.max(-50, Math.min(50, impulseScalar));

      const impX = nx * impulseScalar;
      const impY = ny * impulseScalar;

      p.velocity.x += impX;
      p.velocity.y += impY;
      other.velocity.x -= impX;
      other.velocity.y -= impY;

      PhysicsEngine.resetSleepingCounter(p);
      PhysicsEngine.resetSleepingCounter(other);

      const velDotP = p.velocity.x * nx + p.velocity.y * ny;
      const velDotO = other.velocity.x * nx + other.velocity.y * ny;
      const tangPx = p.velocity.x - nx * velDotP;
      const tangPy = p.velocity.y - ny * velDotP;
      const tangOx = other.velocity.x - nx * velDotO;
      const tangOy = other.velocity.y - ny * velDotO;

      p.velocity.x -= tangPx * CONFIG.TANGENTIAL_DAMPING;
      p.velocity.y -= tangPy * CONFIG.TANGENTIAL_DAMPING;
      other.velocity.x -= tangOx * CONFIG.TANGENTIAL_DAMPING;
      other.velocity.y -= tangOy * CONFIG.TANGENTIAL_DAMPING;

      this.stats.collisionsThisFrame += 1;
    });
  }

  getParticles(): Particle[] {
    return this.particles;
  }

  getStats(): PhysicsStats {
    return this.stats;
  }

  clear(): void {
    this.particles.length = 0;
  }
}

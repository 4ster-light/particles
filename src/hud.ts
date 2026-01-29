import { CONFIG } from "@/config.ts";

export class HUD {
  private particleCount: HTMLElement;
  private fps: HTMLElement;
  private frameTime: HTMLElement;
  private activeCount: HTMLElement;
  private memory: HTMLElement;
  private collisions: HTMLElement;
  private avgVel: HTMLElement;
  private maxVel: HTMLElement;

  private frameCounter: number = 0;
  private lastTime: number = performance.now();
  private frameTimeSamples: number[] = [];

  constructor() {
    this.particleCount = document.getElementById("particles")!;
    this.fps = document.getElementById("fps")!;
    this.frameTime = document.getElementById("frame-ms")!;
    this.activeCount = document.getElementById("active")!;
    this.memory = document.getElementById("memory")!;
    this.collisions = document.getElementById("collisions")!;
    this.avgVel = document.getElementById("avg-vel")!;
    this.maxVel = document.getElementById("max-vel")!;
  }

  update(
    particles: number,
    active: number,
    collisions: number,
    avgVel: number,
    maxVel: number,
  ): void {
    const now = performance.now();
    const deltaTime = now - this.lastTime;
    this.lastTime = now;

    this.frameTimeSamples.push(deltaTime);
    if (this.frameTimeSamples.length > 60) {
      this.frameTimeSamples.shift();
    }

    this.frameCounter++;

    if (this.frameCounter % 10 === 0) {
      const avgFrameTime = this.frameTimeSamples.reduce((a, b) => a + b, 0) /
        this.frameTimeSamples.length;
      const fps = Math.round(1000 / avgFrameTime);

      this.particleCount.textContent = particles.toString();
      this.fps.textContent = fps.toString();
      this.frameTime.textContent = avgFrameTime.toFixed(2);
      this.activeCount.textContent = active.toString();
      this.collisions.textContent = collisions.toString();
      this.avgVel.textContent = avgVel.toFixed(1);
      this.maxVel.textContent = maxVel.toFixed(1);

      if (
        (performance as typeof performance & {
          memory?: { usedJSHeapSize: number };
        }).memory
      ) {
        const memoryUsedMB = ((performance as typeof performance & {
          memory?: { usedJSHeapSize: number };
        }).memory!.usedJSHeapSize) / 1024 /
          1024;
        this.memory.textContent = memoryUsedMB.toFixed(1);
      }

      const particleRatio = particles / CONFIG.MAX_PARTICLES;
      this.updateWarningClass(this.particleCount.parentElement!, particleRatio);
      this.updateWarningClass(
        this.fps.parentElement!,
        avgFrameTime > 16.67 ? 0.8 : 0,
      );
    }
  }

  private updateWarningClass(element: HTMLElement, ratio: number): void {
    if (ratio > 0.9) {
      element.className = "stat-row critical";
    } else if (ratio > 0.7) {
      element.className = "stat-row warning";
    } else {
      element.className = "stat-row";
    }
  }
}

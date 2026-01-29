import { CONFIG } from "@/config.ts";
import type { Particle } from "@/types.ts";

export class Renderer {
  private ctx: CanvasRenderingContext2D;
  private canvas: HTMLCanvasElement;

  constructor(canvas: HTMLCanvasElement) {
    this.canvas = canvas;
    const ctx = canvas.getContext("2d");
    if (!ctx) throw new Error("Failed to get 2D context");
    this.ctx = ctx;
  }

  resize(): void {
    const maxWidth = globalThis.innerWidth;
    const maxHeight = globalThis.innerHeight;

    const aspectRatio = CONFIG.SCREEN_WIDTH / CONFIG.SCREEN_HEIGHT;
    let width = CONFIG.SCREEN_WIDTH;
    let height = CONFIG.SCREEN_HEIGHT;

    if (width > maxWidth) {
      width = maxWidth;
      height = width / aspectRatio;
    }
    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspectRatio;
    }

    this.canvas.style.width = `${width}px`;
    this.canvas.style.height = `${height}px`;

    this.canvas.width = CONFIG.SCREEN_WIDTH;
    this.canvas.height = CONFIG.SCREEN_HEIGHT;
  }

  clear(): void {
    this.ctx.fillStyle = "#000000";
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
  }

  drawParticle(particle: Particle): void {
    const { x, y } = particle.position;
    const r = particle.radius;

    this.ctx.fillStyle = particle.color;
    this.ctx.beginPath();
    this.ctx.arc(x, y, r, 0, Math.PI * 2);
    this.ctx.fill();
  }

  drawParticles(particles: Particle[]): void {
    for (const particle of particles) {
      this.drawParticle(particle);
    }
  }

  drawBoundaries(): void {
    this.ctx.strokeStyle = "#444444";
    this.ctx.lineWidth = 2;
    this.ctx.strokeRect(0, 0, this.canvas.width, this.canvas.height);
  }
}

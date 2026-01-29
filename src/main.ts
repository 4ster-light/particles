import { CONFIG } from "@/config.ts";
import { ParticleSystem } from "@/particle-system.ts";
import { Renderer } from "@/renderer.ts";
import { HUD } from "@/hud.ts";

interface AppState {
  isRunning: boolean;
  lastFrameTime: number;
  mouseDown: boolean;
  mouseX: number;
  mouseY: number;
}

export class Application {
  private canvas: HTMLCanvasElement;
  private renderer: Renderer;
  private particleSystem: ParticleSystem;
  private hud: HUD;
  private state: AppState;
  private animationFrameId: number | null = null;

  constructor() {
    this.canvas = document.getElementById("canvas") as HTMLCanvasElement;
    if (!this.canvas) throw new Error("Canvas element not found");

    this.renderer = new Renderer(this.canvas);
    this.particleSystem = new ParticleSystem();
    this.hud = new HUD();
    this.state = {
      isRunning: true,
      lastFrameTime: performance.now(),
      mouseDown: false,
      mouseX: 0,
      mouseY: 0,
    };

    this.setupEventListeners();
    this.renderer.resize();
    this.start();
  }

  private setupEventListeners(): void {
    globalThis.addEventListener("resize", () => this.renderer.resize());

    this.canvas.addEventListener("mousedown", (e: MouseEvent) => {
      this.state.mouseDown = true;
      const rect = this.canvas.getBoundingClientRect();
      this.state.mouseX = e.clientX - rect.left;
      this.state.mouseY = e.clientY - rect.top;
    });

    this.canvas.addEventListener("mousemove", (e: MouseEvent) => {
      const rect = this.canvas.getBoundingClientRect();
      this.state.mouseX = e.clientX - rect.left;
      this.state.mouseY = e.clientY - rect.top;
    });

    this.canvas.addEventListener("mouseup", () => {
      this.state.mouseDown = false;
    });

    this.canvas.addEventListener("mouseleave", () => {
      this.state.mouseDown = false;
    });

    globalThis.addEventListener("keydown", (e: KeyboardEvent) => {
      switch (e.code) {
        case "Space":
          e.preventDefault();
          this.particleSystem.clear();
          break;
        case "KeyP":
          this.state.isRunning = !this.state.isRunning;
          break;
      }
    });
  }

  private update(deltaTime: number): void {
    if (
      this.state.mouseDown &&
      this.particleSystem.getParticles().length < CONFIG.MAX_PARTICLES
    ) {
      const spawnCount = CONFIG.SPAWN_RATE;
      this.particleSystem.spawnParticles(
        this.state.mouseX,
        this.state.mouseY,
        spawnCount,
      );
    }

    this.particleSystem.update(deltaTime);
  }

  private render(): void {
    this.renderer.clear();
    this.renderer.drawParticles(this.particleSystem.getParticles());
    this.renderer.drawBoundaries();

    const stats = this.particleSystem.getStats();
    this.hud.update(
      this.particleSystem.getParticles().length,
      stats.activeBodies,
      stats.collisionsThisFrame,
      stats.avgVelocity,
      stats.maxVelocity,
    );
  }

  private loop = (currentTime: number): void => {
    const deltaTime = Math.min(
      (currentTime - this.state.lastFrameTime) / 1000,
      0.016,
    );
    this.state.lastFrameTime = currentTime;

    if (this.state.isRunning) {
      this.update(deltaTime);
    }

    this.render();
    this.animationFrameId = requestAnimationFrame(this.loop);
  };

  private start(): void {
    this.animationFrameId = requestAnimationFrame(this.loop);
  }

  stop(): void {
    if (this.animationFrameId !== null) {
      cancelAnimationFrame(this.animationFrameId);
    }
  }
}

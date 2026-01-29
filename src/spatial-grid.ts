import { CONFIG, GRID_HEIGHT, GRID_WIDTH } from "@/config.ts";

interface GridCell {
  indices: number[];
  generation: number;
}

export class SpatialGrid {
  private grid: GridCell[];
  private currentGeneration: number = 0;

  constructor() {
    this.grid = Array.from({ length: GRID_WIDTH * GRID_HEIGHT }, () => ({
      indices: [],
      generation: -1,
    }));
  }

  private getGridIndex(x: number, y: number): number {
    const clampedX = Math.max(0, Math.min(x, GRID_WIDTH - 1));
    const clampedY = Math.max(0, Math.min(y, GRID_HEIGHT - 1));
    return clampedY * GRID_WIDTH + clampedX;
  }

  clear(): void {
    this.currentGeneration += 1;
  }

  insert(particleIdx: number, x: number, y: number): void {
    const cellX = Math.floor(x / CONFIG.CELL_SIZE);
    const cellY = Math.floor(y / CONFIG.CELL_SIZE);
    const idx = this.getGridIndex(cellX, cellY);

    if (this.grid[idx].generation !== this.currentGeneration) {
      this.grid[idx].generation = this.currentGeneration;
      this.grid[idx].indices.length = 0;
    }

    if (this.grid[idx].indices.length < CONFIG.MAX_PARTICLES_PER_CELL) {
      this.grid[idx].indices.push(particleIdx);
    }
  }

  forNearby(x: number, y: number, callback: (idx: number) => void): void {
    const cellX = Math.floor(x / CONFIG.CELL_SIZE);
    const cellY = Math.floor(y / CONFIG.CELL_SIZE);

    for (let dx = -1; dx <= 1; dx++) {
      for (let dy = -1; dy <= 1; dy++) {
        const idx = this.getGridIndex(cellX + dx, cellY + dy);
        if (this.grid[idx].generation === this.currentGeneration) {
          for (const particleIdx of this.grid[idx].indices) {
            callback(particleIdx);
          }
        }
      }
    }
  }
}

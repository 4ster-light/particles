import type { Vector2 } from "@/types.ts";

export class Vec2 {
  static create(x: number, y: number): Vector2 {
    return { x, y };
  }

  static zero(): Vector2 {
    return { x: 0, y: 0 };
  }

  static add(a: Vector2, b: Vector2): Vector2 {
    return { x: a.x + b.x, y: a.y + b.y };
  }

  static sub(a: Vector2, b: Vector2): Vector2 {
    return { x: a.x - b.x, y: a.y - b.y };
  }

  static mul(v: Vector2, scalar: number): Vector2 {
    return { x: v.x * scalar, y: v.y * scalar };
  }

  static dot(a: Vector2, b: Vector2): number {
    return a.x * b.x + a.y * b.y;
  }

  static magnitude(v: Vector2): number {
    return Math.sqrt(v.x * v.x + v.y * v.y);
  }

  static magnitudeSq(v: Vector2): number {
    return v.x * v.x + v.y * v.y;
  }

  static normalize(v: Vector2): Vector2 {
    const len = Vec2.magnitude(v);
    if (len === 0) return { x: 0, y: 0 };
    return { x: v.x / len, y: v.y / len };
  }

  static scale(v: Vector2, factor: number): void {
    v.x *= factor;
    v.y *= factor;
  }

  static clamp(v: Vector2, maxLength: number): void {
    const lenSq = v.x * v.x + v.y * v.y;
    const maxLenSq = maxLength * maxLength;
    if (lenSq > maxLenSq) {
      const scale = maxLength / Math.sqrt(lenSq);
      v.x *= scale;
      v.y *= scale;
    }
  }
}

export const SAND_COLORS = [
  "#D4A574",
  "#C19A6B",
  "#CD853F",
  "#DEB887",
  "#D2B48C",
  "#B8860B",
  "#DAA520",
  "#F0E68C",
  "#EDD5B1",
  "#FFE4B5",
  "#F5DEB3",
  "#DEB887",
  "#C9B594",
  "#B8A282",
  "#A39872",
  "#8B7D62",
] as const;

export function getRandomSandColor(): string {
  return SAND_COLORS[Math.floor(Math.random() * SAND_COLORS.length)];
}

export function random(min: number = 0, max: number = 1): number {
  return min + Math.random() * (max - min);
}

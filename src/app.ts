import { Application } from "@/main.ts";

console.log("App module loading...");

try {
  console.log("Attempting to create Application...");
  new Application();
  console.log("Particle Simulator initialized successfully");
} catch (error) {
  console.error("Failed to initialize application:", error);
  console.error("Stack:", error instanceof Error ? error.stack : "no stack");
}

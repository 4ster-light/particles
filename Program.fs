#nowarn "3391"

open Raylib_cs
open System.Numerics
open System
open System.Collections.Generic

type Particle =
    { mutable Position: Vector2
      mutable Velocity: Vector2
      Color: Color
      Radius: float32 }

let Gravity = 400.0f
let Friction = 0.8f
let BounceDamping = 0.25f
let MaxParticles = 2056
let ScreenWidth = 1200
let ScreenHeight = 800
let ParticleRadius = 3.0f
let ParticleMinDistance = ParticleRadius * 2.0f
let Restitution = 0.1f
let TangentialDamping = 0.02f

let CellSize = ParticleMinDistance * 2.5f

let rnd = Random()
let particles = ResizeArray<Particle>()
let grid = Dictionary<int * int, ResizeArray<int>>()

let getCell (pos: Vector2) =
    (int (pos.X / CellSize), int (pos.Y / CellSize))

let buildGrid () =
    grid.Clear()

    for i = 0 to particles.Count - 1 do
        let cell = getCell particles[i].Position

        match grid.TryGetValue(cell) with
        | true, lst -> lst.Add(i)
        | _ -> grid[cell] <- ResizeArray([| i |])

let getNearbyIndices (cell: int * int) =
    seq {
        for dx in -1 .. 1 do
            for dy in -1 .. 1 do
                let newCell = (fst cell + dx, snd cell + dy)

                match grid.TryGetValue(newCell) with
                | true, lst -> yield! lst
                | _ -> ()
    }

let getRandomSandColor () =
    match rnd.Next(0, 5) with
    | 0 -> Color(194, 178, 128, 255)
    | 1 -> Color(218, 165, 32, 255)
    | 2 -> Color(160, 142, 95, 255)
    | 3 -> Color(139, 126, 102, 255)
    | _ -> Color(205, 192, 176, 255)

let spawnParticles (mousePos: Vector2) =
    for _ in 0..2 do
        if particles.Count < MaxParticles then
            let offset =
                Vector2(((rnd.NextDouble() - 0.5) |> float32) * 10.0f, ((rnd.NextDouble() - 0.5) |> float32) * 10.0f)

            let newParticle =
                { Position = mousePos + offset
                  Velocity = Vector2.Zero
                  Color = getRandomSandColor ()
                  Radius = ParticleRadius }

            particles.Add(newParticle)

let clampVelocity (v: Vector2) =
    let speed = v.Length()
    if speed > 800.0f then v * (800.0f / speed) else v

let checkParticleCollisions (i: int) =
    let p = particles[i]
    let cell = getCell p.Position

    for j in getNearbyIndices cell do
        if j > i then // avoid double-resolving same pair
            let other = particles[j]
            let diff = p.Position - other.Position
            let distance = diff.Length()

            if distance < ParticleMinDistance && distance > 0.0f then
                let normal =
                    if distance < 1e-6f then
                        Vector2(1.0f, 0.0f)
                    else
                        diff / distance

                // Gentle separation
                let overlap = ParticleMinDistance - distance
                let separation = normal * (overlap * 0.15f)
                p.Position <- p.Position + separation
                other.Position <- other.Position - separation

                // Relative velocity
                let relVel = Vector2.Dot(p.Velocity - other.Velocity, normal)

                if relVel < 0.0f then
                    let mutable impulseScalar = -(1.0f + Restitution) * relVel * 0.5f
                    impulseScalar <- Math.Clamp(impulseScalar, -50.0f, 50.0f)
                    let impulse = impulseScalar * normal

                    p.Velocity <- clampVelocity (p.Velocity + impulse)
                    other.Velocity <- clampVelocity (other.Velocity - impulse)

                    // Tangential damping
                    let tangentP = p.Velocity - Vector2.Dot(p.Velocity, normal) * normal
                    let tangentO = other.Velocity - Vector2.Dot(other.Velocity, normal) * normal
                    p.Velocity <- p.Velocity - tangentP * TangentialDamping
                    other.Velocity <- other.Velocity - tangentO * TangentialDamping

                    // Small random jitter to break symmetry
                    let jitter =
                        Vector2(
                            ((rnd.NextDouble() - 0.5) |> float32) * 2.0f,
                            ((rnd.NextDouble() - 0.5) |> float32) * 2.0f
                        )

                    p.Position <- p.Position + jitter * 0.02f
                    other.Position <- other.Position - jitter * 0.02f

let updateParticle (particle: Particle) (deltaTime: float32) =
    particle.Velocity <- particle.Velocity + Vector2(0.0f, Gravity * deltaTime)
    particle.Velocity <- Vector2(particle.Velocity.X * 0.999f, particle.Velocity.Y)
    particle.Velocity <- clampVelocity particle.Velocity

    let newPosition = particle.Position + particle.Velocity * deltaTime

    if newPosition.Y + particle.Radius >= float32 ScreenHeight then
        particle.Position <- Vector2(newPosition.X, float32 ScreenHeight - particle.Radius)
        particle.Velocity <- Vector2(particle.Velocity.X * Friction, particle.Velocity.Y * -BounceDamping)

        if abs particle.Velocity.Y < 30.0f then
            particle.Velocity <- Vector2(particle.Velocity.X, 0.0f)
    elif newPosition.X - particle.Radius <= 0.0f then
        particle.Position <- Vector2(particle.Radius, newPosition.Y)
        particle.Velocity <- Vector2(particle.Velocity.X * -BounceDamping, particle.Velocity.Y)
    elif newPosition.X + particle.Radius >= float32 ScreenWidth then
        particle.Position <- Vector2(float32 ScreenWidth - particle.Radius, newPosition.Y)
        particle.Velocity <- Vector2(particle.Velocity.X * -BounceDamping, particle.Velocity.Y)
    else
        particle.Position <- newPosition

let Update (deltaTime: float32) =
    if Raylib.IsMouseButtonDown(MouseButton.Left) && particles.Count < MaxParticles then
        Raylib.GetMousePosition() |> spawnParticles

    for i = 0 to particles.Count - 1 do
        updateParticle particles[i] deltaTime

    buildGrid ()

    // 2 solver passes for stability vs. performance balance
    for _ = 1 to 2 do
        for i = 0 to particles.Count - 1 do
            checkParticleCollisions i

let Draw () =
    Raylib.BeginDrawing()
    Raylib.ClearBackground(Color.Black)

    for i = 0 to particles.Count - 1 do
        let p = particles[i]
        Raylib.DrawCircleV(p.Position, p.Radius, p.Color)

    Raylib.DrawText("Hold LEFT CLICK to pour sand", 10, 10, 20, Color.White)
    Raylib.DrawText($"Particles: {particles.Count}/{MaxParticles}", 10, 35, 20, Color.White)
    Raylib.DrawText("Particle Simulator - RaylibFS", 10, ScreenHeight - 30, 20, Color.Gray)
    Raylib.EndDrawing()

[<EntryPoint>]
let main _ =
    Raylib.InitWindow(ScreenWidth, ScreenHeight, "Particle Simulator")
    Raylib.SetTargetFPS(60)

    while not (Raylib.WindowShouldClose()) do
        let deltaTime = Raylib.GetFrameTime()
        Update deltaTime
        Draw()

    Raylib.CloseWindow()
    0

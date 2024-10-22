using Plots

function visualize_simulation(positions::Vector{Vector{Tuple{Float64,Float64}}}, box_size::Float64)
    anim = @animate for step in positions
        scatter([p[1] for p in step], [p[2] for p in step],
            xlims=(0, box_size), ylims=(0, box_size),
            markersize=5, legend=false, aspect_ratio=:equal)
    end

    gif(anim, "simulation.gif", fps=30)
end

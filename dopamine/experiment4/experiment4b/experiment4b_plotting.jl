using DataFrames
using CSV
using CategoricalArrays
using GLMakie



# LOAD SPEEDS CSV INTO DATAFRAME
experimentdir = @__DIR__
speedscsv = joinpath(experimentdir, "speeds.csv")
speeds = DataFrame(CSV.File(speedscsv))



# MAKE CATEGORICAL ARRAYS FOR PLOTTING
speeds.medium = categorical(map(i-> split(i, '_')[1], speeds.id), levels = ["M9", "DA"])
speeds.worm = categorical(map(i-> split(i, '_')[2], speeds.id), levels = ["N2", "CB", "MT"])
speeds.bacteria = categorical(map(i-> split(i, '_')[3], speeds.id), levels = ["NGM", "OP50"])
speeds.id = categorical(speeds.id, levels=[ "DA_N2_OP50", "DA_N2_NGM",
                                            "DA_CB_OP50", "DA_CB_NGM",
                                            "DA_MT_OP50", "DA_MT_NGM",
                                            "M9_N2_OP50", "M9_N2_NGM",
                                            "M9_CB_OP50", "M9_CB_NGM",
                                            "M9_MT_OP50", "M9_MT_NGM"])



# separate speeds into two different dfs based on medium
bufferspeeds = filter(:medium => m -> m == "M9", speeds)
dopaminespeeds = filter(:medium => m -> m == "DA", speeds)



# PLOT

# all 12 conditions evenly spaced in one plot
# fig1 = Figure(
# )

# ax1 = Axis(
#     fig1[1,1],
#     xticks = (1:12, levels(speeds.id)),
#     xticklabelrotation = π/2,
#     ylabel = "Average Speed (<unit>)",
# )

# ylims!(0,150000)

# boxplot!(levelcode.(speeds.id), speeds.speed)

# save(joinpath(experimentdir, "fig1.png"), fig1)

# two boxplots in one figure: plots = medium, xaxis = worm, grouping = bacteria
fig2 = Figure(
)

ax2a = Axis(
    fig2[1,1],
    title = "M9",
    xlabel = "Worm strain",
    # xlabelfont = "TeX Gyre Heros Makie Italic",
    xticks = (1:3, levels(bufferspeeds.worm)),
    ylabel = "Average speed (µm/sec)",
)

ylims!(0,450)
dodge = levelcode.(bufferspeeds.bacteria)

boxplot!(ax2a, levelcode.(bufferspeeds.worm), bufferspeeds.speed, dodge = dodge, color = map(d->d==1 ? :blue : :red, dodge))

ax2b = Axis(
    fig2[1,2],
    title = "DA",
    xlabel = "Worm strain",
    xticks = (1:3, levels(dopaminespeeds.worm)),
    ylabel = "Average speed (µm/sec)",
)

ylims!(0,450)
dodge = levelcode.(dopaminespeeds.bacteria)

boxplot!(ax2b, levelcode.(dopaminespeeds.worm), dopaminespeeds.speed, dodge = dodge, color = map(d->d==1 ? :blue : :red, dodge))

hideydecorations!(ax2b, grid = false)


elem_1 = [PolyElement(color = :blue)]
elem_2 = [PolyElement(color = :red)]

Legend(fig2[2, :],
    [elem_1, elem_2],
    ["No", "Yes"],
    "Bacteria Presence",
    orientation = :horizontal,
    titleposition = :left)


save(joinpath(experimentdir, "fig2.png"), fig2)



# two violin plots in one figure: plots = medium, xaxis = worm, grouping = bacteria
fig3 = Figure(
    )
    
ax3a = Axis(
    fig3[1,1],
    title = "M9",
    xlabel = "Worm strain",
    # xlabelfont = "TeX Gyre Heros Makie Italic",
    xticks = (1:3, levels(bufferspeeds.worm)),
    ylabel = "Average speed (µm/sec)",
)

ylims!(-50,500)
dodge = levelcode.(bufferspeeds.bacteria)

violin!(ax3a, levelcode.(bufferspeeds.worm), bufferspeeds.speed, dodge = dodge, color = map(d->d==1 ? :blue : :red, dodge))

ax3b = Axis(
    fig3[1,2],
    title = "DA",
    xlabel = "Worm strain",
    xticks = (1:3, levels(dopaminespeeds.worm)),
    ylabel = "Average speed (µm/sec)",
)

ylims!(-50,500)
dodge = levelcode.(dopaminespeeds.bacteria)

violin!(ax3b, levelcode.(dopaminespeeds.worm), dopaminespeeds.speed, dodge = dodge, color = map(d->d==1 ? :blue : :red, dodge))

hideydecorations!(ax3b, grid = false)


elem_1 = [PolyElement(color = :blue)]
elem_2 = [PolyElement(color = :red)]

Legend(fig3[2, :],
    [elem_1, elem_2],
    ["No", "Yes"],
    "Bacteria Presence",
    orientation = :horizontal,
    titleposition = :left)


save(joinpath(experimentdir, "fig3.png"), fig3)

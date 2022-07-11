using DataFrames
using CSV
using CategoricalArrays
using GLMakie
using CeDataAnalysis
using Statistics
using StatsBase



# LOAD SPEEDS CSV INTO DATAFRAME
experimentdir = @__DIR__

speeds = DataFrame(CSV.File("./dopamine/experiment4/experiment4b/speeds.csv"))



# CALCULATE SUMMARY STATS BY FIRST CALCULATING SUMMARY STATS OF EACH TRACK
# individual track stats
tracks = groupby(speeds, [:id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed)

# condition stats from individual stats 
conditions = groupby(trackstats, [:id])
speedstats = combine(conditions, :meanspeed => mean => :meanofmeanspeed, :meanspeed => sem => :semofmeanspeed)
# legnth of each DF is # tracks, which = sample size



# MAKE CATEGORICAL ARRAYS FOR PLOTTING
speedstats.medium = categorical(map(i-> split(i, '_')[1], speedstats.id), levels = ["M9", "DA"])
speedstats.worm = categorical(map(i-> split(i, '_')[2], speedstats.id), levels = ["N2", "CB", "MT"])
speedstats.bacteria = categorical(map(i-> split(i, '_')[3], speedstats.id), levels = ["NGM", "OP50"])
speedstats.id = categorical(speedstats.id, levels=[ "DA_N2_OP50", "DA_N2_NGM",
                                            "DA_CB_OP50", "DA_CB_NGM",
                                            "DA_MT_OP50", "DA_MT_NGM",
                                            "M9_N2_OP50", "M9_N2_NGM",
                                            "M9_CB_OP50", "M9_CB_NGM",
                                            "M9_MT_OP50", "M9_MT_NGM"])

# separate speeds into two different dfs based on medium
bufferspeedstats = filter(:medium => m -> m == "M9", speedstats)
dopaminespeedstats = filter(:medium => m -> m == "DA", speedstats)



# PLOT

# all 12 conditions evenly spaced in one plot
fig1 = Figure(
)

ax1 = Axis(
    fig1[1,1],
    xticks = (1:12, levels(speedstats.id)),
    xticklabelrotation = π/2,
    ylabel = "Average Speed (<unit>)",
)

barplot!(levelcode.(speedstats.id), speedstats.meanofmeanspeed)
errorbars!(levelcode.(speedstats.id), speedstats.meanofmeanspeed, speedstats.semofmeanspeed)

save(joinpath(experimentdir, "fig1.png"), fig1)



# two barplots in one figure: plots = medium, xaxis = worm, grouping = bacteria
fig2 = Figure(
)

ax2a = Axis(
    fig2[1,1],
    title = "M9",
    xlabel = "C. elegans strain",
    xticks = (1:3, levels(bufferspeedstats.worm)),
    ylabel = "Average speed (µm/sec)",
)

ylims!(0,300)
dodge = levelcode.(bufferspeedstats.bacteria)

barplot!(ax2a, levelcode.(bufferspeedstats.worm), bufferspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? :blue : :red, dodge))
errorbars!(ax2a, levelcode.(bufferspeedstats.worm), bufferspeedstats.meanofmeanspeed, bufferspeedstats.semofmeanspeed)

ax2b = Axis(
    fig2[1,2],
    title = "DA",
    xlabel = "C. elegans strain",
    xticks = (1:3, levels(dopaminespeedstats.worm)),
    ylabel = "Average speed (µm/sec)",
)

ylims!(0,300)
dodge = levelcode.(dopaminespeedstats.bacteria)

barplot!(ax2b, levelcode.(dopaminespeedstats.worm), dopaminespeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? :blue : :red, dodge))
errorbars!(ax2b, levelcode.(dopaminespeedstats.worm), dopaminespeedstats.meanofmeanspeed, dopaminespeedstats.semofmeanspeed)

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

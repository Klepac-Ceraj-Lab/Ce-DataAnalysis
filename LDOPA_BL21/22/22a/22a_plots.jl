using DataFrames
using CSV
using CategoricalArrays
using GLMakie
using CeDataAnalysis
using Statistics
using StatsBase



# LOAD SPEEDS CSV INTO DATAFRAME
experimentdir = @__DIR__

speeds = DataFrame(CSV.File(joinpath(experimentdir, "speeds.csv")))

# CALCULATE SUMMARY STATS BY FIRST CALCULATING SUMMARY STATS OF EACH TRACK
# individual track stats
tracks = groupby(speeds, [:id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed)

# condition stats from individual stats 
conditions = groupby(trackstats, [:id])
speedstats = combine(conditions, :meanspeed => mean => :meanofmeanspeed, :meanspeed => sem => :semofmeanspeed, :track => length => :n)
# legnth of each DF is # tracks, which = sample size



# MAKE CATEGORICAL ARRAYS FOR PLOTTING
speedstats.medium = categorical(map(i-> split(i, '_')[1], speedstats.id), levels = ["M9", "LD"])
speedstats.worm = categorical(map(i-> split(i, '_')[2], speedstats.id), levels = ["N2", "CB", "MT"])
speedstats.bacteria = categorical(map(i-> split(i, '_')[3], speedstats.id), levels = ["NGM", "BL21"])
speedstats.id = categorical(speedstats.id, levels=[ "LD_N2_BL21", "LD_N2_NGM",
                                            "LD_CB_BL21", "LD_CB_NGM",
                                            "LD_MT_BL21", "LD_MT_NGM",
                                            "M9_N2_BL21", "M9_N2_NGM",
                                            "M9_CB_BL21", "M9_CB_NGM",
                                            "M9_MT_BL21", "M9_MT_NGM"])

# separate speeds into two different dfs based on medium
bufferspeedstats = filter(:medium => m -> m == "M9", speedstats)
ldopaspeedstats = filter(:medium => m -> m == "LD", speedstats)



# ANALYSIS FOR JITTERED DOT PLOT

# dot plot of average speeds of each track in each condition needs trackstats
trackstats.medium = categorical(map(i-> split(i, '_')[1], trackstats.id), levels = ["M9", "LD"])
trackstats.bacteria = categorical(map(i-> split(i, '_')[3], trackstats.id), levels = ["NGM", "BL21"])
trackstats.id = categorical(trackstats.id, levels=[ "LD_N2_BL21", "LD_N2_NGM",
                                            "LD_CB_BL21", "LD_CB_NGM",
                                            "LD_MT_BL21", "LD_MT_NGM",
                                            "M9_N2_BL21", "M9_N2_NGM",
                                            "M9_CB_BL21", "M9_CB_NGM",
                                            "M9_MT_BL21", "M9_MT_NGM"])

# separate speeds into two different dfs based on medium and bacteria
buffertrackstats = filter(:medium => m -> m == "M9", trackstats)
ldopatrackstats = filter(:medium => m -> m == "LD", trackstats)

# add id level codes to each df and reassign values for scatter
buffertrackstats.idlevel = levelcode.(buffertrackstats.id)
buffertrackstats.idlevel = replace(buffertrackstats.idlevel, 7=>1.2, 8=>0.8, 9=>2.2, 10=>1.8, 11=>3.2, 12=>2.8)
ldopatrackstats.idlevel = levelcode.(ldopatrackstats.id)
ldopatrackstats.idlevel = replace(ldopatrackstats.idlevel, 1=>1.2, 2=>0.8, 3=>2.2, 4=>1.8, 5=>3.2, 6=>2.8)

# split buffer and ldopa DFs by bactera in order to assign colors
bufferno = filter(:bacteria => b -> b == "NGM", buffertrackstats)
bufferyes = filter(:bacteria => b -> b == "BL21", buffertrackstats)
ldopano = filter(:bacteria => b -> b == "NGM", ldopatrackstats)
ldopayes = filter(:bacteria => b -> b == "BL21", ldopatrackstats)



# PLOT

# mean ± SEM w jitter dot plot

# define error bars at middle of each dodged bar
errorpos = [1.2, 0.8, 2.2, 1.8, 3.2, 2.8]

fig4 = Figure(
)

ax4a = Axis(
    fig4[1,1],
    title = "Buffer",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = (1:3, ["wild type", "cat-2 CB", "cat-2 MT"]),
    xlabelfont = "TeX Gyre Heros Makie Bold",
    ylabel = "Average speed (µm/sec)",
    ylabelfont = "TeX Gyre Heros Makie Bold",
    titlecolor = "#825ca5",
    topspinecolor = "#825ca5",
    bottomspinecolor = "#825ca5",
    leftspinecolor = "#825ca5",
    rightspinecolor = "#825ca5",
)

dodge = levelcode.(bufferspeedstats.bacteria)

barplot!(ax4a, levelcode.(bufferspeedstats.worm), bufferspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax4a, bufferno.idlevel .+ rand(-0.1:0.01:0.1, length(bufferno.idlevel)), bufferno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax4a, bufferyes.idlevel .+ rand(-0.1:0.01:0.1, length(bufferyes.idlevel)), bufferyes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax4a, errorpos, bufferspeedstats.meanofmeanspeed, bufferspeedstats.semofmeanspeed, linewidth = 2)

ax4b = Axis(
    fig4[1,2],
    title = "L-DOPA",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = (1:3, ["wild type", "cat-2 CB", "cat-2 MT"]),
    xlabelfont = "TeX Gyre Heros Makie Bold",
    ylabel = "Average speed (µm/sec)",
    ylabelfont = "TeX Gyre Heros Makie Bold",
    titlecolor = "#5aaa46",
    topspinecolor = "#5aaa46",
    bottomspinecolor = "#5aaa46",
    leftspinecolor = "#5aaa46",
    rightspinecolor = "#5aaa46",
)

dodge = levelcode.(ldopaspeedstats.bacteria)

barplot!(ax4b, levelcode.(ldopaspeedstats.worm), ldopaspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax4b, ldopano.idlevel .+ rand(-0.1:0.01:0.1, length(ldopano.idlevel)), ldopano.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax4b, ldopayes.idlevel .+ rand(-0.1:0.01:0.1, length(ldopayes.idlevel)), ldopayes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax4b, errorpos, ldopaspeedstats.meanofmeanspeed, ldopaspeedstats.semofmeanspeed, linewidth = 2)

linkyaxes!(ax4a, ax4b)

hideydecorations!(ax4b, grid = false)


elem_1 = [PolyElement(color = "#bbdaef")]
elem_2 = [PolyElement(color = "#efafcb")]

Legend(fig4[2, :],
    [elem_1, elem_2],
    ["No", "Yes"],
    "Bacteria Presence",
    orientation = :horizontal,
    titleposition = :left)

save(joinpath(experimentdir, "fig04.png"), fig4)

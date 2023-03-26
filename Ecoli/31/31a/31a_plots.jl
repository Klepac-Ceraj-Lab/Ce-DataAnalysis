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
trackstats = combine(tracks, :speed => mean => :meanspeed, :track => length => :n) # add legnth of each track (# data points)

# data point = speed/5s --> only keep tracks w > 6pts ie. more than 30s
filter!(row -> row.n > 6, trackstats)

# condition stats from individual stats 
conditions = groupby(trackstats, [:id])
speedstats = combine(conditions, :meanspeed => mean => :meanofmeanspeed, :meanspeed => sem => :semofmeanspeed, :meanspeed => std => :stdofmeanspeed, :track => length => :n)
# length of each DF is # tracks, which = sample size



# MAKE CATEGORICAL ARRAYS FOR PLOTTING
speedstats.medium = categorical(map(i-> split(i, '_')[1], speedstats.id), levels = ["H2O", "IPTG"])
speedstats.worm = categorical(map(i-> split(i, '_')[2], speedstats.id), levels = ["N2", "CB"])
speedstats.bacteria = categorical(map(i-> split(i, '_')[3], speedstats.id), levels = ["NGM", "BL21"])
speedstats.id = categorical(speedstats.id, levels=[ "IPTG_N2_BL21", "IPTG_N2_NGM",
                                            "IPTG_CB_BL21", "IPTG_CB_NGM",
                                            "H2O_N2_BL21", "H2O_N2_NGM",
                                            "H2O_CB_BL21", "H2O_CB_NGM",])

# separate speeds into two different dfs based on medium
waterspeedstats = filter(:medium => m -> m == "H2O", speedstats)
iptgspeedstats = filter(:medium => m -> m == "IPTG", speedstats)



# ANALYSIS FOR JITTERED DOT PLOT

# dot plot of average speeds of each track in each condition needs trackstats
trackstats.medium = categorical(map(i-> split(i, '_')[1], trackstats.id), levels = ["H2O", "IPTG"])
trackstats.bacteria = categorical(map(i-> split(i, '_')[3], trackstats.id), levels = ["NGM", "BL21"])
trackstats.id = categorical(trackstats.id, levels=[ "IPTG_N2_BL21", "IPTG_N2_NGM",
                                            "IPTG_CB_BL21", "IPTG_CB_NGM",
                                            "H2O_N2_BL21", "H2O_N2_NGM",
                                            "H2O_CB_BL21", "H2O_CB_NGM",])

# separate speeds into two different dfs based on medium and bacteria
watertrackstats = filter(:medium => m -> m == "H2O", trackstats)
iptgtrackstats = filter(:medium => m -> m == "IPTG", trackstats)

# add id level codes to each df and reassign values for scatter
watertrackstats.idlevel = levelcode.(watertrackstats.id)
watertrackstats.idlevel = replace(watertrackstats.idlevel, 5=>1.2, 6=>0.8, 7=>2.2, 8=>1.8)
iptgtrackstats.idlevel = levelcode.(iptgtrackstats.id)
iptgtrackstats.idlevel = replace(iptgtrackstats.idlevel, 1=>1.2, 2=>0.8, 3=>2.2, 4=>1.8)

# split water and iptg DFs by bactera in order to assign colors
waterno = filter(:bacteria => b -> b == "NGM", watertrackstats)
wateryes = filter(:bacteria => b -> b == "BL21", watertrackstats)
iptgno = filter(:bacteria => b -> b == "NGM", iptgtrackstats)
iptgyes = filter(:bacteria => b -> b == "BL21", iptgtrackstats)



# PLOT

# mean ± SEM w jitter dot plot

# define error bars at middle of each dodged bar
errorpos = [1.2, 0.8, 2.2, 1.8]

fig4 = Figure(
)

ax4a = Axis(
    fig4[1,1],
    title = "IPTG(-)",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = (1:2, ["wild type", "cat-2 CB"]),
    xlabelfont = "TeX Gyre Heros Makie Bold",
    ylabel = "Average speed (µm/sec)",
    ylabelfont = "TeX Gyre Heros Makie Bold",
    titlecolor = "#825ca5",
    topspinecolor = "#825ca5",
    bottomspinecolor = "#825ca5",
    leftspinecolor = "#825ca5",
    rightspinecolor = "#825ca5",
)

dodge = levelcode.(waterspeedstats.bacteria)

barplot!(ax4a, levelcode.(waterspeedstats.worm), waterspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax4a, waterno.idlevel .+ rand(-0.1:0.01:0.1, length(waterno.idlevel)), waterno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax4a, wateryes.idlevel .+ rand(-0.1:0.01:0.1, length(wateryes.idlevel)), wateryes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax4a, errorpos, waterspeedstats.meanofmeanspeed, waterspeedstats.semofmeanspeed, linewidth = 2)

ax4b = Axis(
    fig4[1,2],
    title = "IPTG(+)",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = (1:2, ["wild type", "cat-2 CB"]),
    xlabelfont = "TeX Gyre Heros Makie Bold",
    ylabel = "Average speed (µm/sec)",
    ylabelfont = "TeX Gyre Heros Makie Bold",
    titlecolor = "#5aaa46",
    topspinecolor = "#5aaa46",
    bottomspinecolor = "#5aaa46",
    leftspinecolor = "#5aaa46",
    rightspinecolor = "#5aaa46",
)

dodge = levelcode.(iptgspeedstats.bacteria)

barplot!(ax4b, levelcode.(iptgspeedstats.worm), iptgspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax4b, iptgno.idlevel .+ rand(-0.1:0.01:0.1, length(iptgno.idlevel)), iptgno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax4b, iptgyes.idlevel .+ rand(-0.1:0.01:0.1, length(iptgyes.idlevel)), iptgyes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax4b, errorpos, iptgspeedstats.meanofmeanspeed, iptgspeedstats.semofmeanspeed, linewidth = 2)

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



# FIG 9 = prettily formatted FIG 4

# define error bars at middle of each dodged bar
errorpos = [1.2, 0.8, 2.2, 1.8]

fig9 = Figure(
)

ax9a = Axis(
    fig9[1,1],
    title = "IPTG(-)",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = (1:2, ["wild type", "cat-2 CB"]),
    xlabelfont = "TeX Gyre Heros Makie Bold",
    ylabel = "Average speed (µm/sec)",
    ylabelfont = "TeX Gyre Heros Makie Bold",
    titlecolor = "#825ca5",
    topspinecolor = "#FFFFFF",
    bottomspinecolor = "#825ca5",
    rightspinecolor = "#FFFFFF",
)

ylims!(0, 400)
hidedecorations!(ax9a, label = false, ticklabels = false, ticks = false)

dodge = levelcode.(waterspeedstats.bacteria)

barplot!(ax9a, levelcode.(waterspeedstats.worm), waterspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax9a, waterno.idlevel .+ rand(-0.1:0.01:0.1, length(waterno.idlevel)), waterno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax9a, wateryes.idlevel .+ rand(-0.1:0.01:0.1, length(wateryes.idlevel)), wateryes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax9a, errorpos, waterspeedstats.meanofmeanspeed, waterspeedstats.semofmeanspeed, linewidth = 2)

ax9b = Axis(
    fig9[1,2],
    title = "IPTG(+)",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = (1:2, ["wild type", "cat-2 CB"]),
    xlabelfont = "TeX Gyre Heros Makie Bold",
    ylabel = "Average speed (µm/sec)",
    ylabelfont = "TeX Gyre Heros Makie Bold",
    titlecolor = "#5aaa46",
    topspinecolor = "#FFFFFF",
    bottomspinecolor = "#5aaa46",
    leftspinecolor = "#FFFFFF",
    rightspinecolor = "#FFFFFF",
)

ylims!(0, 400)
hidedecorations!(ax9b, label = false, ticklabels = false, ticks = false)

dodge = levelcode.(iptgspeedstats.bacteria)

barplot!(ax9b, levelcode.(iptgspeedstats.worm), iptgspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax9b, iptgno.idlevel .+ rand(-0.1:0.01:0.1, length(iptgno.idlevel)), iptgno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax9b, iptgyes.idlevel .+ rand(-0.1:0.01:0.1, length(iptgyes.idlevel)), iptgyes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax9b, errorpos, iptgspeedstats.meanofmeanspeed, iptgspeedstats.semofmeanspeed, linewidth = 2)

hideydecorations!(ax9b, grid = false)


elem_1 = [PolyElement(color = "#bbdaef")]
elem_2 = [PolyElement(color = "#efafcb")]

Legend(fig9[2, :],
    [elem_1, elem_2],
    ["No", "Yes"],
    "Bacteria Presence",
    orientation = :horizontal,
    titleposition = :left)

save(joinpath(experimentdir, "fig09.png"), fig9)

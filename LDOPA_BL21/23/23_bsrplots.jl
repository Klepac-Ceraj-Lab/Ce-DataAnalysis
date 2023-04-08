# PLOTS OF BASAL SLOWING RESPONSE

using DataFrames
using CSV
using CategoricalArrays
using GLMakie
using Statistics
using StatsBase
using Distributions



# LOAD SPEEDS CSV INTO DATAFRAME
experimentdir = @__DIR__

speeds = DataFrame(CSV.File(joinpath(experimentdir, "speeds.csv")))

# CALCULATE SUMMARY STATS BY FIRST CALCULATING SUMMARY STATS OF EACH TRACK
# individual track stats
tracks = groupby(speeds, [:experiment, :id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed, :track => length => :n) # add legnth of each track (# data points)

# data point = speed/5s --> only keep tracks w > 6pts ie. more than 30s
filter!(row -> row.n > 6, trackstats)

# condition stats from individual stats 
conditions = groupby(trackstats, [:id])
speedstats = combine(conditions, :meanspeed => mean => :meanofmeanspeed, :meanspeed => sem => :semofmeanspeed, :meanspeed => std => :stdofmeanspeed, :track => length => :n)
# legnth of each DF is # tracks, which = sample size



# SAVE SUMMARY STATS DATAFRAME
summarystatscsv = joinpath(experimentdir, "summarystats.csv")

CSV.write(summarystatscsv, speedstats)



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
trackstats.worm = categorical(map(i-> split(i, '_')[2], trackstats.id), levels = ["N2", "CB", "MT"])
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

# split buffer and LDOPA DFs by bactera in order to assign colors
bufferno = filter(:bacteria => b -> b == "NGM", buffertrackstats)
bufferyes = filter(:bacteria => b -> b == "BL21", buffertrackstats)
ldopano = filter(:bacteria => b -> b == "NGM", ldopatrackstats)
ldopayes = filter(:bacteria => b -> b == "BL21", ldopatrackstats)



# PLOTS

# MEAN ± SEM W JITTER DOT PLOT (DOT = TRACK MEAN) (ONLY TRACKS > 30s)

# define error bars at middle of each dodged bar
errorpos = [1.2, 0.8, 2.2, 1.8, 3.2, 2.8]

fig7 = Figure(
)

ax7a = Axis(
    fig7[1,1],
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

barplot!(ax7a, levelcode.(bufferspeedstats.worm), bufferspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax7a, bufferno.idlevel .+ rand(-0.1:0.01:0.1, length(bufferno.idlevel)), bufferno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax7a, bufferyes.idlevel .+ rand(-0.1:0.01:0.1, length(bufferyes.idlevel)), bufferyes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax7a, errorpos, bufferspeedstats.meanofmeanspeed, bufferspeedstats.semofmeanspeed, linewidth = 2)

ax7b = Axis(
    fig7[1,2],
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

barplot!(ax7b, levelcode.(ldopaspeedstats.worm), ldopaspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax7b, ldopano.idlevel .+ rand(-0.1:0.01:0.1, length(ldopano.idlevel)), ldopano.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax7b, ldopayes.idlevel .+ rand(-0.1:0.01:0.1, length(ldopayes.idlevel)), ldopayes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax7b, errorpos, ldopaspeedstats.meanofmeanspeed, ldopaspeedstats.semofmeanspeed, linewidth = 2)

linkyaxes!(ax7a, ax7b)

hideydecorations!(ax7b, grid = false)


elem_1 = [PolyElement(color = "#bbdaef")]
elem_2 = [PolyElement(color = "#efafcb")]

Legend(fig7[2, :],
    [elem_1, elem_2],
    ["No", "Yes"],
    "Bacteria Presence",
    orientation = :horizontal,
    titleposition = :left)

save(joinpath(experimentdir, "fig07.png"), fig7)



# FIG 7 with diff formatting

# define error bars at middle of each dodged bar
errorpos = [1.2, 0.8, 2.2, 1.8, 3.2, 2.8]

fig8 = Figure(
)

ax8a = Axis(
    fig8[1,1],
    title = "Buffer",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = (1:3, ["wild type", "cat-2 CB", "cat-2 MT"]),
    xlabelfont = "TeX Gyre Heros Makie Bold",
    ylabel = "Average speed (µm/sec)",
    ylabelfont = "TeX Gyre Heros Makie Bold",
    titlecolor = "#825ca5",
    topspinecolor = "#FFFFFF",
    bottomspinecolor = "#825ca5",
    rightspinecolor = "#FFFFFF",
)

ylims!(0, 500)
hidedecorations!(ax8a, label = false, ticklabels = false, ticks = false)

dodge = levelcode.(bufferspeedstats.bacteria)

barplot!(ax8a, levelcode.(bufferspeedstats.worm), bufferspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax8a, bufferno.idlevel .+ rand(-0.1:0.01:0.1, length(bufferno.idlevel)), bufferno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax8a, bufferyes.idlevel .+ rand(-0.1:0.01:0.1, length(bufferyes.idlevel)), bufferyes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax8a, errorpos, bufferspeedstats.meanofmeanspeed, bufferspeedstats.semofmeanspeed, linewidth = 2)

ax8b = Axis(
    fig8[1,2],
    title = "L-DOPA",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = (1:3, ["wild type", "cat-2 CB", "cat-2 MT"]),
    xlabelfont = "TeX Gyre Heros Makie Bold",
    ylabel = "Average speed (µm/sec)",
    ylabelfont = "TeX Gyre Heros Makie Bold",
    titlecolor = "#5aaa46",
    topspinecolor = "#FFFFFF",
    bottomspinecolor = "#5aaa46",
    leftspinecolor = "#FFFFFF",
    rightspinecolor = "#FFFFFF",
)

ylims!(0, 500)
hidedecorations!(ax8b, label = false, ticklabels = false, ticks = false)

dodge = levelcode.(ldopaspeedstats.bacteria)

barplot!(ax8b, levelcode.(ldopaspeedstats.worm), ldopaspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax8b, ldopano.idlevel .+ rand(-0.1:0.01:0.1, length(ldopano.idlevel)), ldopano.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax8b, ldopayes.idlevel .+ rand(-0.1:0.01:0.1, length(ldopayes.idlevel)), ldopayes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax8b, errorpos, ldopaspeedstats.meanofmeanspeed, ldopaspeedstats.semofmeanspeed, linewidth = 2)

hideydecorations!(ax8b, grid = false)


elem_1 = [PolyElement(color = "#bbdaef")]
elem_2 = [PolyElement(color = "#efafcb")]

Legend(fig8[2, :],
    [elem_1, elem_2],
    ["No", "Yes"],
    "Bacteria Presence",
    orientation = :horizontal,
    titleposition = :left)

save(joinpath(experimentdir, "fig08.png"), fig8)



# FIG 9 = FIG 8 simplified w only N2 and CB

# filter out MT
filter!(row -> (row.worm != "MT"),  bufferspeedstats)
filter!(row -> (row.worm != "MT"),  ldopaspeedstats)
filter!(row -> (row.worm != "MT"),  bufferno)
filter!(row -> (row.worm != "MT"),  bufferyes)
filter!(row -> (row.worm != "MT"),  ldopano)
filter!(row -> (row.worm != "MT"),  ldopayes)


# define error bars at middle of each dodged bar
errorpos = [1.2, 0.8, 2.2, 1.8]

fig9 = Figure(
)

ax9a = Axis(
    fig9[1,1],
    title = "Buffer",
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

dodge = levelcode.(bufferspeedstats.bacteria)

barplot!(ax9a, levelcode.(bufferspeedstats.worm), bufferspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))
errorbars!(ax9a, errorpos, bufferspeedstats.meanofmeanspeed, bufferspeedstats.semofmeanspeed, linewidth = 2)

scatter!(ax9a, bufferno.idlevel .+ rand(-0.1:0.01:0.1, length(bufferno.idlevel)), bufferno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax9a, bufferyes.idlevel .+ rand(-0.1:0.01:0.1, length(bufferyes.idlevel)), bufferyes.meanspeed, color = "#d679a2", markersize = 5)

ax9b = Axis(
    fig9[1,2],
    title = "L-DOPA",
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

dodge = levelcode.(ldopaspeedstats.bacteria)

barplot!(ax9b, levelcode.(ldopaspeedstats.worm), ldopaspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))
errorbars!(ax9b, errorpos, ldopaspeedstats.meanofmeanspeed, ldopaspeedstats.semofmeanspeed, linewidth = 2)

scatter!(ax9b, ldopano.idlevel .+ rand(-0.1:0.01:0.1, length(ldopano.idlevel)), ldopano.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax9b, ldopayes.idlevel .+ rand(-0.1:0.01:0.1, length(ldopayes.idlevel)), ldopayes.meanspeed, color = "#d679a2", markersize = 5)

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



# FIG 10 = FIG 8 simplified w only N2 and CB

# filter out CB
filter!(row -> (row.worm != "CB"),  bufferspeedstats)
filter!(row -> (row.worm != "CB"),  ldopaspeedstats)
filter!(row -> (row.worm != "CB"),  bufferno)
filter!(row -> (row.worm != "CB"),  bufferyes)
filter!(row -> (row.worm != "CB"),  ldopano)
filter!(row -> (row.worm != "CB"),  ldopayes)


# define error bars at middle of each dodged bar
errorpos = [1.4, 0.6, 3.4, 2.6]

fig10 = Figure(
)

ax10a = Axis(
    fig10[1,1],
    title = "Buffer",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = ([1,3], ["wild type", "cat-2 MT"]),
    xlabelfont = "TeX Gyre Heros Makie Bold",
    ylabel = "Average speed (µm/sec)",
    ylabelfont = "TeX Gyre Heros Makie Bold",
    titlecolor = "#825ca5",
    topspinecolor = "#FFFFFF",
    bottomspinecolor = "#825ca5",
    rightspinecolor = "#FFFFFF",
)

ylims!(0, 400)
hidedecorations!(ax10a, label = false, ticklabels = false, ticks = false)

dodge = levelcode.(bufferspeedstats.bacteria)

barplot!(ax10a, levelcode.(bufferspeedstats.worm), bufferspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))
errorbars!(ax10a, errorpos, bufferspeedstats.meanofmeanspeed, bufferspeedstats.semofmeanspeed, linewidth = 2)

scatter!(ax10a, bufferno.idlevel .- 0.2 .+ rand(-0.2:0.02:0.2, length(bufferno.idlevel)), bufferno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax10a, bufferyes.idlevel .+ 0.2 .+ rand(-0.2:0.02:0.2, length(bufferyes.idlevel)), bufferyes.meanspeed, color = "#d679a2", markersize = 5)

ax10b = Axis(
    fig10[1,2],
    title = "L-DOPA",
    titlesize = 20,
    xlabel = "Worm strain",
    xticks = ([1,3], ["wild type", "cat-2 MT"]),
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
hidedecorations!(ax10b, label = false, ticklabels = false, ticks = false)

dodge = levelcode.(ldopaspeedstats.bacteria)

barplot!(ax10b, levelcode.(ldopaspeedstats.worm), ldopaspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))
errorbars!(ax10b, errorpos, ldopaspeedstats.meanofmeanspeed, ldopaspeedstats.semofmeanspeed, linewidth = 2)

scatter!(ax10b, ldopano.idlevel .- 0.2 .+ rand(-0.2:0.02:0.2, length(ldopano.idlevel)), ldopano.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax10b, ldopayes.idlevel .+ 0.2 .+ rand(-0.2:0.02:0.2, length(ldopayes.idlevel)), ldopayes.meanspeed, color = "#d679a2", markersize = 5)

hideydecorations!(ax10b, grid = false)


elem_1 = [PolyElement(color = "#bbdaef")]
elem_2 = [PolyElement(color = "#efafcb")]

Legend(fig10[2, :],
    [elem_1, elem_2],
    ["No", "Yes"],
    "Bacteria Presence",
    orientation = :horizontal,
    titleposition = :left)

save(joinpath(experimentdir, "fig10.png"), fig10)



# FIG 11 = FIG 9 w larger text

# filter out MT
filter!(row -> (row.worm != "MT"),  bufferspeedstats)
filter!(row -> (row.worm != "MT"),  ldopaspeedstats)
filter!(row -> (row.worm != "MT"),  bufferno)
filter!(row -> (row.worm != "MT"),  bufferyes)
filter!(row -> (row.worm != "MT"),  ldopano)
filter!(row -> (row.worm != "MT"),  ldopayes)


# define error bars at middle of each dodged bar
errorpos = [1.2, 0.8, 2.2, 1.8]

fontsize_theme = Theme(fontsize = 25)
set_theme!(fontsize_theme)

fig11 = Figure(
)

ax11a = Axis(
    fig11[1,1],
    title = "Buffer",
    titlesize = 35,
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
hidedecorations!(ax11a, label = false, ticklabels = false, ticks = false)

dodge = levelcode.(bufferspeedstats.bacteria)

barplot!(ax11a, levelcode.(bufferspeedstats.worm), bufferspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax11a, bufferno.idlevel .+ rand(-0.1:0.01:0.1, length(bufferno.idlevel)), bufferno.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax11a, bufferyes.idlevel .+ rand(-0.1:0.01:0.1, length(bufferyes.idlevel)), bufferyes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax11a, errorpos, bufferspeedstats.meanofmeanspeed, bufferspeedstats.semofmeanspeed, linewidth = 2)

ax11b = Axis(
    fig11[1,2],
    title = "L-DOPA",
    titlesize = 35,
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
hidedecorations!(ax11b, label = false, ticklabels = false, ticks = false)

dodge = levelcode.(ldopaspeedstats.bacteria)

barplot!(ax11b, levelcode.(ldopaspeedstats.worm), ldopaspeedstats.meanofmeanspeed, dodge = dodge, color = map(d->d==1 ? "#bbdaef" : "#efafcb", dodge))

scatter!(ax11b, ldopano.idlevel .+ rand(-0.1:0.01:0.1, length(ldopano.idlevel)), ldopano.meanspeed, color = "#7ca4d7", markersize = 5)
scatter!(ax11b, ldopayes.idlevel .+ rand(-0.1:0.01:0.1, length(ldopayes.idlevel)), ldopayes.meanspeed, color = "#d679a2", markersize = 5)

errorbars!(ax11b, errorpos, ldopaspeedstats.meanofmeanspeed, ldopaspeedstats.semofmeanspeed, linewidth = 2)

hideydecorations!(ax11b, grid = false)


elem_1 = [PolyElement(color = "#bbdaef")]
elem_2 = [PolyElement(color = "#efafcb")]

Legend(fig11[2, :],
    [elem_1, elem_2],
    ["No", "Yes"],
    "Bacteria Presence",
    orientation = :horizontal,
    titleposition = :left)

save(joinpath(experimentdir, "fig11.png"), fig11)

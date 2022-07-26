# VARIANCE IN SPEED PLOTS
# Plots of wild type and mutant on bacterial lawn (Omura)

using DataFrames
using CSV
using CategoricalArrays
using GLMakie
using Statistics
using StatsBase



# LOAD SPEEDS CSV INTO DATAFRAME
experimentdir = @__DIR__

speeds = DataFrame(CSV.File(joinpath(experimentdir, "speeds.csv")))

# CALCULATE SUMMARY STATS BY FIRST CALCULATING SUMMARY STATS OF EACH TRACK
# individual track stats
tracks = groupby(speeds, [:experiment, :id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed, :speed => std => :stdspeed)

# MAKE CATEGORICAL ARRAYS FOR PLOTTING
trackstats.medium = categorical(map(i-> split(i, '_')[1], trackstats.id), levels = ["M9", "DA"])
trackstats.worm = categorical(map(i-> split(i, '_')[2], trackstats.id), levels = ["N2", "CB", "MT"])
trackstats.bacteria = categorical(map(i-> split(i, '_')[3], trackstats.id), levels = ["NGM", "OP50"])

# only keep data on bacterial lawn
filter!(:bacteria => x -> x == "OP50", trackstats)

# separate all conditions into new DFs
buffer = filter(:medium => x -> x == "M9", trackstats)
bufferN2 = filter(:worm => x -> x == "N2", buffer)
bufferCB = filter(:worm => x -> x == "CB", buffer)
bufferMT = filter(:worm => x -> x == "MT", buffer)

dopamine = filter(:medium => x -> x == "DA", trackstats)
dopamineN2 = filter(:worm => x -> x == "N2", dopamine)
dopamineCB = filter(:worm => x -> x == "CB", dopamine)
dopamineMT = filter(:worm => x -> x == "MT", dopamine)



# PLOT

fig1 = Figure(
)

ax1a = Axis(
    fig1[1,1],
    title = "Buffer",
    xlabel = "Mean speed (µm/sec)",
    ylabel = "Std speed",
)

N2 = scatter!(ax1a, bufferN2.meanspeed, bufferN2.stdspeed, color = :pink)
CB = scatter!(ax1a, bufferCB.meanspeed, bufferCB.stdspeed, color = :lightgreen)
MT = scatter!(ax1a, bufferMT.meanspeed, bufferMT.stdspeed, color = :lightblue)

ax1b = Axis(
    fig1[1,2],
    title = "Dopamine",
    xlabel = "Mean speed (µm/sec)",
    ylabel = "Std speed",
)

scatter!(ax1b, dopamineN2.meanspeed, dopamineN2.stdspeed, color = :pink)
scatter!(ax1b, dopamineCB.meanspeed, dopamineCB.stdspeed, color = :lightgreen)
scatter!(ax1b, dopamineMT.meanspeed, dopamineMT.stdspeed, color = :lightblue)

linkyaxes!(ax1a, ax1b)
hideydecorations!(ax1b, grid = false)
linkxaxes!(ax1a, ax1b)

Legend(fig1[2, :],
    [N2, CB, MT],
    ["wild type", "cat-2 #1", "cat-2 #2"],
    "Worm strain",
    orientation = :horizontal,
    titleposition = :left)

save(joinpath(experimentdir, "fig101.png"), fig1)

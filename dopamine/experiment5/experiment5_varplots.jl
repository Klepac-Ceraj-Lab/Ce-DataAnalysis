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

# CALCULATE MEAN AND STD SPEED OF EACH TRACK
tracks = groupby(speeds, [:experiment, :id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed, :speed => std => :stdspeed)

# FILTER TRACKS WITH NAN VALUES FOR STD
filter!(:stdspeed => x -> !(isnan(x)), trackstats)

# BIN TRACKS ACCORDING TO MEAN SPEED
bin = Vector{Int}()

for row in 1:nrow(trackstats)
    max = (maximum(trackstats.meanspeed) + 50)
    binnum = count(trackstats.meanspeed[row] .> 0:50:max)
    push!(bin, binnum)
end

trackstats.bin = bin

# MAKE CATEGORICAL ARRAYS FOR PLOTTING
trackstats.medium = categorical(map(i-> split(i, '_')[1], trackstats.id); levels = ["M9", "DA"])
trackstats.worm = categorical(map(i-> split(i, '_')[2], trackstats.id); levels = ["N2", "CB", "MT"])
trackstats.bacteria = categorical(map(i-> split(i, '_')[3], trackstats.id); levels = ["NGM", "OP50"])

# ONLY KEEP DATA ON BACTERIAL LAWN
filter!(:bacteria => x -> x == "OP50", trackstats)

# SEPARATE ALL CONDITIONS INTO NEW DFs
buffer = filter(:medium => x -> x == "M9", trackstats)
bufferN2 = filter(:worm => x -> x == "N2", buffer)
bufferCB = filter(:worm => x -> x == "CB", buffer)
bufferMT = filter(:worm => x -> x == "MT", buffer)

dopamine = filter(:medium => x -> x == "DA", trackstats)
dopamineN2 = filter(:worm => x -> x == "N2", dopamine)
dopamineCB = filter(:worm => x -> x == "CB", dopamine)
dopamineMT = filter(:worm => x -> x == "MT", dopamine)

# GET MEAN AND STD OF MEAN SPEED AND SEM OF EACH BIN OF EACH CONDITION
# x = mean of mean speed
# y = mean of std speed
# error = sem of std speed
bufferN2binned = combine(groupby(bufferN2, [:bin]), 
            :meanspeed => mean => :meanofmeanspeed,
            :stdspeed  => mean => :meanofstdspeed,
            :stdspeed  => sem  => :semofstdspeed,
            :track => length => :n)
bufferCBbinned = combine(groupby(bufferCB, [:bin]), :meanspeed => mean => :meanofmeanspeed, :stdspeed => mean => :meanofstdspeed, :stdspeed => sem => :semofstdspeed, :track => length => :n)
bufferMTbinned = combine(groupby(bufferMT, [:bin]), :meanspeed => mean => :meanofmeanspeed, :stdspeed => mean => :meanofstdspeed, :stdspeed => sem => :semofstdspeed, :track => length => :n)
dopamineN2binned = combine(groupby(dopamineN2, [:bin]), :meanspeed => mean => :meanofmeanspeed, :stdspeed => mean => :meanofstdspeed, :stdspeed => sem => :semofstdspeed, :track => length => :n)
dopamineCBbinned = combine(groupby(dopamineCB, [:bin]), :meanspeed => mean => :meanofmeanspeed, :stdspeed => mean => :meanofstdspeed, :stdspeed => sem => :semofstdspeed, :track => length => :n)
dopamineMTbinned = combine(groupby(dopamineMT, [:bin]), :meanspeed => mean => :meanofmeanspeed, :stdspeed => mean => :meanofstdspeed, :stdspeed => sem => :semofstdspeed, :track => length => :n)



# PLOT

# scatter of individual mean speeds
fig1 = Figure(
)

ax1a = Axis(
    fig1[1,1],
    title = "Buffer",
    xlabel = "Mean speed (µm/s)",
    ylabel = "Std speed (µm/s)",
)

N2 = scatter!(ax1a, bufferN2.meanspeed, bufferN2.stdspeed, color = :pink)
CB = scatter!(ax1a, bufferCB.meanspeed, bufferCB.stdspeed, color = :lightgreen)
MT = scatter!(ax1a, bufferMT.meanspeed, bufferMT.stdspeed, color = :lightblue)

ax1b = Axis(
    fig1[1,2],
    title = "Dopamine",
    xlabel = "Mean speed (µm/s)",
    ylabel = "Std speed (µm/s)",
)

scatter!(ax1b, dopamineN2.meanspeed, dopamineN2.stdspeed, color = :pink)
scatter!(ax1b, dopamineCB.meanspeed, dopamineCB.stdspeed, color = :lightgreen)
scatter!(ax1b, dopamineMT.meanspeed, dopamineMT.stdspeed, color = :lightblue)

linkyaxes!(ax1a, ax1b)
hideydecorations!(ax1b, grid = false)
linkxaxes!(ax1a, ax1b)

Legend(fig1[2, :],
    [N2, CB, MT],
    ["wild type", "cat-2 CB", "cat-2 MT"],
    "Worm strain",
    orientation = :horizontal,
    titleposition = :left)

# save(joinpath(experimentdir, "fig101.png"), fig1)



# scatter and line of binned mean speeds
fig2 = Figure(
)

ax2a = Axis(
    fig2[1,1],
    title = "Buffer",
    xlabel = "Mean speed (µm/s)",
    ylabel = "Std speed (µm/s)",
)

N2 = scatter!(ax2a, bufferN2binned.meanofmeanspeed, bufferN2binned.meanofstdspeed, color = :pink)
CB = scatter!(ax2a, bufferCBbinned.meanofmeanspeed, bufferCBbinned.meanofstdspeed, color = :lightgreen)
MT = scatter!(ax2a, bufferMTbinned.meanofmeanspeed, bufferMTbinned.meanofstdspeed, color = :lightblue)

lines!(ax2a, bufferN2binned.meanofmeanspeed, bufferN2binned.meanofstdspeed, color = :pink)
lines!(ax2a, bufferCBbinned.meanofmeanspeed, bufferCBbinned.meanofstdspeed, color = :lightgreen)
lines!(ax2a, bufferMTbinned.meanofmeanspeed, bufferMTbinned.meanofstdspeed, color = :lightblue)

errorbars!(ax2a, bufferN2binned.meanofmeanspeed, bufferN2binned.meanofstdspeed, bufferN2binned.semofstdspeed, color = :pink)
errorbars!(ax2a, bufferCBbinned.meanofmeanspeed, bufferCBbinned.meanofstdspeed, bufferCBbinned.semofstdspeed, color = :lightgreen)
errorbars!(ax2a, bufferMTbinned.meanofmeanspeed, bufferMTbinned.meanofstdspeed, bufferMTbinned.semofstdspeed, color = :lightblue)

ax2b = Axis(
    fig2[1,2],
    title = "Dopamine",
    xlabel = "Mean speed (µm/s)",
    ylabel = "Std speed (µm/s)",
)

scatter!(ax2b, dopamineN2binned.meanofmeanspeed, dopamineN2binned.meanofstdspeed, color = :pink)
scatter!(ax2b, dopamineCBbinned.meanofmeanspeed, dopamineCBbinned.meanofstdspeed, color = :lightgreen)
scatter!(ax2b, dopamineMTbinned.meanofmeanspeed, dopamineMTbinned.meanofstdspeed, color = :lightblue)

lines!(ax2b, dopamineN2binned.meanofmeanspeed, dopamineN2binned.meanofstdspeed, color = :pink)
lines!(ax2b, dopamineCBbinned.meanofmeanspeed, dopamineCBbinned.meanofstdspeed, color = :lightgreen)
lines!(ax2b, dopamineMTbinned.meanofmeanspeed, dopamineMTbinned.meanofstdspeed, color = :lightblue)

errorbars!(ax2b, dopamineN2binned.meanofmeanspeed, dopamineN2binned.meanofstdspeed, dopamineN2binned.semofstdspeed, color = :pink)
errorbars!(ax2b, dopamineCBbinned.meanofmeanspeed, dopamineCBbinned.meanofstdspeed, dopamineCBbinned.semofstdspeed, color = :lightgreen)
errorbars!(ax2b, dopamineMTbinned.meanofmeanspeed, dopamineMTbinned.meanofstdspeed, dopamineMTbinned.semofstdspeed, color = :lightblue)

linkyaxes!(ax2a, ax2b)
hideydecorations!(ax2b, grid = false)
linkxaxes!(ax2a, ax2b)

Legend(fig2[2, :],
    [N2, CB, MT],
    ["wild type", "cat-2 CB", "cat-2 MT"],
    "Worm strain",
    orientation = :horizontal,
    titleposition = :left)

# save(joinpath(experimentdir, "fig102.png"), fig2)
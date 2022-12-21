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



# filter on DA_N2_OP50 of experiment 1
DA_N2_OP50 = subset(speeds, :id=>ByRow(==("DA_N2_OP50")), :experiment=>ByRow(==(1)))

# plot speed vs. track #
fig201 = Figure(
)

ax201 = Axis(
    fig201[1,1],
    title = "DA_N2_OP50",
    xlabel = "Track #",
    ylabel = "Speed (µm/sec)",
)

scatter!(ax201, DA_N2_OP50.track, DA_N2_OP50.speed)

save(joinpath(experimentdir, "fig201.png"), fig201)



# filter on DA_N2_NGM of experiment 1
DA_N2_NGM = subset(speeds, :id=>ByRow(==("DA_N2_NGM")), :experiment=>ByRow(==(1)))

# plot speed vs. track #
fig202 = Figure(
)

ax202 = Axis(
    fig202[1,1],
    title = "DA_N2_NGM",
    xlabel = "Track #",
    ylabel = "Speed (µm/sec)",
)

scatter!(ax202, DA_N2_NGM.track, DA_N2_NGM.speed)

save(joinpath(experimentdir, "fig202.png"), fig202)

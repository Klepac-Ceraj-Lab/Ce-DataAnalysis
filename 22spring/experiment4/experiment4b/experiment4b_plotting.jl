using DataFrames
using CSV
using CategoricalArrays
using GLMakie



# LOAD SPEEDS CSV INTO DATAFRAME
experimentdir = "./22spring/experiment4/experiment4b/"
speedscsv = joinpath(experimentdir, "speeds.csv")
speeds = DataFrame(CSV.File(speedscsv))



# MAKE CATEGORICAL ARRAYS FOR PLOTTING
speeds.medium = categorical(map(i-> split(i, '_')[1], speeds.id), levels = ["M9", "DA"])
speeds.worm = categorical(map(i-> split(i, '_')[2], speeds.id), levels = ["N2", "CB", "MT"])
speeds.bacteria = categorical(map(i-> split(i, '_')[3], speeds.id), levels = ["NGM", "OP50"])

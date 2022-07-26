using DataFrames
using CSV
using Statistics
using CategoricalArrays
using GLM



# LOAD SPEEDS CSV INTO DATAFRAME
experimentdir = @__DIR__

speeds = DataFrame(CSV.File(joinpath(experimentdir, "speeds.csv")))

# CALCULATE SUMMARY STATS BY FIRST CALCULATING SUMMARY STATS OF EACH TRACK
# individual track stats
tracks = groupby(speeds, [:experiment, :id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed)

# MAKE CATEGORICAL ARRAYS
trackstats.medium = categorical(map(i-> split(i, '_')[1], trackstats.id), levels = ["M9", "DA"])
trackstats.worm = categorical(map(i-> split(i, '_')[2], trackstats.id), levels = ["N2", "CB", "MT"])
trackstats.bacteria = categorical(map(i-> split(i, '_')[3], trackstats.id), levels = ["NGM", "OP50"])



# MODELING
id = lm(@formula(meanspeed ~ id), trackstats)

m = lm(@formula(meanspeed ~ medium), trackstats)
w = lm(@formula(meanspeed ~ worm), trackstats)
b = lm(@formula(meanspeed ~ bacteria), trackstats)

mw = lm(@formula(meanspeed ~ medium + worm), trackstats)
wb = lm(@formula(meanspeed ~ worm + bacteria), trackstats)
mb = lm(@formula(meanspeed ~ medium + bacteria), trackstats)

mwb = lm(@formula(meanspeed ~ medium + worm + bacteria), trackstats)


ftest(mw.model, mwb.model)

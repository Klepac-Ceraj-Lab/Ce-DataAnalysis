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
tracks = groupby(speeds, [:id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed, :track => length => :n) # add legnth of each track (# data points)

# filter on tracks w > 6pts ie. more than 30s
filter!(row -> row.n > 6, trackstats)



# MAKE CATEGORICAL ARRAYS
trackstats.medium = categorical(map(i-> split(i, '_')[1], trackstats.id), levels = ["H2O", "IPTG"])
trackstats.worm = categorical(map(i-> split(i, '_')[2], trackstats.id), levels = ["N2", "CB"])
trackstats.bacteria = categorical(map(i-> split(i, '_')[3], trackstats.id), levels = ["NGM", "BL21"])



# MODELS / ANOVAS

# three way interaction between all variables without subsetting
threeway = lm(@formula(meanspeed ~ medium*bacteria*worm), trackstats)
# meanspeed ~ 1 + medium + bacteria + worm + medium & bacteria + medium & worm + bacteria & worm + medium & bacteria & worm

# Coefficients:
# ────────────────────────────────────────────────────────────────────────────────────────────────────────
#                                                Coef.  Std. Error      t  Pr(>|t|)   Lower 95%  Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                                259.351       14.7686  17.56    <1e-24   229.819     288.882
# medium: IPTG                                -8.35919     20.8859  -0.40    0.6904   -50.1231     33.4047
# bacteria: BL21                            -147.405       19.6914  -7.49    <1e-09  -186.781    -108.03
# worm: CB                                     1.43498     18.892    0.08    0.9397   -36.3419     39.2119
# medium: IPTG & bacteria: BL21               13.3508      27.5416   0.48    0.6296   -41.722      68.4236
# medium: IPTG & worm: CB                    -17.0771      26.9758  -0.63    0.5291   -71.0186     36.8644
# bacteria: BL21 & worm: CB                   49.3068      27.2885   1.81    0.0757    -5.25988   103.873
# medium: IPTG & bacteria: BL21 & worm: CB    24.9544      38.1965   0.65    0.5160   -51.4242    101.333
# ────────────────────────────────────────────────────────────────────────────────────────────────────────

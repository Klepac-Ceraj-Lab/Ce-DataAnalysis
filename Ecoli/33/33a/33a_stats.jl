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
#                                               Coef.  Std. Error       t  Pr(>|t|)  Lower 95%   Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                                291.766      12.1079   24.10    <1e-34   267.606    315.927
# medium: IPTG                               -22.6327     16.3262   -1.39    0.1702   -55.2112     9.94577
# bacteria: BL21                            -179.273      16.6895  -10.74    <1e-15  -212.576   -145.969
# worm: CB                                   -81.7491     17.6501   -4.63    <1e-04  -116.969    -46.5289
# medium: IPTG & bacteria: BL21               27.7402     22.5485    1.23    0.2228   -17.2547    72.7351
# medium: IPTG & worm: CB                     89.5209     23.7363    3.77    0.0003    42.1559   136.886
# bacteria: BL21 & worm: CB                  132.589      25.1386    5.27    <1e-05    82.4256   182.752
# medium: IPTG & bacteria: BL21 & worm: CB   -91.6285     33.7696   -2.71    0.0084  -159.015    -24.2422
# ────────────────────────────────────────────────────────────────────────────────────────────────────────

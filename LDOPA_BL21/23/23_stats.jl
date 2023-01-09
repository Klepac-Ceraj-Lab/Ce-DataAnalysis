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
trackstats = combine(tracks, :speed => mean => :meanspeed, :track => length => :n) # add legnth of each track (# data points)

# filter on tracks w > 6pts ie. more than 30s
filter!(row -> row.n > 6, trackstats)


# MAKE CATEGORICAL ARRAYS
trackstats.medium = categorical(map(i-> split(i, '_')[1], trackstats.id), levels = ["M9", "LD"])
trackstats.worm = categorical(map(i-> split(i, '_')[2], trackstats.id), levels = ["N2", "CB", "MT"])
trackstats.bacteria = categorical(map(i-> split(i, '_')[3], trackstats.id), levels = ["NGM", "BL21"])



# MODELS / ANOVAS

# comparing across strains for buffer medium
lm(@formula(meanspeed ~ worm*bacteria), subset(trackstats, :medium=>ByRow(==("M9"))))
# meanspeed ~ 1 + worm + bacteria + worm & bacteria

# Coefficients:
# ───────────────────────────────────────────────────────────────────────────────────────
#                                Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ───────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                 289.403      10.662   27.14    <1e-59   268.34     310.467
# worm: CB                    -59.3747     14.3302  -4.14    <1e-04   -87.6853   -31.064
# worm: MT                    -61.8596     14.7965  -4.18    <1e-04   -91.0915   -32.6277
# bacteria: BL21             -138.103      14.7965  -9.33    <1e-15  -167.335   -108.871
# worm: CB & bacteria: BL21   106.918      20.492    5.22    <1e-06    66.4346   147.402
# worm: MT & bacteria: BL21   100.288      21.1603   4.74    <1e-05    58.4834   142.092
# ───────────────────────────────────────────────────────────────────────────────────────

# CB on and off bacteria vs N2 on and off bacteria
# ie. speed diff of CB vs speed diff of N2
# p = <1e-06 --> significant difference, as expected

# MT on and off bacteria vs N2 on and off bacteria
# ie. speed diff of MT vs speed diff of N2
# p = <1e-05 --> significant difference, as expected



# comparing across strains for dopamine medium
lm(@formula(meanspeed ~ worm*bacteria), subset(trackstats, :medium=>ByRow(==("LD"))))
# meanspeed ~ 1 + worm + bacteria + worm & bacteria

# Coefficients:
# ────────────────────────────────────────────────────────────────────────────────────────
#                                Coef.  Std. Error      t  Pr(>|t|)   Lower 95%  Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                242.422       9.62313  25.19    <1e-57   223.42      261.424
# worm: CB                   -10.219      13.7346   -0.74    0.4579   -37.3397     16.9016
# worm: MT                   -66.2015     13.6092   -4.86    <1e-05   -93.0745    -39.3286
# bacteria: BL21             -81.5703     13.3804   -6.10    <1e-08  -107.992     -55.149
# worm: CB & bacteria: BL21   -6.33004    19.1748   -0.33    0.7417   -44.1931     31.5331
# worm: MT & bacteria: BL21   29.618      19.0852    1.55    0.1226    -8.06808    67.3041
# ────────────────────────────────────────────────────────────────────────────────────────

# CB on and off bacteria vs N2 on and off bacteria
# ie. speed diff of CB vs speed diff of N2
# p = 0.7417 --> not significant, as expected

# MT on and off bacteria vs N2 on and off bacteria
# ie. speed diff of MT vs speed diff of N2
# p = 0.1226 --> not significant, as expected



# comparing across mediums for N2 strain
lm(@formula(meanspeed ~ medium*bacteria), subset(trackstats, :worm=>ByRow(==("N2"))))
# meanspeed ~ 1 + medium + bacteria + medium & bacteria

# Coefficients:
# ─────────────────────────────────────────────────────────────────────────────────────────
#                                  Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ─────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                   289.403      10.35    27.96    <1e-50   268.884    309.923
# medium: LD                    -46.9815     14.2396  -3.30    0.0013   -75.2129   -18.7501
# bacteria: BL21               -138.103      14.3635  -9.61    <1e-15  -166.58    -109.626
# medium: LD & bacteria: BL21    56.5327     19.7793   2.86    0.0051    17.3182    95.7471
# ─────────────────────────────────────────────────────────────────────────────────────────

# N2 on and off bacteria on buffer vs. dopamine
# ie. speed diff of N2 w buffer vs. w dopamine
# p = 0.0051 --> SIGNIFICANT, NOT AS EXPECTED



# comparing across mediums for CB strain
lm(@formula(meanspeed ~ medium*bacteria), subset(trackstats, :worm=>ByRow(==("CB"))))
# meanspeed ~ 1 + medium + bacteria + medium & bacteria

# Coefficients:
# ─────────────────────────────────────────────────────────────────────────────────────────
#                                  Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ─────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                  230.029       9.22092  24.95    <1e-45   211.751   248.306
# medium: LD                     2.17414    13.5147    0.16    0.8725   -24.6143   28.9626
# bacteria: BL21               -31.1846     13.6529   -2.28    0.0243   -58.247    -4.12215
# medium: LD & bacteria: BL21  -56.7158     19.4463   -2.92    0.0043   -95.2617  -18.1698
# ─────────────────────────────────────────────────────────────────────────────────────────

# CB on and off bacteria on buffer vs. dopamine
# ie. speed diff of CB w buffer vs. w dopamine
# p = 0.0043 --> significant, as expected



# comparing across mediums for MT strain
lm(@formula(meanspeed ~ medium*bacteria), subset(trackstats, :worm=>ByRow(==("MT"))))
# meanspeed ~ 1 + medium + bacteria + medium & bacteria

# Coefficients:
# ────────────────────────────────────────────────────────────────────────────────────────
#                                 Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                  227.544      10.2427  22.22    <1e-40   207.227   247.86
# medium: LD                   -51.3234     14.3555  -3.58    0.0005   -79.7974  -22.8494
# bacteria: BL21               -37.8154     15.1021  -2.50    0.0139   -67.7703   -7.86052
# medium: LD & bacteria: BL21  -14.1369     20.7462  -0.68    0.4972   -55.2869   27.0132
# ────────────────────────────────────────────────────────────────────────────────────────

# MT on and off bacteria on buffer vs. dopamine
# ie. speed diff of MT w buffer vs. w dopamine
# p = 0.4972 --> NOT SIGNIFICANT, NOT AS EXPECTED



# save CSVs for each subset
CSV.write(joinpath(experimentdir, "alltracks_data.csv"), trackstats)
CSV.write(joinpath(experimentdir, "M9_data.csv"), select(subset(trackstats, :medium=>ByRow(==("M9"))), "meanspeed", "worm", "bacteria"))
CSV.write(joinpath(experimentdir, "LD_data.csv"), select(subset(trackstats, :medium=>ByRow(==("LD"))), "meanspeed", "worm", "bacteria"))
CSV.write(joinpath(experimentdir, "N2_data.csv"), select(subset(trackstats, :worm=>ByRow(==("N2"))), "meanspeed", "medium", "bacteria"))
CSV.write(joinpath(experimentdir, "CB_data.csv"), select(subset(trackstats, :worm=>ByRow(==("CB"))), "meanspeed", "medium", "bacteria"))
CSV.write(joinpath(experimentdir, "MT_data.csv"), select(subset(trackstats, :worm=>ByRow(==("MT"))), "meanspeed", "medium", "bacteria"))

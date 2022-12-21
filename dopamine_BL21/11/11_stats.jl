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
trackstats.medium = categorical(map(i-> split(i, '_')[1], trackstats.id), levels = ["M9", "DA"])
trackstats.worm = categorical(map(i-> split(i, '_')[2], trackstats.id), levels = ["N2", "CB", "MT"])
trackstats.bacteria = categorical(map(i-> split(i, '_')[3], trackstats.id), levels = ["NGM", "BL21"])



# MODELS / ANOVAS

# comparing across strains for buffer medium
lm(@formula(meanspeed ~ worm*bacteria), subset(trackstats, :medium=>ByRow(==("M9"))))
# meanspeed ~ 1 + worm + bacteria + worm & bacteria

# Coefficients:
# ────────────────────────────────────────────────────────────────────────────────────────
#                                Coef.  Std. Error       t  Pr(>|t|)  Lower 95%  Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                 292.938      12.4953   23.44    <1e-46   268.206    317.669
# worm: CB                    -45.5792     15.6637   -2.91    0.0043   -76.582    -14.5764
# worm: MT                    -69.0725     16.422    -4.21    <1e-04  -101.576    -36.5687
# bacteria: BL21             -171.053      15.8812  -10.77    <1e-18  -202.487   -139.62
# worm: CB & bacteria: BL21   149.003      22.0993    6.74    <1e-09   105.262    192.744
# worm: MT & bacteria: BL21   123.34       22.0164    5.60    <1e-06    79.7631   166.916
# ────────────────────────────────────────────────────────────────────────────────────────

# CB on and off bacteria vs N2 on and off bacteria
# ie. speed diff of CB vs speed diff of N2
# p = <1e-09 --> significant difference, as expected

# MT on and off bacteria vs N2 on and off bacteria
# ie. speed diff of MT vs speed diff of N2
# p = <1e-06 --> significant difference, as expected



# comparing across strains for dopamine medium
lm(@formula(meanspeed ~ worm*bacteria), subset(trackstats, :medium=>ByRow(==("DA"))))
# meanspeed ~ 1 + worm + bacteria + worm & bacteria

# Coefficients:
# ───────────────────────────────────────────────────────────────────────────────────────────
#                                 Coef.  Std. Error       t  Pr(>|t|)   Lower 95%   Upper 95%
# ───────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                 236.311       8.82898   26.77    <1e-57   218.862    253.76
# worm: CB                      7.86592    11.9762     0.66    0.5123   -15.8032    31.5351
# worm: MT                    -25.0427     12.2116    -2.05    0.0421   -49.177     -0.908308
# bacteria: BL21             -118.027      11.3625   -10.39    <1e-18  -140.483    -95.5704
# worm: CB & bacteria: BL21    -3.19201    16.1265    -0.20    0.8434   -35.0635    28.6795
# worm: MT & bacteria: BL21    33.5566     16.2246     2.07    0.0404     1.49108   65.6221
# ───────────────────────────────────────────────────────────────────────────────────────────

# CB on and off bacteria vs N2 on and off bacteria
# ie. speed diff of CB vs speed diff of N2
# p = 0.8434 --> not significant, as expected

# MT on and off bacteria vs N2 on and off bacteria
# ie. speed diff of MT vs speed diff of N2
# p = 0.0404 --> BARELY SIGNIFICANT, KINDA EXPECTED?



# comparing across mediums for N2 strain
lm(@formula(meanspeed ~ medium*bacteria), subset(trackstats, :worm=>ByRow(==("N2"))))
# meanspeed ~ 1 + medium + bacteria + medium & bacteria

# Coefficients:
# ──────────────────────────────────────────────────────────────────────────────────────────
#                                  Coef.  Std. Error       t  Pr(>|t|)  Lower 95%  Upper 95%
# ──────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                   292.938      10.4741   27.97    <1e-45    272.132   313.743
# medium: DA                    -56.6264     13.903    -4.07    <1e-04    -84.243   -29.0097
# bacteria: BL21               -171.053      13.3124  -12.85    <1e-21   -197.497  -144.61
# medium: DA & bacteria: BL21    53.0266     17.7668    2.98    0.0036     17.735    88.3182
# ──────────────────────────────────────────────────────────────────────────────────────────

# dopamine vs. buffer, bacteria vs. no bacteria
# ie. speed diff of N2 w buffer vs. w dopamine
# p = 0.0036 --> SIGNIFICANT, NOT AS EXPECTED



# comparing across mediums for CB strain
lm(@formula(meanspeed ~ medium*bacteria), subset(trackstats, :worm=>ByRow(==("CB"))))
# meanspeed ~ 1 + medium + bacteria + medium & bacteria

# Coefficients:
# ─────────────────────────────────────────────────────────────────────────────────────────
#                                  Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ─────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                  247.358       7.30811  33.85    <1e-52   232.842   261.875
# medium: DA                    -3.18123    10.6408   -0.30    0.7656   -24.3178   17.9554
# bacteria: BL21               -22.0502     11.8901   -1.85    0.0669   -45.6685    1.56806
# medium: DA & bacteria: BL21  -99.1684     16.1558   -6.14    <1e-07  -131.26    -67.0768
# ─────────────────────────────────────────────────────────────────────────────────────────

# dopamine vs. buffer, bacteria vs. no bacteria
# ie. speed diff of CB w buffer vs. w dopamine
# p = <1e-07 --> significant, as expected



# comparing across mediums for MT strain
lm(@formula(meanspeed ~ medium*bacteria), subset(trackstats, :worm=>ByRow(==("MT"))))
# meanspeed ~ 1 + medium + bacteria + medium & bacteria

# Coefficients:
# ────────────────────────────────────────────────────────────────────────────────────────
#                                 Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                  223.865      11.4304  19.59    <1e-33   201.15    246.581
# medium: DA                   -12.5965     15.9883  -0.79    0.4329   -44.37     19.1769
# bacteria: BL21               -47.7135     16.3563  -2.92    0.0045   -80.2182  -15.2088
# medium: DA & bacteria: BL21  -36.7565     22.4289  -1.64    0.1048   -81.3293    7.81618
# ────────────────────────────────────────────────────────────────────────────────────────

# dopamine vs. buffer, bacteria vs. no bacteria
# ie. speed diff of MT w buffer vs. w dopamine
# p = 0.1048 --> NOT SIGNIFICANT, NOT AS EXPECTED

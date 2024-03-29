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



# MODELS / ANOVAS

# comparing across strains for buffer medium
lm(@formula(meanspeed ~ worm*bacteria), subset(trackstats, :medium=>ByRow(==("M9"))))
# meanspeed ~ 1 + worm + bacteria + worm & bacteria

# Coefficients:
# ───────────────────────────────────────────────────────────────────────────────────────
#                                Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ───────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                 269.204      10.41    25.86    <1e-78   248.721    289.688
# worm: CB                    -64.1178     15.0256  -4.27    <1e-04   -93.6832   -34.5525
# worm: MT                    -45.1968     14.2228  -3.18    0.0016   -73.1826   -17.211
# bacteria: OP50             -100.851      13.4165  -7.52    <1e-12  -127.25     -74.4519
# worm: CB & bacteria: OP50    70.0027     18.8285   3.72    0.0002    32.9544   107.051
# worm: MT & bacteria: OP50    68.086      18.4956   3.68    0.0003    31.6927   104.479
# ───────────────────────────────────────────────────────────────────────────────────────

# CB on and off bacteria vs N2 on and off bacteria
# ie. speed diff of CB vs speed diff of N2
# p = 0.0002 --> significant difference, as expected

# MT on and off bacteria vs N2 on and off bacteria
# ie. speed diff of MT vs speed diff of N2
# p = 0.0003 --> significant difference, as expected



# comparing across strains for dopamine medium
lm(@formula(meanspeed ~ worm*bacteria), subset(trackstats, :medium=>ByRow(==("DA"))))
# meanspeed ~ 1 + worm + bacteria + worm & bacteria

# Coefficients:
# ───────────────────────────────────────────────────────────────────────────────────────
#                                Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ───────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                 252.881      10.0241  25.23    <1e-75   233.156   272.607
# worm: CB                    -32.7666     13.4317  -2.44    0.0153   -59.1975   -6.33565
# worm: MT                    -30.643      13.8936  -2.21    0.0282   -57.9827   -3.30322
# bacteria: OP50             -100.472      12.1398  -8.28    <1e-14  -124.36    -76.5829
# worm: CB & bacteria: OP50    20.7443     16.8004   1.23    0.2179   -12.3155   53.8041
# worm: MT & bacteria: OP50    12.658      17.4657   0.72    0.4692   -21.7109   47.027
# ───────────────────────────────────────────────────────────────────────────────────────

# CB on and off bacteria vs N2 on and off bacteria
# ie. speed diff of CB vs speed diff of N2
# p = 0.2179 --> not significant, as expected

# MT on and off bacteria vs N2 on and off bacteria
# ie. speed diff of MT vs speed diff of N2
# p = 0.4692 --> not significant, as expected



# comparing across mediums for N2 strain
lm(@formula(meanspeed ~ medium*bacteria), subset(trackstats, :worm=>ByRow(==("N2"))))
# meanspeed ~ 1 + medium + bacteria + medium & bacteria

# Coefficients:
# ───────────────────────────────────────────────────────────────────────────────────────────
#                                    Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ───────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                   269.204        9.88731  27.23    <1e-69   249.71     288.699
# medium: DA                    -16.3228      14.3767   -1.14    0.2576   -44.6689    12.0232
# bacteria: OP50               -100.851       12.7428   -7.91    <1e-12  -125.976    -75.7266
# medium: DA & bacteria: OP50     0.379548    17.9484    0.02    0.9831   -35.0086    35.7677
# ───────────────────────────────────────────────────────────────────────────────────────────

# dopamine vs. buffer, bacteria vs. no bacteria
# ie. speed diff of N2 w buffer vs. w dopamine
# p = 0.9831 --> not significant, as expected



# comparing across mediums for CB strain
lm(@formula(meanspeed ~ medium*bacteria), subset(trackstats, :worm=>ByRow(==("CB"))))
# meanspeed ~ 1 + medium + bacteria + medium & bacteria

# Coefficients:
# ────────────────────────────────────────────────────────────────────────────────────────
#                                 Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                  205.086      10.6991  19.17    <1e-47   183.997   226.176
# medium: DA                    15.0284     14.4266   1.04    0.2987   -13.408    43.4649
# bacteria: OP50               -30.8484     13.0445  -2.36    0.0189   -56.5604   -5.13627
# medium: DA & bacteria: OP50  -48.8789     18.1164  -2.70    0.0075   -84.5883  -13.1694
# ────────────────────────────────────────────────────────────────────────────────────────

# dopamine vs. buffer, bacteria vs. no bacteria
# ie. speed diff of CB w buffer vs. w dopamine
# p = 0.0075 --> significant, as expected



# comparing across mediums for MT strain
lm(@formula(meanspeed ~ medium*bacteria), subset(trackstats, :worm=>ByRow(==("MT"))))
# meanspeed ~ 1 + medium + bacteria + medium & bacteria

# Coefficients:
# ─────────────────────────────────────────────────────────────────────────────────────────
#                                  Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ─────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                  224.008       9.02944  24.81    <1e-61   206.2     241.815
# medium: DA                    -1.76902    13.3447   -0.13    0.8947   -28.0874   24.5494
# bacteria: OP50               -32.7651     11.862    -2.76    0.0063   -56.1593   -9.37089
# medium: DA & bacteria: OP50  -55.0484     17.4699   -3.15    0.0019   -89.5027  -20.5942
# ─────────────────────────────────────────────────────────────────────────────────────────

# dopamine vs. buffer, bacteria vs. no bacteria
# ie. speed diff of MT w buffer vs. w dopamine
# p = 0.0019 --> significant, as expected



# interaction between all three vars
three_int = lm(@formula(meanspeed ~ medium*worm*bacteria), trackstats)
# meanspeed ~ 1 + medium + worm + bacteria + medium & worm + medium & bacteria + worm & bacteria + medium & worm & bacteria

# Coefficients:
# ────────────────────────────────────────────────────────────────────────────────────────────────────────
#                                               Coef.  Std. Error      t  Pr(>|t|)   Lower 95%   Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                              269.204        9.96727  27.01    <1e-99   249.63     288.778
# medium: DA                               -16.3228      14.493    -1.13    0.2605   -44.7848    12.1391
# worm: CB                                 -64.1178      14.3865   -4.46    <1e-05   -92.3707   -35.865
# worm: MT                                 -45.1968      13.6179   -3.32    0.0010   -71.9402   -18.4534
# bacteria: OP50                          -100.851       12.8459   -7.85    <1e-13  -126.078    -75.6238
# medium: DA & worm: CB                     31.3513      20.1427    1.56    0.1201    -8.20584   70.9084
# medium: DA & worm: MT                     14.5538      19.9527    0.73    0.4660   -24.63      53.7377
# medium: DA & bacteria: OP50                0.379548    18.0936    0.02    0.9833   -35.1533    35.9124
# worm: CB & bacteria: OP50                 70.0027      18.0278    3.88    0.0001    34.5991   105.406
# worm: MT & bacteria: OP50                 68.086       17.709     3.84    0.0001    33.3083   102.864
# medium: DA & worm: CB & bacteria: OP50   -49.2584      25.2182   -1.95    0.0512   -98.7829     0.266115
# medium: DA & worm: MT & bacteria: OP50   -55.428       25.4888   -2.17    0.0300  -105.484     -5.37193
# ────────────────────────────────────────────────────────────────────────────────────────────────────────

# interaction between two of the three vars
two_int = lm(@formula(meanspeed ~ medium*worm + medium*bacteria + worm*bacteria), trackstats)
# meanspeed ~ 1 + medium + worm + bacteria + medium & worm + medium & bacteria + worm & bacteria

# Coefficients:
# ──────────────────────────────────────────────────────────────────────────────────────────
#                                   Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ──────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                  258.497        8.91471  29.00    <1e-99   240.99    276.004
# medium: DA                     6.31613     10.9452    0.58    0.5641   -15.1784   27.8107
# worm: CB                     -48.5366      11.8467   -4.10    <1e-04   -71.8014  -25.2718
# worm: MT                     -29.1081      11.5427   -2.52    0.0119   -51.776    -6.44023
# bacteria: OP50               -83.0655      10.4656   -7.94    <1e-14  -103.618   -62.513
# medium: DA & worm: CB         -0.148857    12.1557   -0.01    0.9902   -24.0205   23.7228
# medium: DA & worm: MT        -19.8385      12.4456   -1.59    0.1114   -44.2795    4.60258
# medium: DA & bacteria: OP50  -34.9053      10.3463   -3.37    0.0008   -55.2237  -14.5869
# worm: CB & bacteria: OP50     44.9726      12.6434    3.56    0.0004    20.1431   69.8021
# worm: MT & bacteria: OP50     41.0138      12.7709    3.21    0.0014    15.9339   66.0937
# ──────────────────────────────────────────────────────────────────────────────────────────

ftest(three_int.model, two_int.model)
# F-test: 2 models fitted on 625 observations
# ─────────────────────────────────────────────────────────────────────────
#      DOF  ΔDOF           SSR        ΔSSR      R²      ΔR²      F*   p(>F)
# ─────────────────────────────────────────────────────────────────────────
# [1]   13        2375077.8791              0.2954                         
# [2]   11    -2  2397142.0002  22064.1211  0.2889  -0.0065  2.8473  0.0588
# ─────────────────────────────────────────────────────────────────────────
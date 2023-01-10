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

# N2 on and off bacteria on buffer vs. dopamine
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

# CB on and off bacteria on buffer vs. dopamine
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

# MT on and off bacteria on buffer vs. dopamine
# ie. speed diff of MT w buffer vs. w dopamine
# p = 0.1048 --> NOT SIGNIFICANT, NOT AS EXPECTED



# comparing across mediums for WT and CB strains
lm(@formula(meanspeed ~ medium*bacteria*worm), subset(trackstats, :worm=>ByRow(!=("MT"))))
# meanspeed ~ 1 + medium + bacteria + worm + medium & bacteria + medium & worm + bacteria & worm + medium & bacteria & worm

# Coefficients:
# ─────────────────────────────────────────────────────────────────────────────────────────────────────
#                                             Coef.  Std. Error       t  Pr(>|t|)  Lower 95%  Upper 95%
# ─────────────────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                              292.938      10.079    29.06    <1e-69   273.051    312.824
# medium: DA                               -56.6264     13.3785   -4.23    <1e-04   -83.0233   -30.2294
# bacteria: BL21                          -171.053      12.8102  -13.35    <1e-28  -196.329   -145.778
# worm: CB                                 -45.5792     12.6347   -3.61    0.0004   -70.5085   -20.6499
# medium: DA & bacteria: BL21               53.0266     17.0966    3.10    0.0022    19.2936    86.7596
# medium: DA & worm: CB                     53.4451     17.3796    3.08    0.0024    19.1538    87.7365
# bacteria: BL21 & worm: CB                149.003      17.8258    8.36    <1e-13   113.831    184.175
# medium: DA & bacteria: BL21 & worm: CB  -152.195      23.9996   -6.34    <1e-08  -199.548   -104.842
# ─────────────────────────────────────────────────────────────────────────────────────────────────────

# p <1e-08 --> significant, as expected

# comparing across mediums for WT and MT strains
lm(@formula(meanspeed ~ medium*bacteria*worm), subset(trackstats, :worm=>ByRow(!=("CB"))))
# meanspeed ~ 1 + medium + bacteria + worm + medium & bacteria + medium & worm + bacteria & worm + medium & bacteria & worm

# Coefficients:
# ──────────────────────────────────────────────────────────────────────────────────────────────────────
#                                             Coef.  Std. Error       t  Pr(>|t|)   Lower 95%  Upper 95%
# ──────────────────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                              292.938      12.0038   24.40    <1e-58   269.25      316.625
# medium: DA                               -56.6264     15.9335   -3.55    0.0005   -88.068     -25.1847
# bacteria: BL21                          -171.053      15.2566  -11.21    <1e-21  -201.159    -140.947
# worm: MT                                 -69.0725     15.7761   -4.38    <1e-04  -100.204     -37.9414
# medium: DA & bacteria: BL21               53.0266     20.3616    2.60    0.0100    12.847      93.2062
# medium: DA & worm: MT                     44.0299     21.4221    2.06    0.0413     1.75741    86.3023
# bacteria: BL21 & worm: MT                123.34       21.1505    5.83    <1e-07    81.6034    165.076
# medium: DA & bacteria: BL21 & worm: MT   -89.7831     28.6021   -3.14    0.0020  -146.224     -33.3424
# ──────────────────────────────────────────────────────────────────────────────────────────────────────

# p = 0.0020 --> significant, as expected

# save CSVs for each subset
CSV.write(joinpath(experimentdir, "alltracks_data.csv"), trackstats)
CSV.write(joinpath(experimentdir, "M9_data.csv"), select(subset(trackstats, :medium=>ByRow(==("M9"))), "meanspeed", "worm", "bacteria"))
CSV.write(joinpath(experimentdir, "DA_data.csv"), select(subset(trackstats, :medium=>ByRow(==("DA"))), "meanspeed", "worm", "bacteria"))
CSV.write(joinpath(experimentdir, "N2_data.csv"), select(subset(trackstats, :worm=>ByRow(==("N2"))), "meanspeed", "medium", "bacteria"))
CSV.write(joinpath(experimentdir, "CB_data.csv"), select(subset(trackstats, :worm=>ByRow(==("CB"))), "meanspeed", "medium", "bacteria"))
CSV.write(joinpath(experimentdir, "MT_data.csv"), select(subset(trackstats, :worm=>ByRow(==("MT"))), "meanspeed", "medium", "bacteria"))

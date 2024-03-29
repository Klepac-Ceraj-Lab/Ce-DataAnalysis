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



# comparing across mediums for WT and CB strains
lm(@formula(meanspeed ~ medium*bacteria*worm), subset(trackstats, :worm=>ByRow(!=("MT"))))
# meanspeed ~ 1 + medium + bacteria + worm + medium & bacteria + medium & worm + bacteria & worm + medium & bacteria & worm

# Coefficients:
# ────────────────────────────────────────────────────────────────────────────────────────────────────
#                                             Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                              289.403      10.3087  28.07    <1e-72   269.084    309.723
# medium: LD                               -46.9815     14.1828  -3.31    0.0011   -74.9373   -19.0256
# bacteria: BL21                          -138.103      14.3061  -9.65    <1e-17  -166.302   -109.904
# worm: CB                                 -59.3747     13.8553  -4.29    <1e-04   -86.685    -32.0643
# medium: LD & bacteria: BL21               56.5327     19.7004   2.87    0.0045    17.701     95.3643
# medium: LD & worm: CB                     49.1556     19.6278   2.50    0.0130    10.4671    87.8441
# bacteria: BL21 & worm: CB                106.918      19.8128   5.40    <1e-06    67.8651   145.972
# medium: LD & bacteria: BL21 & worm: CB  -113.248      27.7357  -4.08    <1e-04  -167.919    -58.5783
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# p <1e-04 --> significant, as expected

# comparing across mediums for WT and MT strains
lm(@formula(meanspeed ~ medium*bacteria*worm), subset(trackstats, :worm=>ByRow(!=("CB"))))
# meanspeed ~ 1 + medium + bacteria + worm + medium & bacteria + medium & worm + bacteria & worm + medium & bacteria & worm

# Coefficients:
# ─────────────────────────────────────────────────────────────────────────────────────────────────────
#                                              Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ─────────────────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                              289.403       10.4955  27.57    <1e-70   268.712    310.095
# medium: LD                               -46.9815      14.4398  -3.25    0.0013   -75.4486   -18.5144
# bacteria: BL21                          -138.103       14.5654  -9.48    <1e-17  -166.818   -109.388
# worm: MT                                 -61.8596      14.5654  -4.25    <1e-04   -90.5743   -33.1449
# medium: LD & bacteria: BL21               56.5327      20.0574   2.82    0.0053    16.9909    96.0744
# medium: LD & worm: MT                     -4.34193     20.2202  -0.21    0.8302   -44.2046    35.5208
# bacteria: BL21 & worm: MT                100.288       20.8297   4.81    <1e-05    59.2231   141.352
# medium: LD & bacteria: BL21 & worm: MT   -70.6695      28.6484  -2.47    0.0144  -127.148    -14.1911
# ─────────────────────────────────────────────────────────────────────────────────────────────────────

# p = 0.0144 --> significant, as expected



# three way interaction between all variables without subsetting
threeway = lm(@formula(meanspeed ~ medium*bacteria*worm), trackstats)
# meanspeed ~ 1 + medium + bacteria + worm + medium & bacteria + medium & worm + bacteria & worm + medium & bacteria & worm

# Coefficients:
# ─────────────────────────────────────────────────────────────────────────────────────────────────────
#                                              Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ─────────────────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                              289.403       10.4183  27.78    <1e-86   268.906    309.901
# medium: LD                               -46.9815      14.3336  -3.28    0.0012   -75.1828   -18.7802
# bacteria: BL21                          -138.103       14.4582  -9.55    <1e-18  -166.55    -109.656
# worm: CB                                 -59.3747      14.0026  -4.24    <1e-04   -86.9248   -31.8245
# worm: MT                                 -61.8596      14.4582  -4.28    <1e-04   -90.3062   -33.413
# medium: LD & bacteria: BL21               56.5327      19.9099   2.84    0.0048    17.36      95.7053
# medium: LD & worm: CB                     49.1556      19.8364   2.48    0.0137    10.1274    88.1838
# medium: LD & worm: MT                     -4.34193     20.0714  -0.22    0.8289   -43.8325    35.1486
# bacteria: BL21 & worm: CB                106.918       20.0235   5.34    <1e-06    67.5222   146.315
# bacteria: BL21 & worm: MT                100.288       20.6766   4.85    <1e-05    59.6064   140.969
# medium: LD & bacteria: BL21 & worm: CB  -113.248       28.0306  -4.04    <1e-04  -168.399    -58.0983
# medium: LD & bacteria: BL21 & worm: MT   -70.6695      28.4377  -2.49    0.0135  -126.621    -14.7183
# ─────────────────────────────────────────────────────────────────────────────────────────────────────

# p <1e-04 comparing across N2 and CB
# p = 0.0135 comparing across N2 and MT

# two way interactions between the three variables without subsetting
twoway = lm(@formula(meanspeed ~ medium*bacteria+medium*worm+bacteria*worm), trackstats)
# meanspeed ~ 1 + medium + bacteria + worm + medium & bacteria + medium & worm + bacteria & worm

# Coefficients:
# ──────────────────────────────────────────────────────────────────────────────────────────
#                                   Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
# ──────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                   272.563       9.63733  28.28    <1e-88   253.602   291.524
# medium: LD                    -15.1054     11.8701   -1.27    0.2041   -38.4593    8.24848
# bacteria: BL21               -105.67       11.9183   -8.87    <1e-16  -129.119   -82.2213
# worm: CB                      -30.8999     12.3996   -2.49    0.0132   -55.2956   -6.50417
# worm: MT                      -42.7849     12.7306   -3.36    0.0009   -67.8318  -17.738
# medium: LD & bacteria: BL21    -4.96972    11.7964   -0.42    0.6738   -28.1785   18.2391
# medium: LD & worm: CB          -7.71331    14.331    -0.54    0.5908   -35.9089   20.4823
# medium: LD & worm: MT         -40.6073     14.5382   -2.79    0.0055   -69.2104  -12.0042
# bacteria: BL21 & worm: CB      48.9788     14.3281    3.42    0.0007    20.7888   77.1687
# bacteria: BL21 & worm: MT      62.9969     14.5182    4.34    <1e-04    34.433    91.5608
# ──────────────────────────────────────────────────────────────────────────────────────────

ftest(threeway.model, twoway.model)
F-test: 2 models fitted on 328 observations
────────────────────────────────────────────────────────────────────────
     DOF  ΔDOF          SSR        ΔSSR      R²      ΔR²      F*   p(>F)
────────────────────────────────────────────────────────────────────────
[1]   13        857469.1233              0.4489                         
[2]   11    -2  902578.3839  45109.2606  0.4199  -0.0290  8.3120  0.0003
────────────────────────────────────────────────────────────────────────

# p = 0.0003 between the two models
# --> significant difference when taking all interactions into account vs. just two

r2(threeway) # reports R^2 value for model (proportion of data explained by the model)
# 0.4489105529868552 --> 0.449



# save CSVs for each subset
CSV.write(joinpath(experimentdir, "alltracks_data.csv"), trackstats)
CSV.write(joinpath(experimentdir, "M9_data.csv"), select(subset(trackstats, :medium=>ByRow(==("M9"))), "meanspeed", "worm", "bacteria"))
CSV.write(joinpath(experimentdir, "LD_data.csv"), select(subset(trackstats, :medium=>ByRow(==("LD"))), "meanspeed", "worm", "bacteria"))
CSV.write(joinpath(experimentdir, "N2_data.csv"), select(subset(trackstats, :worm=>ByRow(==("N2"))), "meanspeed", "medium", "bacteria"))
CSV.write(joinpath(experimentdir, "CB_data.csv"), select(subset(trackstats, :worm=>ByRow(==("CB"))), "meanspeed", "medium", "bacteria"))
CSV.write(joinpath(experimentdir, "MT_data.csv"), select(subset(trackstats, :worm=>ByRow(==("MT"))), "meanspeed", "medium", "bacteria"))

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

# MODELS
one = lm(@formula(meanspeed ~ 1), trackstats) # we don't have any var affecting speed

m = lm(@formula(meanspeed ~ medium), trackstats) # speed depends only on medium (buffer vs. dopamine)
w = lm(@formula(meanspeed ~ worm), trackstats) # speed depends only on worm strain
b = lm(@formula(meanspeed ~ bacteria), trackstats) # speed depends only on bacteria presence

mw = lm(@formula(meanspeed ~ medium + worm), trackstats) # speed depends on medium and worm
wb = lm(@formula(meanspeed ~ worm + bacteria), trackstats) # speed depends on worm and bacteria
mb = lm(@formula(meanspeed ~ medium + bacteria), trackstats) # speed depends on medium and bacteria

mwb = lm(@formula(meanspeed ~ medium + worm + bacteria), trackstats) # speed depends on all three variables

wb_int_m = lm(@formula(meanspeed ~ worm*bacteria + medium), trackstats) # interaction between worm and bacteria
# Coefficients:
# ────────────────────────────────────────────────────────────────────────────────────────
#                                Coef.  Std. Error       t  Pr(>|t|)  Lower 95%  Upper 95%
# ────────────────────────────────────────────────────────────────────────────────────────
# (Intercept)                 271.758      7.70373   35.28    <1e-99   256.629    286.887
# worm: CB                    -46.4588    10.1673    -4.57    <1e-05   -66.4255   -26.492
# worm: MT                    -38.6153    10.0716    -3.83    0.0001   -58.394    -18.8367
# bacteria: OP50             -100.17       9.13385  -10.97    <1e-24  -118.108    -82.2332
# medium: DA                  -21.722      5.05884   -4.29    <1e-04   -31.6566   -11.7874
# worm: CB & bacteria: OP50    43.4845    12.7419     3.41    0.0007    18.4619    68.5071
# worm: MT & bacteria: OP50    41.9327    12.8612     3.26    0.0012    16.6757    67.1896
# ────────────────────────────────────────────────────────────────────────────────────────

mwb_int = lm(@formula(meanspeed ~ medium*worm*bacteria), trackstats) # interaction between all variables
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



# F TESTS
# ftest = is fit of second model better than fit of first model

# Does bacteria affect speed, also separating by medium?
ftest(mw.model, mwb.model)
# F-test: 2 models fitted on 625 observations
# ────────────────────────────────────────────────────────────────────────────
#      DOF  ΔDOF           SSR          ΔSSR      R²     ΔR²        F*   p(>F)
# ────────────────────────────────────────────────────────────────────────────
# [1]    5        3257210.6688                0.0337                          
# [2]    6     1  2510861.8156  -746348.8531  0.2551  0.2214  184.2938  <1e-36
# ────────────────────────────────────────────────────────────────────────────

# Does bacteria affect speed dependent on worm, also separating by medium?
ftest(mw.model, wb_int_m.model)
# F-test: 2 models fitted on 625 observations
# ───────────────────────────────────────────────────────────────────────────
#      DOF  ΔDOF           SSR          ΔSSR      R²     ΔR²       F*   p(>F)
# ───────────────────────────────────────────────────────────────────────────
# [1]    5        3257210.6688                0.0337                         
# [2]    8     3  2452259.7245  -804950.9442  0.2725  0.2388  67.6192  <1e-37
# ───────────────────────────────────────────────────────────────────────────

# Does bacteria affect speed dependent on worm and medium?
ftest(one.model, mwb_int.model)
# F-test: 2 models fitted on 625 observations
# ───────────────────────────────────────────────────────────────────────────
#      DOF  ΔDOF           SSR          ΔSSR      R²     ΔR²       F*   p(>F)
# ───────────────────────────────────────────────────────────────────────────
# [1]    2        3370821.8383                0.0000                         
# [2]   13    11  2375077.8791  -995743.9592  0.2954  0.2954  23.3635  <1e-39
# ───────────────────────────────────────────────────────────────────────────

# Is speed dependent on an interactions among all variables?
ftest(mwb.model, mwb_int.model)
# F-test: 2 models fitted on 625 observations
# ──────────────────────────────────────────────────────────────────────────
#      DOF  ΔDOF           SSR          ΔSSR      R²     ΔR²      F*   p(>F)
# ──────────────────────────────────────────────────────────────────────────
# [1]    6        2510861.8156                0.2551                        
# [2]   13     7  2375077.8791  -135783.9365  0.2954  0.0403  5.0065  <1e-04
# ──────────────────────────────────────────────────────────────────────────
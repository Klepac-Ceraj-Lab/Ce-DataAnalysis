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



# # MODELING

# # MODELS
# one = lm(@formula(meanspeed ~ 1), trackstats) # we don't have any var affecting speed

# m = lm(@formula(meanspeed ~ medium), trackstats) # speed depends only on medium (buffer vs. dopamine)
# w = lm(@formula(meanspeed ~ worm), trackstats) # speed depends only on worm strain
# b = lm(@formula(meanspeed ~ bacteria), trackstats) # speed depends only on bacteria presence

# mw = lm(@formula(meanspeed ~ medium + worm), trackstats) # speed depends on medium and worm
# wb = lm(@formula(meanspeed ~ worm + bacteria), trackstats) # speed depends on worm and bacteria
# mb = lm(@formula(meanspeed ~ medium + bacteria), trackstats) # speed depends on medium and bacteria

# mwb = lm(@formula(meanspeed ~ medium + worm + bacteria), trackstats) # speed depends on all three variables

# wb_int_m = lm(@formula(meanspeed ~ worm*bacteria + medium), trackstats) # interaction between worm and bacteria

# mwb_int = lm(@formula(meanspeed ~ medium*worm*bacteria), trackstats) # interaction between all variables



# # F TESTS
# # ftest = is fit of second model better than fit of first model

# # Does bacteria affect speed, also separating by medium?
# ftest(mw.model, mwb.model)
# # F-test: 2 models fitted on 625 observations
# # ────────────────────────────────────────────────────────────────────────────
# #      DOF  ΔDOF           SSR          ΔSSR      R²     ΔR²        F*   p(>F)
# # ────────────────────────────────────────────────────────────────────────────
# # [1]    5        3257210.6688                0.0337                          
# # [2]    6     1  2510861.8156  -746348.8531  0.2551  0.2214  184.2938  <1e-36
# # ────────────────────────────────────────────────────────────────────────────

# # Does bacteria affect speed dependent on worm, also separating by medium?
# ftest(mw.model, wb_int_m.model)
# # F-test: 2 models fitted on 625 observations
# # ───────────────────────────────────────────────────────────────────────────
# #      DOF  ΔDOF           SSR          ΔSSR      R²     ΔR²       F*   p(>F)
# # ───────────────────────────────────────────────────────────────────────────
# # [1]    5        3257210.6688                0.0337                         
# # [2]    8     3  2452259.7245  -804950.9442  0.2725  0.2388  67.6192  <1e-37
# # ───────────────────────────────────────────────────────────────────────────

# # Does bacteria affect speed dependent on worm and medium?
# ftest(one.model, mwb_int.model)
# # F-test: 2 models fitted on 625 observations
# # ───────────────────────────────────────────────────────────────────────────
# #      DOF  ΔDOF           SSR          ΔSSR      R²     ΔR²       F*   p(>F)
# # ───────────────────────────────────────────────────────────────────────────
# # [1]    2        3370821.8383                0.0000                         
# # [2]   13    11  2375077.8791  -995743.9592  0.2954  0.2954  23.3635  <1e-39
# # ───────────────────────────────────────────────────────────────────────────

# # Is speed dependent on an interactions among all variables?
# ftest(mwb.model, mwb_int.model)
# # F-test: 2 models fitted on 625 observations
# # ──────────────────────────────────────────────────────────────────────────
# #      DOF  ΔDOF           SSR          ΔSSR      R²     ΔR²      F*   p(>F)
# # ──────────────────────────────────────────────────────────────────────────
# # [1]    6        2510861.8156                0.2551                        
# # [2]   13     7  2375077.8791  -135783.9365  0.2954  0.0403  5.0065  <1e-04
# # ──────────────────────────────────────────────────────────────────────────



# ANOVAS

# interaction between medium and worm
mw = lm(@formula(meanspeed ~ medium + worm), trackstats)
mw_int = lm(@formula(meanspeed ~ medium + worm + medium*worm), trackstats)

ftest(mw.model, mw_int.model)
# F-test: 2 models fitted on 625 observations
# ─────────────────────────────────────────────────────────────────────────
#      DOF  ΔDOF           SSR         ΔSSR      R²     ΔR²      F*   p(>F)
# ─────────────────────────────────────────────────────────────────────────
# [1]    5        3257210.6688               0.0337                        
# [2]    7     2  3243550.4037  -13660.2651  0.0378  0.0041  1.3035  0.2723
# ─────────────────────────────────────────────────────────────────────────

# interaction between worm and bacteria 
wb = lm(@formula(meanspeed ~ worm + bacteria), trackstats)
wb_int = lm(@formula(meanspeed ~ worm + bacteria + worm*bacteria), trackstats)

ftest(wb.model, wb_int.model)
# F-test: 2 models fitted on 625 observations
# ─────────────────────────────────────────────────────────────────────────
#      DOF  ΔDOF           SSR         ΔSSR      R²     ΔR²      F*   p(>F)
# ─────────────────────────────────────────────────────────────────────────
# [1]    5        2592321.8552               0.2310                        
# [2]    7     2  2525420.2672  -66901.5881  0.2508  0.0198  8.1990  0.0003
# ─────────────────────────────────────────────────────────────────────────

# interaction between worm and bacteria, also considering medium
mwb = lm(@formula(meanspeed ~ medium + worm + bacteria), trackstats)
wb_int_m = lm(@formula(meanspeed ~ medium + worm + bacteria + worm*bacteria), trackstats)

ftest(mwb.model, wb_int_m.model)
# F-test: 2 models fitted on 625 observations
# ─────────────────────────────────────────────────────────────────────────
#      DOF  ΔDOF           SSR         ΔSSR      R²     ΔR²      F*   p(>F)
# ─────────────────────────────────────────────────────────────────────────
# [1]    6        2510861.8156               0.2551                        
# [2]    8     2  2452259.7245  -58602.0911  0.2725  0.0174  7.3842  0.0007
# ─────────────────────────────────────────────────────────────────────────

# interaction among all vars
mwb = lm(@formula(meanspeed ~ medium + worm + bacteria), trackstats)
mwb_int = lm(@formula(meanspeed ~ medium + worm + bacteria + medium*worm*bacteria), trackstats)

ftest(mwb.model, mwb_int.model)
# F-test: 2 models fitted on 625 observations
# ──────────────────────────────────────────────────────────────────────────
#      DOF  ΔDOF           SSR          ΔSSR      R²     ΔR²      F*   p(>F)
# ──────────────────────────────────────────────────────────────────────────
# [1]    6        2510861.8156                0.2551                        
# [2]   13     7  2375077.8791  -135783.9365  0.2954  0.0403  5.0065  <1e-04
# ──────────────────────────────────────────────────────────────────────────
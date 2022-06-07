using DataFrames
using CSV
using CategoricalArrays
using GLMakie



# LOAD SPEEDS CSV INTO DATAFRAME
experimentdir = "./22spring/experiment4/experiment4b/"
speedscsv = joinpath(experimentdir, "speeds.csv")
speeds = DataFrame(CSV.File(speedscsv))



# MAKE CATEGORICAL ARRAYS FOR PLOTTING
speeds.medium = categorical(map(i-> split(i, '_')[1], speeds.id))
speeds.worm = categorical(map(i-> split(i, '_')[2], speeds.id))
speeds.bacteria = categorical(map(i-> split(i, '_')[3], speeds.id))
speeds.id = categorical(speeds.id, levels=[ "DA_N2_OP50", "DA_N2_NGM",
                                            "DA_CB_OP50", "DA_CB_NGM",
                                            "DA_MT_OP50", "DA_MT_NGM",
                                            "M9_N2_OP50", "M9_N2_NGM",
                                            "M9_CB_OP50", "M9_CB_NGM",
                                            "M9_MT_OP50", "M9_MT_NGM"])
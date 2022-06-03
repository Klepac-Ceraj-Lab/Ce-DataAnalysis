using CeDataAnalysis
using DataFrames
using CSV
# using CategoricalArrays
# using GLMakie



# COMPILE DATAFRAME WITH 5 POSITION MEASUREMENTS EVERY SEC
data = DataFrame(id=String[], track=Int[], xpos=Float64[], ypos=Float64[])

datafolder = "./22spring/experiment4/experiment4b/data/Position/"

for f in 131:136
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "DA_N2_OP50")
end

for f in 137:142
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "DA_N2_NGM")
end

for f in 143:147
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "DA_CB_OP50")
end

for f in 148:152
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "DA_CB_NGM")
end

for f in 153:156
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "DA_MT_OP50")
end

for f in 157:160
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "DA_MT_NGM")
end

for f in 161:163
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "M9_N2_OP50")
end

for f in 164:166
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "M9_N2_NGM")
end

for f in 167:168
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "M9_CB_OP50")
end

for f in 169:171
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "M9_CB_NGM")
end

for f in 172:175
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "M9_MT_OP50")
end

for f in 175:179
    load_tracks!(data, joinpath(datafolder, string(f, "Position.csv")), "M9_MT_NGM")
end



# CALCULATE SPEED/DISTANCE FROM POSITION
speed(data) # calculate speed from position

# AVERAGE SPEED MEASUREMENTS ACROSS 5 SEC
speedperfive = averageoverfive(data)



# SAVE FINAL DATAFRAME
CSV.write("./22spring/experiment4/experiment4b/speeds.csv", speedperfive)

# LOAD SPEEDS CSV INTO DATAFRAME
speeds = DataFrame(CSV.File("./22spring/experiment4/experiment4b/speeds.csv"))



# SUMMARY STATS
conditionstats(speeds)
allstats(speeds)



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
using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 131:179
files.id = [
    fill("DA_N2_OP50", length(131:136));
    fill("DA_N2_NGM", length(137:142));
    fill("DA_CB_OP50", length(143:147));
    fill("DA_CB_NGM", length(148:152));
    fill("DA_MT_OP50", length(153:156));
    fill("DA_MT_NGM", length(157:160));
    fill("M9_N2_OP50", length(161:163));
    fill("M9_N2_NGM", length(164:166));
    fill("M9_CB_OP50", length(167:168));
    fill("M9_CB_NGM", length(169:171));
    fill("M9_MT_OP50", length(172:175));
    fill("M9_MT_NGM", length(176:179))
]



# DEFINE EXPERIMENT DIRECTORY
experimentdir = "./dopamine/experiment4/experiment4b/"



# COMPILE DATAFRAME WITH 5 POSITION MEASUREMENTS EVERY SEC
data = DataFrame(id=String[], track=Int[], xpos=Float64[], ypos=Float64[])

positionsdir = joinpath(experimentdir, "data/Position")

for row in eachrow(files)
    load_tracks!(data, joinpath(positionsdir, string(row.num, "Position.csv")), row.id)
end



# CALCULATE DISTANCE FROM POSITION (µm/0.2sec)
distance(data)

# CALCULATE SPEED FROM DISTANCE
speed(data)

# AVERAGE SPEED MEASUREMENTS ACROSS 5 SEC (AVERAGE OF 25 MEASUREMENTS)
speedperfive = averageoverfive(data)



# SUMMARY STATS
conditionstats(speedperfive)
allstats(speedperfive)



# SAVE FINAL DATAFRAME
speedscsv = joinpath(experimentdir, "speeds.csv")

CSV.write(speedscsv, speedperfive)
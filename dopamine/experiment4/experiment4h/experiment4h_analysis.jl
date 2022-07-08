using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 53:102
files.id = [
    fill("DA_N2_OP50", length(53:55));
    fill("DA_N2_NGM", length(56:63));
    fill("DA_CB_OP50", length(64:67));
    fill("DA_CB_NGM", length(68:70));
    fill("DA_MT_OP50", length(71:74));
    fill("DA_MT_NGM", length(75:79));
    fill("M9_N2_OP50", length(80:81));
    fill("M9_N2_NGM", length(82:86));
    fill("M9_CB_OP50", length(87:89));
    fill("M9_CB_NGM", length(90:93));
    fill("M9_MT_OP50", length(94:100));
    fill("M9_MT_NGM", length(101:102))
]



# DEFINE EXPERIMENT DIRECTORY
experimentdir = "./dopamine/experiment4/experiment4h/"



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
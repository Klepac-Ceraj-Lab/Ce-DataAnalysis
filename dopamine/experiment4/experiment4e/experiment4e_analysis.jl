using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 181:230
files.id = [
    fill("DA_N2_OP50", length(181:183));
    fill("DA_N2_NGM", length(184:188));
    fill("DA_CB_OP50", length(189:192));
    fill("DA_CB_NGM", length(193:195));
    fill("DA_MT_OP50", length(196:198));
    fill("DA_MT_NGM", length(199:202));
    fill("M9_N2_OP50", length(203:206));
    fill("M9_N2_NGM", length(207:211));
    fill("M9_CB_OP50", length(212:215));
    fill("M9_CB_NGM", length(216:218));
    fill("M9_MT_OP50", length(219:224));
    fill("M9_MT_NGM", length(225:230))
]

deleteat!(files, 12) # did not get data from VID192 --> deleted row for that file



# DEFINE EXPERIMENT DIRECTORY
experimentdir = @__DIR__



# COMPILE DATAFRAME WITH 5 POSITION MEASUREMENTS EVERY SEC
data = DataFrame(id=String[], track=Int[], xpos=Float64[], ypos=Float64[])

positionsdir = joinpath(experimentdir, "data", "Position")

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
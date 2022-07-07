using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 1:51
files.id = [
    fill("DA_N2_OP50", length(1:5));
    fill("DA_N2_NGM", length(6:9));
    fill("DA_CB_OP50", length(10:15));
    fill("DA_CB_NGM", length(16:21));
    fill("DA_MT_OP50", length(22:25));
    fill("DA_MT_NGM", length(26:29));
    fill("M9_N2_OP50", length(30:32));
    fill("M9_N2_NGM", length(33:36));
    fill("M9_CB_OP50", length(37:38));
    fill("M9_CB_NGM", length(39:42));
    fill("M9_MT_OP50", length(43:47));
    fill("M9_MT_NGM", length(48:51))
]



# DEFINE EXPERIMENT DIRECTORY
experimentdir = "./dopamine/experiment4/experiment4g/"



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
using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 233:284
files.id = [
    fill("DA_N2_OP50", length(233:237));
    fill("DA_N2_NGM", length(238:240));
    fill("DA_CB_OP50", length(241:243));
    fill("DA_CB_NGM", length(244:248));
    fill("DA_MT_OP50", length(249:254));
    fill("DA_MT_NGM", length(255:257));
    fill("M9_N2_OP50", length(258:261));
    fill("M9_N2_NGM", length(262:265));
    fill("M9_CB_OP50", length(266:269));
    fill("M9_CB_NGM", length(270:273));
    fill("M9_MT_OP50", length(274:278));
    fill("M9_MT_NGM", length(279:284))
]



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
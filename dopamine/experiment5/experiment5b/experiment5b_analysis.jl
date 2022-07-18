using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 146:192
files.id = [
    fill("DA_N2_OP50", length(146:148));
    fill("DA_N2_NGM", length(149:151));
    fill("DA_CB_OP50", length(152:155));
    fill("DA_CB_NGM", length(156:159));
    fill("DA_MT_OP50", length(160:163));
    fill("DA_MT_NGM", length(164:167));
    fill("M9_N2_OP50", length(168:170));
    fill("M9_N2_NGM", length(171:174));
    fill("M9_CB_OP50", length(175:179));
    fill("M9_CB_NGM", length(180:184));
    fill("M9_MT_OP50", length(185:188));
    fill("M9_MT_NGM", length(189:192))
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
distance!(data)

# CALCULATE SPEED FROM DISTANCE
speed!(data)

# AVERAGE SPEED MEASUREMENTS ACROSS 5 SEC (AVERAGE OF 25 MEASUREMENTS)
speedperfive = averageoverfive(data)



# SAVE FINAL DATAFRAME
speedscsv = joinpath(experimentdir, "speeds.csv")

CSV.write(speedscsv, speedperfive)
using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 5:45
files.id = [
    fill("DA_N2_BL21", length(5:7));
    fill("DA_N2_NGM", length(8:11));
    fill("DA_CB_BL21", length(12:14));
    fill("DA_CB_NGM", length(15:18));
    fill("DA_MT_BL21", length(19:21));
    fill("DA_MT_NGM", length(22:24));
    fill("M9_N2_BL21", length(25:28));
    fill("M9_N2_NGM", length(29:32));
    fill("M9_CB_BL21", length(33:36));
    fill("M9_CB_NGM", length(37:38));
    fill("M9_MT_BL21", length(39:42));
    fill("M9_MT_NGM", length(43:45))
]



# DEFINE EXPERIMENT DIRECTORY
experimentdir = @__DIR__



# CREATE DATAFRAME FROM CSV WITH ALL POSITION DATA
alldata = DataFrame(id=String[], track=Int[], xpos=Float64[], ypos=Float64[])

positionsdir = joinpath(experimentdir, "data", "Position")

for row in eachrow(files)
    load_tracks!(alldata, joinpath(positionsdir, string(row.num, "Position.csv")), row.id)
end

# TAKE EVERY 5 POSITION MEASUREMENTS OF EACH TRACK
alltracks = groupby(alldata, [:id, :track]) # group df by condition id and track
data = combine(groupby(alldata, [:id, :track]), x->x[5:5:end, :]) # filter out every fifth row of each grouped df

# CALCULATE DISTANCE FROM POSITION (µm/0.2sec)
distance!(data)

# CALCULATE SPEED FROM DISTANCE
speed!(data)

# AVERAGE SPEED MEASUREMENTS ACROSS 5 SEC (AVERAGE OF 25 MEASUREMENTS)
speedperfive = averageoverfive(data)

# set scale incorrectly in WormLab --> multiply each value by 10 to get correct scale
for row in eachrow(speedperfive)
    speedperfive.correctspeed = speedperfive.speed * 10
end



# SAVE FINAL DATAFRAME
speedscsv = joinpath(experimentdir, "speeds.csv")

CSV.write(speedscsv, speedperfive)
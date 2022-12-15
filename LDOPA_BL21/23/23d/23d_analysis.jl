using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 2:39
files.id = [
    fill("LD_N2_BL21", length(2:5));
    fill("LD_N2_NGM", length(6:10));
    fill("LD_CB_BL21", length(11:14));
    fill("LD_CB_NGM", length(15:18));
    fill("LD_MT_BL21", length(19:22));
    fill("LD_MT_NGM", length(23:24));
    fill("M9_N2_BL21", length(25:27));
    fill("M9_N2_NGM", length(28:29));
    fill("M9_CB_BL21", length(30:32));
    fill("M9_CB_NGM", length(33:34));
    fill("M9_MT_BL21", length(35:37));
    fill("M9_MT_NGM", length(38:39))
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



# SAVE FINAL DATAFRAME
speedscsv = joinpath(experimentdir, "speeds.csv")

CSV.write(speedscsv, speedperfive)
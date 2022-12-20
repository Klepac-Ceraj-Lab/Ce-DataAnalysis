using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 41:81
files.id = [
    fill("LD_N2_BL21", length(41:44));
    fill("LD_N2_NGM", length(45:47));
    fill("LD_CB_BL21", length(48:49));
    fill("LD_CB_NGM", length(50:51));
    fill("LD_MT_BL21", length(52:56));
    fill("LD_MT_NGM", length(57:59));
    fill("M9_N2_BL21", length(60:63));
    fill("M9_N2_NGM", length(64:68));
    fill("M9_CB_BL21", length(69:71));
    fill("M9_CB_NGM", length(72:74));
    fill("M9_MT_BL21", length(75:78));
    fill("M9_MT_NGM", length(79:81))
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
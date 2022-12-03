using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 01:46
files.id = [
    fill("LD_N2_BL21", length(01:04));
    fill("LD_N2_NGM", length(05:07));
    fill("LD_CB_BL21", length(08:11));
    fill("LD_CB_NGM", length(12:15));
    fill("LD_MT_BL21", length(16:19));
    fill("LD_MT_NGM", length(20:23));
    fill("M9_N2_BL21", length(24:27));
    fill("M9_N2_NGM", length(28:31));
    fill("M9_CB_BL21", length(32:35));
    fill("M9_CB_NGM", length(36:38));
    fill("M9_MT_BL21", length(39:43));
    fill("M9_MT_NGM", length(44:46))
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
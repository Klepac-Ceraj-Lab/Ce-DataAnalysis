using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 135:183
files.id = [
    fill("DA_N2_BL21", length(135:138));
    fill("DA_N2_NGM", length(139:141));
    fill("DA_CB_BL21", length(142:144));
    fill("DA_CB_NGM", length(145:148));
    fill("DA_MT_BL21", length(149:152));
    fill("DA_MT_NGM", length(153:157));
    fill("M9_N2_BL21", length(158:161));
    fill("M9_N2_NGM", length(162:166));
    fill("M9_CB_BL21", length(167:170));
    fill("M9_CB_NGM", length(171:174));
    fill("M9_MT_BL21", length(175:179));
    fill("M9_MT_NGM", length(180:183))
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
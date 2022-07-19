using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 104:144
files.id = [
    fill("DA_N2_OP50", length(104:107));
    fill("DA_N2_NGM", length(108:110));
    fill("DA_CB_OP50", length(111:113));
    fill("DA_CB_NGM", length(114:115));
    fill("DA_MT_OP50", length(116:120));
    fill("DA_MT_NGM", length(121:123));
    fill("M9_N2_OP50", length(124:126));
    fill("M9_N2_NGM", length(127:129));
    fill("M9_CB_OP50", length(130:134));
    fill("M9_CB_NGM", length(135:137));
    fill("M9_MT_OP50", length(138:142));
    fill("M9_MT_NGM", length(143:144))
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
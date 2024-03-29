using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 230:278
files.id = [
    fill("LD_N2_BL21", length(230:233));
    fill("LD_N2_NGM", length(234:238));
    fill("LD_CB_BL21", length(239:242));
    fill("LD_CB_NGM", length(243:247));
    fill("LD_MT_BL21", length(248:251));
    fill("LD_MT_NGM", length(252:257));
    fill("M9_N2_BL21", length(258:261));
    fill("M9_N2_NGM", length(262:264));
    fill("M9_CB_BL21", length(265:268));
    fill("M9_CB_NGM", length(269:271));
    fill("M9_MT_BL21", length(272:275));
    fill("M9_MT_NGM", length(276:278))
]

deleteat!(files, 45) # did not get data from VID201 --> deleted row for that file

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
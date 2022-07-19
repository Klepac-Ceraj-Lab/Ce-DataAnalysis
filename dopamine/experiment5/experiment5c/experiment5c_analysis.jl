using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 194:238
files.id = [
    fill("DA_N2_OP50", length(194:196));
    fill("DA_N2_NGM", length(197:200));
    fill("DA_CB_OP50", length(201:203));
    fill("DA_CB_NGM", length(204:206));
    fill("DA_MT_OP50", length(207:209));
    fill("DA_MT_NGM", length(210:213));
    fill("M9_N2_OP50", length(214:217));
    fill("M9_N2_NGM", length(218:221));
    fill("M9_CB_OP50", length(222:225));
    fill("M9_CB_NGM", length(226:230));
    fill("M9_MT_OP50", length(231:234));
    fill("M9_MT_NGM", length(235:238))
]

deleteat!(files, 8) # did not get data from VID201 --> deleted row for that file



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
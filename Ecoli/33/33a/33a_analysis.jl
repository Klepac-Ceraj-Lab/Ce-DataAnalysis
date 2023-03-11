using CeDataAnalysis
using DataFrames
using CSV



# CREATE DATAFRAME OF FILE NUMBERS AND IDS
files = DataFrame()
files.num = 36:65
files.id = [
    fill("IPTG_N2_BL21", length(36:39));
    fill("IPTG_N2_NGM", length(40:43));
    fill("IPTG_CB_BL21", length(44:47));
    fill("IPTG_CB_NGM", length(48:50));
    fill("H2O_N2_BL21", length(51:53));
    fill("H2O_N2_NGM", length(54:57));
    fill("H2O_CB_BL21", length(58:62));
    fill("H2O_CB_NGM", length(63:65));
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
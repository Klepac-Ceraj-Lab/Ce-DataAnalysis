using DataFrames
using CSV




# LOAD ALL SPEEDS CSVS AND COMBINE INTO ONE DATAFRAME
experimentdir = @__DIR__

speedsa = DataFrame(CSV.File(joinpath(experimentdir, "new11a", "speeds.csv")))
speedsa.experiment = fill(1, length(speedsa.id)) # add experiment column to df

speedsb = DataFrame(CSV.File(joinpath(experimentdir, "new11b", "speeds.csv")))
speedsb.experiment = fill(2, length(speedsb.id))

speedsd = DataFrame(CSV.File(joinpath(experimentdir, "new11d", "speeds.csv")))
speedsd.experiment = fill(3, length(speedsd.id))

speeds = vcat(speedsa, speedsb, speedsd)



# SAVE FINAL DATAFRAME
speedscsv = joinpath(experimentdir, "speeds.csv")

CSV.write(speedscsv, speeds)
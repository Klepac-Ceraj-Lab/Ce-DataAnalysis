using DataFrames
using CSV




# LOAD ALL SPEEDS CSVS AND COMBINE INTO ONE DATAFRAME
experimentdir = @__DIR__

speedsa = DataFrame(CSV.File("./dopamine/experiment5/experiment5a/speeds.csv"))
speedsa.experiment = fill(1, length(speedsa.id)) # add experiment column to df

speedsb = DataFrame(CSV.File("./dopamine/experiment5/experiment5b/speeds.csv"))
speedsb.experiment = fill(2, length(speedsb.id))

speedsc = DataFrame(CSV.File("./dopamine/experiment5/experiment5c/speeds.csv"))
speedsc.experiment = fill(3, length(speedsc.id))

speeds = vcat(speedsa, speedsb, speedsc)



# SAVE FINAL DATAFRAME
speedscsv = joinpath(experimentdir, "speeds.csv")

CSV.write(speedscsv, speeds)
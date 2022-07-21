using DataFrames
using CSV




# LOAD ALL SPEEDS CSVS AND COMBINE INTO ONE DATAFRAME
experimentdir = @__DIR__

speedsb = DataFrame(CSV.File("./dopamine/experiment4/experiment4b/speeds.csv"))
speedsb.experiment = fill(1, length(speedsb.id)) # add experiment column to df

speedse = DataFrame(CSV.File("./dopamine/experiment4/experiment4e/speeds.csv"))
speedse.experiment = fill(2, length(speedse.id))

speedsf = DataFrame(CSV.File("./dopamine/experiment4/experiment4f/speeds.csv"))
speedsf.experiment = fill(3, length(speedsf.id))

speedsh = DataFrame(CSV.File("./dopamine/experiment4/experiment4h/speeds.csv"))
speedsh.experiment = fill(4, length(speedsh.id))

speeds = vcat(speedsb, speedse, speedsf, speedsh)



# SAVE FINAL DATAFRAME
speedshsv = joinpath(experimentdir, "speeds.csv")

CSV.write(speedshsv, speeds)
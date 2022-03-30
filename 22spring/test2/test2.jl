using CSV
using DataFrames
using CategoricalArrays
using GLMakie
using Statistics

# extract relevant data from WormLab Speed file
function extractdata!(df, file::String, id)
    newdf = DataFrame(CSV.File(file, header=5))
    select!(newdf, Not([1,2])) # filters out rows that are not data 
    speeds = [x for x in Matrix(newdf) if !ismissing(x) && x != 0] # convert newDF to vector
    
  
    newdf = DataFrame(id = fill(id, length(speeds)), speed = speeds)
    append!(df, newdf)
    return df
end

# extract data from all files
# for file in datafiles
#     extractdata("./22spring/test2/data/"*file)
# end

##

data = DataFrame()
for f in 45:48
    extractdata!(data, joinpath("./22spring/test2/data/", string(f, "Speed.csv")), "DA_N2")
end

for f in 52:54
    extractdata!(data, joinpath("./22spring/test2/data/", string(f, "Speed.csv")), "M9_N2")
end

for f in 59:64
    extractdata!(data, joinpath("./22spring/test2/data/", string(f, "Speed.csv")), "DA_CB")
end

for f in 70:73
    extractdata!(data, joinpath("./22spring/test2/data/", string(f, "Speed.csv")), "M9_CB")
end

##

data.medium = categorical(map(i-> split(i, '_')[1], data.id))
data.worm = categorical(map(i-> split(i, '_')[2], data.id))
data.id = categorical(data.id, levels=["DA_N2", "M9_N2", "DA_CB", "M9_CB"])

##

# make plot
fig1 = Figure(
)

ax1 = Axis(
    fig1[1,1],
    xlabel = "Conditions",
    ylabel = "Average Speed (um/s)",
)

boxplot!(data.medium, data.speed, group=data.worm)

fig
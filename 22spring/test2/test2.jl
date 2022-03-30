using CSV
using DataFrames
using GLMakie
using Statistics

vid45 = DataFrame(CSV.File("./22spring/test2/data/45Speed.csv"))
delete!(vid45, 1:3) # filters out columns that are not data 
select!(vid45, Not([1,2])) # filters out rows that are not data 
vid45 = vec(Matrix(vid45)) # convert DF to vector
filter!(!ismissing, vid45) # filters out missing
filter!(x->x≠0,vid45) # filters out '0'
# Float64.(vid45)
# convert(Vector{Float64}, vid45)

vid52 = DataFrame(CSV.File("./22spring/test2/data/52Speed.csv"))
delete!(vid52, 1:3) # filters out columns that are not data 
select!(vid52, Not([1,2])) # filters out rows that are not data 
vid52 = vec(Matrix(vid52)) # convert DF to vector
filter!(!ismissing, vid52) # filters out missing
filter!(x->x≠0,vid52) # filters out '0'

# extract relevant data from WormLab Speed file
function extractdata!(df, file::String)
    newdf = DataFrame(CSV.File(file))
    delete!(newdf, 1:3) # filters out columns that are not data 
    select!(newdf, Not([1,2])) # filters out rows that are not data 
    newdf = vec(Matrix(newdf)) # convert newDF to vector
    filter!(!ismissing, newdf) # filters out missing
    filter!(x->x≠0,newdf) # filters out '0'
    
    id = replace(basename(file), r"(\d+)Speed\.csv" => s"\1")
    id = parse(Int, id)
    newdf[!, :id] = fill(id, nrow(newdf))
    append!(df, newdf)
    return df
end

datafiles = readdir("./22spring/test2/data/")

# extract data from all files
# for file in datafiles
#     extractdata("./22spring/test2/data/"*file)
# end

# DA_N2
data45 = extractdata("./22spring/test2/data/45Speed.csv")
data46 = extractdata("./22spring/test2/data/46Speed.csv")
data47 = extractdata("./22spring/test2/data/47Speed.csv")
data48 = extractdata("./22spring/test2/data/48Speed.csv")
DA_N2y = vcat(data45, data46, data47, data48)
DA_N2x = repeat([1], length(DA_N2y))

# M9_N2 x and y values
data52 = extractdata("./22spring/test2/data/52Speed.csv")
data53 = extractdata("./22spring/test2/data/53Speed.csv")
data54 = extractdata("./22spring/test2/data/54Speed.csv")
M9_N2y = vcat(data52, data53, data54)
M9_N2x = repeat([2], length(M9_N2y))

# DA_CB x and y values
data59 = extractdata("./22spring/test2/data/59Speed.csv")
data60 = extractdata("./22spring/test2/data/60Speed.csv")
data61 = extractdata("./22spring/test2/data/61Speed.csv")
data62 = extractdata("./22spring/test2/data/62Speed.csv")
data63 = extractdata("./22spring/test2/data/63Speed.csv")
data64 = extractdata("./22spring/test2/data/64Speed.csv")
DA_CBy = vcat(data59, data60, data61, data62, data63, data64)
DA_CBx = repeat([3], length(DA_CBy))

# M9_CB x and y values
data70 = extractdata("./22spring/test2/data/70Speed.csv")
data71 = extractdata("./22spring/test2/data/71Speed.csv")
data72 = extractdata("./22spring/test2/data/72Speed.csv")
data73 = extractdata("./22spring/test2/data/73Speed.csv")
M9_CBy = vcat(data70, data71, data72, data73)
M9_CBx = repeat([4], length(M9_CBy))

# all x and y values
xs = float(vcat(DA_N2x, M9_N2x, DA_CBx, M9_CBx))
ys = float(vcat(DA_N2y, M9_N2y, DA_CBy, M9_CBy))

# make plot
fig1 = Figure(
)

ax1 = Axis(
    fig1[1,1],
    xlabel = "Conditions",
    xticks = ([1,2,3,4], ["DA_N2", "M9_N2", "DA_CB", "M9_CB"]),
    ylabel = "Average Speed (um/s)",
)

boxplot!(DA_N2x, DA_N2y)


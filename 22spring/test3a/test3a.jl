using CSV
using DataFrames
using CategoricalArrays
using GLMakie
using Statistics
using Distances


# # CALCULATE SPEED FROM DISTANCE

positiondf = DataFrame(CSV.File("./22spring/test3a/data/Position/74Position.csv", header=5)) # import position csv into df

divby1(num) = num%1 == 0
filter!(:Time => divby1, positiondf) # filter df down to position measurements every sec

select!(positiondf, Not([1,2])) # delete Frame and Time columns 

x1 = positiondf[1, "1 x"]
y1 = positiondf[1, "1 y"]
x2 = positiondf[2, "1 x"]
y2 = positiondf[2, "1 y"]
euclidean((x1, y1), (x2, y2)) # calculate distance between 2 pts

track1df = positiondf[:, ["1 x", "1 y"]] # create new df with single track
dropmissing!(track1df) # remove all rows that say missing

# track1matrix = Matrix(track1df) # create matrix from df
# track1vectors = DataFrame()
# for row in eachrow(track1matrix)
#     append!(track1vectors, row)
# end

t1coordinates = DataFrame(coordinate = Vector[])
for row in eachrow(track1df)
    coordinate = (row."1 x", row."1 y")
    println(coordinate)
    append!(t1vectors, coordinate)
end
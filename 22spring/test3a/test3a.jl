using CSV
using DataFrames
using CategoricalArrays
using GLMakie
using Statistics
using Distances


# CALCULATE SPEED/DISTANCE FROM POSITION

df = DataFrame(CSV.File("./22spring/test3a/data/Position/74Position.csv", header=5)) # import position csv into df

divby1(num) = num%1 == 0
filter!(:Time => divby1, df) # filter df down to position measurements every sec

select!(df, Not([:Frame, :Time])) # delete Frame and Time columns 

df.track = map(eachrow(df)) do row
    ceil(Int, findfirst(!ismissing, values(row)) / 2)
end # add column to df with track numbers

df.x = map(eachrow(df)) do row
    coalesce(row[r"\d x"]...) # regex: "\d" = any digit, " " = space, "x" = "x" char
end # add column to df with all x values

df.y = map(eachrow(df)) do row
    coalesce(row[r"\d y"]...)
end # add column to df with all y values

select!(df, [:track, :x, :y]) # only keep new columns :track, :x, :y

df.speed = map(1:nrow(df)) do ri 
    if ri == 1 || df.track[ri] != df.track[ri-1] # if first row in csv or track
        return missing # don't calculate distance
    else # calculate distance between point in row to point in next row
        return euclidean([df.x[ri-1], df.x[ri]], [df.y[ri-1], df.y[ri]]) 
    end
end # add column to df with distances --> since distance is being measured across 1sec, distance = speed

select!(df, [:track, :speed])
dropmissing!(df)
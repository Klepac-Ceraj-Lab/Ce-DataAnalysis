using CSV
using DataFrames
using CategoricalArrays
using GLMakie
using Statistics
using Distances


# CALCULATE SPEED/DISTANCE FROM POSITION

function speed(file)

    df = DataFrame(CSV.File(file, header=5)) # import position csv into df

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

    return df
end



speed74 = speed("./22spring/test3a/data/Position/74Position.csv")



# LOAD TRACKS

function load_tracks!(existingdf, file)
    tracks = DataFrame(CSV.File(file, header=5)) # import CSV to DataFrame

    divby1(num) = num%1 == 0
    filter!(:Time => divby1, tracks) # filter df down to position measurements every sec
    
    select!(tracks, Not([:Frame, :Time])) # delete Frame and Time columns 
    
    ntracks = ncol(tracks) ÷ 2 # count every pair of columns (this is integer division, so the answer stays Int)
    
    for tr in 1:ntracks
        x = collect(skipmissing(tracks[!, 2*tr-1]))
        y = collect(skipmissing(tracks[!, 2*tr]))
        append!(existingdf, DataFrame(track = fill(tr, length(x)),
                                  xpos  = x,
                                  ypos  = y)
        )
    end
    
    return existingdf
end

# load_tracks! test
existingdf = DataFrame() # initiate empty DataFrame

file = "./22spring/test3a/data/Position/75Position.csv"
tracks = DataFrame(CSV.File(file, header=5)) # import CSV to DataFrame

divby1(num) = num%1 == 0
filter!(:Time => divby1, tracks) # filter df down to position measurements every sec

select!(tracks, Not([:Frame, :Time])) # delete Frame and Time columns 

ntracks = ncol(tracks) ÷ 2 # count every pair of columns (this is integer division, so the answer stays Int)

for tr in 1:ntracks
    x = collect(skipmissing(tracks[!, 2*tr-1]))
    y = collect(skipmissing(tracks[!, 2*tr]))
    append!(existingdf, DataFrame(track = fill(tr, length(x)),
                              xpos  = x,
                              ypos  = y)
    )
end

data = DataFrame()
file = "./22spring/test3a/data/Position/75Position.csv"
load_tracks!(data, file)
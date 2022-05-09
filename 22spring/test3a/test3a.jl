using CSV
using DataFrames
using CategoricalArrays
using GLMakie
using Statistics
using Distances



# COMPILE DATAFRAME WITH ALL POSITIONS

function load_tracks!(existingdf, file, id)
    tracks = DataFrame(CSV.File(file, header=5)) # import CSV to DataFrame

    filter!(:Time=> (num-> num % 1 == 0), tracks) # filter df down to position measurements every sec

    select!(tracks, Not([:Frame, :Time])) # delete Frame and Time columns 
    
    ntracks = ncol(tracks) ÷ 2 # count every pair of columns (this is integer division, so the answer stays Int)
    
    for tr in 1:ntracks
        x = collect(skipmissing(tracks[!, 2*tr-1]))
        y = collect(skipmissing(tracks[!, 2*tr]))
        
        if isempty(existingdf) # if there is no data
            tracknum = 1 # start from 1
        elseif id == last(existingdf.id) # if the condition is the same as the last
            tracknum = last(existingdf.track) + 1 # count up from there
        else # if the condition is not the same
            tracknum = 1 # start from 1
        end # assign appropriate track number
    
        append!(existingdf, DataFrame(
            id = fill(id, length(x)),
            track = fill(tracknum, length(x)),
            xpos  = x,
            ypos  = y)
        ) # add x y coordinates positions of each track to existingdf
    end
    
    return existingdf
end



data = DataFrame(id=String[], track=Int[], xpos=Float64[], ypos=Float64[])

for f in 74:77
    load_tracks!(data, joinpath("./22spring/test3a/data/Position/", string(f, "Position.csv")), "DA_N2_OP50")
end

for f in 78:81
    load_tracks!(data, joinpath("./22spring/test3a/data/Position/", string(f, "Position.csv")), "DA_N2_NGM")
end

data



# CALCULATE SPEED/DISTANCE FROM POSITION

function speed(df)
    df.speed = map(1:nrow(df)) do ri 
        if ri == 1 || df.id[ri] != df.id[ri-1] || df.track[ri] != df.track[ri-1] # if first row in dataframe or condition (id) or track
            return missing # don't calculate distance
        else # calculate distance between point in row to point in previous row
            return euclidean([df.xpos[ri-1], df.xpos[ri]], [df.ypos[ri-1], df.ypos[ri]]) 
        end
    end # add column to df with distances --> since distance is being measured across 1sec, distance = speed

    dropmissing!(df) # delete rows with 'missing' speeds

    return df
end

speed(data)
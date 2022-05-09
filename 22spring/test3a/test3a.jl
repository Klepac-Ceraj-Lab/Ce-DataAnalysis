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



# COMPILE DATAFRAME WITH ALL POSITIONS

function load_tracks!(existingdf, file, id)
    tracks = DataFrame(CSV.File(file, header=5)) # import CSV to DataFrame

    divby1(num) = num%1 == 0
    filter!(:Time => divby1, tracks) # filter df down to position measurements every sec
    
    select!(tracks, Not([:Frame, :Time])) # delete Frame and Time columns 
    
    ntracks = ncol(tracks) ÷ 2 # count every pair of columns (this is integer division, so the answer stays Int)
    
    for tr in 1:ntracks
        x = collect(skipmissing(tracks[!, 2*tr-1]))
        y = collect(skipmissing(tracks[!, 2*tr]))
        
        if isempty(existingdf)
            tracknum = 1
        elseif id == last(existingdf.id)
            tracknum = last(existingdf.track) + 1
        else
            tracknum = 1
        end
    
        append!(existingdf, DataFrame(
            id = fill(id, length(x)),
            track = fill(tracknum, length(x)),
            xpos  = x,
            ypos  = y)
        )
    end # add x y coordinates positions of each track to existingdf
    
    return existingdf
end


# function load_tracks(file)
#     df = DataFrame(track=Int[], xpos=Float64[], ypos=Float64[])

#     load_tracks!(df, file)
# end

# function load_tracks(files::Vector{<:AbstractString})
#     longdf = load_tracks(first(files))
#     length(files) == 1 && return longdf
#     for file in files[2:end]
#         load_tracks!(longdf, file)
#     end
#     return longdf
# end

data = DataFrame(id=String[], track=Int[], xpos=Float64[], ypos=Float64[])

load_tracks!(data, "./22spring/test3a/data/Position/74Position.csv", "DA_N2_OP50")
load_tracks!(data, "./22spring/test3a/data/Position/75Position.csv", "DA_N2_OP50")
load_tracks!(data, "./22spring/test3a/data/Position/76Position.csv", "DA_N2_OP50")
load_tracks!(data, "./22spring/test3a/data/Position/77Position.csv", "DA_N2_OP50")

load_tracks!(data, "./22spring/test3a/data/Position/78Position.csv", "DA_N2_NGM")
load_tracks!(data, "./22spring/test3a/data/Position/79Position.csv", "DA_N2_NGM")
load_tracks!(data, "./22spring/test3a/data/Position/80Position.csv", "DA_N2_NGM")
load_tracks!(data, "./22spring/test3a/data/Position/81Position.csv", "DA_N2_NGM")

using CSV
using DataFrames
using CategoricalArrays
using GLMakie
using Statistics
using Distances



# COMPILE DATAFRAME WITH ALL POSITIONS

# TAKE 5 POSITION MEASUREMENTS EVERY SEC -> AVERAGE SPEED ACROSS A SEC
function load_tracks!(existingdf, file, id)
    tracks = DataFrame(CSV.File(file, header=5)) # import CSV to DataFrame

    filter!(:Frame=> (num-> num % 5 == 0), tracks) # filter df down to 5 position measurements every sec

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

for f in 83:85
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "DA_N2_OP50")
end

for f in 86:89
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "DA_N2_NGM")
end

for f in 90:93
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "DA_CB_OP50")
end

for f in 94:96
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "DA_CB_NGM")
end

for f in 97:99
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "DA_MT_OP50")
end

for f in 100:106
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "DA_MT_NGM")
end

for f in 107:110
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "M9_N2_OP50")
end

for f in 111:115
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "M9_N2_NGM")
end

for f in 116:118
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "M9_CB_OP50")
end

for f in 119:120
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "M9_CB_NGM")
end

for f in 121:123
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "M9_MT_OP50")
end

for f in 124:129
    load_tracks!(data, joinpath("./22spring/experiment4a/data/Position/", string(f, "Position.csv")), "M9_MT_NGM")
end



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

speed(data) # calculate speed from position

select!(data, [:id, :track, :speed]) # filter out :xpos and :ypos columns



# AVERAGE 5 MEASUREMENTS TO GET AVERAGE SPEED ACROSS A SEC
speedpersec = DataFrame(id=String[], track=Int[], speed=Float64[])

for row in 5:5:nrow(data)
    if data.id[row] == data.id[row-4] && data.track[row] == data.track[row-4]
        meanspeed = mean([data.speed[row-4], data.speed[row-3], data.speed[row-2], data.speed[row-1], data.speed[row]])
        append!(speedpersec, DataFrame(id = data.id[row], track = data.track[row], speed = meanspeed))
    end
end



# AVERAGE EVERY 5 SPEED/SEC MEASUREMENTS
averagespeeds = DataFrame(id=String[], track=Int[], speed=Float64[])

for row in 5:5:nrow(speedpersec)
    if speedpersec.id[row] == speedpersec.id[row-4] && speedpersec.track[row] == speedpersec.track[row-4]
        averagespeed = mean([speedpersec.speed[row-4], speedpersec.speed[row-3], speedpersec.speed[row-2], speedpersec.speed[row-1], speedpersec.speed[row]])
        append!(averagespeeds, DataFrame(id = speedpersec.id[row], track = speedpersec.track[row], speed = averagespeed))
    end
end



# STATS

# individual track stats
tracks = groupby(averagespeeds, [:id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed, :speed => std => :stdspeed)

# condition stats from individual stats 
conditions = groupby(trackstats, [:id])
conditionstats = combine(conditions, :meanspeed => mean => :meanofmeanspeed, :meanspeed => std => :stdofmeanspeed, :stdspeed => mean => :meanofstdspeed, :stdspeed => std => :stdofstdspeed)

# condition stats from all data
all = groupby(data, [:id])
allstats = combine(all, :speed => mean => :meanspeed, :speed => std => :stdspeed)



# MAKE CATEGORICAL ARRAYS FOR PLOTTING
averagespeeds.medium = categorical(map(i-> split(i, '_')[1], averagespeeds.id))
averagespeeds.worm = categorical(map(i-> split(i, '_')[2], averagespeeds.id))
averagespeeds.bacteria = categorical(map(i-> split(i, '_')[3], averagespeeds.id))
averagespeeds.id = categorical(averagespeeds.id, levels=[ "DA_N2_OP50", "DA_N2_NGM",
                                                        "DA_CB_OP50", "DA_CB_NGM",
                                                        "DA_MT_OP50", "DA_MT_NGM",
                                                        "M9_N2_OP50", "M9_N2_NGM",
                                                        "M9_CB_OP50", "M9_CB_NGM",
                                                        "M9_MT_OP50", "M9_MT_NGM"])

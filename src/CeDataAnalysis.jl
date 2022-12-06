module CeDataAnalysis

# "export" functions / variables that should be accessible when you do `using CeDataAnalysis`
export  load_tracks!,
        distance!,
        speed!,
        averageoverfive,
        conditionstats,
        allstats



using CSV
using DataFrames
using Statistics
using Distances



# CREATE DATAFRAME FROM CSV WITH ALL POSITION DATA
function load_tracks!(existingdf, file, id)
    tracks = CSV.read(file, DataFrame; header=5) # import CSV to DataFrame

    select!(tracks, Not([:Frame, :Time])) # delete Frame and Time columns 
    
    ntracks = ncol(tracks) ÷ 2 # count every pair of columns (this is integer division, so the answer stays Int)
    
    for tr in 1:ntracks
        x = tracks[!, 2*tr-1]
        y = tracks[!, 2*tr]

        start_idx = findfirst(!ismissing, x) # get first non-missing
        end_idx = lastindex(x) - findfirst(!ismissing, reverse(x)) + 1 # get last non-missing

        x = x[start_idx:end_idx] # truncate beginning and end missing values, but leave internal
        y = y[start_idx:end_idx]
        
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



# CALCULATE DISTANCE FROM POSITION (µm/0.2sec)
function distance!(df)
    flag = false
    df.distance = map(1:nrow(df)) do ri 
        if ri == 1 || # if first row in dataframe
           df.id[ri] != df.id[ri-1] || df.track[ri] != df.track[ri-1] || # or condition (id) or track
           ismissing(df.xpos[ri-1]) || ismissing(df.xpos[ri]) # either position is missing
            return missing # don't calculate distance
        else # calculate distance between point in row to point in previous row
            return euclidean((df.xpos[ri-1], df.ypos[ri-1]), (df.xpos[ri], df.ypos[ri]))
        end
    end # add column to df with distances

    dropmissing!(df) # delete rows with 'missing' distances

    # select!(df, [:id, :track, :distance]) # filter out :xpos and :ypos columns

    return df
end



# CALCULATE SPEED FROM DISTANCE
# since distance is being measured across 0.2sec, speed in µm/sec = distance(µm) / 0.2sec
function speed!(df; duration=0.2)
    df.speed = map(1:nrow(df)) do ri 
        return df.distance[ri] / duration
    end # add column to df with speeds

    return df
end



# CALCULATE AVERAGE SPEED ACROSS 5SEC
function averageoverfive(data)
    # AVERAGE 5 MEASUREMENTS TO GET AVERAGE SPEED ACROSS A SEC
    speedpersec = DataFrame(id=String[], track=Int[], speed=Float64[])

    for row in 5:5:nrow(data)
        if data.id[row] == data.id[row-4] && data.track[row] == data.track[row-4]
            meanspeed = mean([data.speed[row-4], data.speed[row-3], data.speed[row-2], data.speed[row-1], data.speed[row]])
            append!(speedpersec, DataFrame(id = data.id[row], track = data.track[row], speed = meanspeed))
        end
    end

    # AVERAGE EVERY 5 SPEED/SEC MEASUREMENTS
    speedperfive = DataFrame(id=String[], track=Int[], speed=Float64[])

    for row in 5:5:nrow(speedpersec)
        if speedpersec.id[row] == speedpersec.id[row-4] && speedpersec.track[row] == speedpersec.track[row-4]
            meanspeed = mean([speedpersec.speed[row-4], speedpersec.speed[row-3], speedpersec.speed[row-2], speedpersec.speed[row-1], speedpersec.speed[row]])
            append!(speedperfive, DataFrame(id = speedpersec.id[row], track = speedpersec.track[row], speed = meanspeed))
        end
    end

    return speedperfive
end



# CALCULATE SUMMARY STATS BY FIRST CALCULATING SUMMARY STATS OF EACH TRACK
function conditionstats(speeds)
    # individual track stats
    tracks = groupby(speeds, [:id, :track])
    trackstats = combine(tracks, :speed => mean => :meanspeed, :speed => std => :stdspeed)

    # condition stats from individual stats 
    conditions = groupby(trackstats, [:id])
    conditionstats = combine(conditions, :meanspeed => mean => :meanofmeanspeed, :meanspeed => std => :stdofmeanspeed, :stdspeed => mean => :meanofstdspeed, :stdspeed => std => :stdofstdspeed)

    return conditionstats
end

# CALCULATE SUMMARY STATS FROM ALL TRACKS
function allstats(speeds)
    # condition stats from all data
    all = groupby(speeds, [:id])
    allstats = combine(all, :speed => mean => :meanspeed, :speed => std => :stdspeed)

    return allstats
end



end
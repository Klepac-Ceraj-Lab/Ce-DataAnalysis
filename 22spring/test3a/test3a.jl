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



# SUMMARY STATS

# individual track stats
tracks = groupby(data, [:id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed, :speed => std => :stdspeed)

# condition stats from individual stats 
conditions = groupby(trackstats, [:id])
conditionstats = combine(conditions, :meanspeed => mean => :meanofmeanspeed, :meanspeed => std => :stdofmeanspeed, :stdspeed => mean => :meanofstdspeed, :stdspeed => std => :stdofstdspeed)

# condition stats from all data
all = groupby(data, [:id])
allstats = combine(all, :speed => mean => :meanspeed, :speed => std => :stdspeed)



# MAKE CATEGORICAL ARRAYS FOR PLOTTING
data.medium = categorical(map(i-> split(i, '_')[1], data.id))
data.worm = categorical(map(i-> split(i, '_')[2], data.id))
data.bacteria = categorical(map(i-> split(i, '_')[3], data.id))
data.id = categorical(data.id, levels=["DA_N2_OP50", "DA_N2_NGM"])



# PLOTS

# violin
fig = Figure(
)

ax = Axis(
    fig[1,1],
    xlabel = "Conditions",
    ylabel = "Average Speed (um/s)",
)

violin!(levelcode.(data.bacteria), data.speed, dodge = levelcode.(data.worm))

# boxplot
fig = Figure(
)

ax = Axis(
    fig[1,1],
    xlabel = "Conditions",
    ylabel = "Average Speed (um/s)",
)

boxplot!(levelcode.(data.bacteria), data.speed, dodge = levelcode.(data.worm))


# ===========================================================================================


# AVERAGE EVERY 5 SPEED MEASUREMENTS

averagespeeds = DataFrame(id=String[], track=Int[], speed=Float64[])

for row in 5:5:nrow(data)
    if data.id[row] == data.id[row-4] && data.track[row] == data.track[row-4]
        averagespeed = mean([data.speed[row-4], data.speed[row-3], data.speed[row-2], data.speed[row-1], data.speed[row]])
        append!(averagespeeds, DataFrame(id = data.id[row], track = data.track[row], speed = averagespeed))
    end
end


# individual track stats
tracks = groupby(averagespeeds, [:id, :track])
trackstats = combine(tracks, :speed => mean => :meanspeed, :speed => std => :stdspeed)

# condition stats from individual stats 
conditions = groupby(trackstats, [:id])
conditionstats = combine(conditions, :meanspeed => mean => :meanofmeanspeed, :meanspeed => std => :stdofmeanspeed, :stdspeed => mean => :meanofstdspeed, :stdspeed => std => :stdofstdspeed)

# condition stats from all data
all = groupby(data, [:id])
allstats = combine(all, :speed => mean => :meanspeed, :speed => std => :stdspeed)


averagespeeds.medium = categorical(map(i-> split(i, '_')[1], averagespeeds.id))
averagespeeds.worm = categorical(map(i-> split(i, '_')[2], averagespeeds.id))
averagespeeds.bacteria = categorical(map(i-> split(i, '_')[3], averagespeeds.id))
averagespeeds.id = categorical(averagespeeds.id, levels=["DA_N2_OP50", "DA_N2_NGM"])


# violin
fig = Figure(
)

ax = Axis(
    fig[1,1],
    xlabel = "Conditions",
    ylabel = "Average Speed (um/s)",
)

violin!(levelcode.(averagespeeds.bacteria), averagespeeds.speed, dodge = levelcode.(averagespeeds.worm))

# boxplot
fig = Figure(
)

ax = Axis(
    fig[1,1],
    xlabel = "Conditions",
    ylabel = "Average Speed (um/s)",
)

boxplot!(levelcode.(averagespeeds.bacteria), averagespeeds.speed, dodge = levelcode.(averagespeeds.worm))


# ===========================================================================================


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

for f in 74:77
    load_tracks!(data, joinpath("./22spring/test3a/data/Position/", string(f, "Position.csv")), "DA_N2_OP50")
end

for f in 78:81
    load_tracks!(data, joinpath("./22spring/test3a/data/Position/", string(f, "Position.csv")), "DA_N2_NGM")
end

speed(data) # calculate speed from position

select!(data, [:id, :track, :speed]) # filter out :xpos and :ypos columns


speedpersec = DataFrame(id=String[], track=Int[], speed=Float64[])

for row in 5:5:nrow(data)
    if data.id[row] == data.id[row-4] && data.track[row] == data.track[row-4]
        meanspeed = mean([data.speed[row-4], data.speed[row-3], data.speed[row-2], data.speed[row-1], data.speed[row]])
        append!(speedpersec, DataFrame(id = data.id[row], track = data.track[row], speed = meanspeed))
    end
end # average 5 measurements to get average speed across a sec

averagespeeds = DataFrame(id=String[], track=Int[], speed=Float64[])

for row in 5:5:nrow(speedpersec)
    if speedpersec.id[row] == speedpersec.id[row-4] && speedpersec.track[row] == speedpersec.track[row-4]
        averagespeed = mean([speedpersec.speed[row-4], speedpersec.speed[row-3], speedpersec.speed[row-2], speedpersec.speed[row-1], speedpersec.speed[row]])
        append!(averagespeeds, DataFrame(id = speedpersec.id[row], track = speedpersec.track[row], speed = averagespeed))
    end
end

averagespeeds

# do the same summary stat calculations and plotting as above (under AVERAGE EVERY 5 SPEED MEASUREMENTS)
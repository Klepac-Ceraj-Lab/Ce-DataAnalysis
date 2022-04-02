using CSV
using DataFrames
using CategoricalArrays
using GLMakie
using Statistics

# EXTRACT DATA

# extract relevant data from WormLab Speed file into DF
# id = condition (worm strain, doapmine presecne, E. coli prescence)
# track = track number
# speed = instantaneous speed of worm
function extractdata!(df, file::String, id)
    newdf = DataFrame(CSV.File(file, header=5))
    select!(newdf, Not([1,2])) # filters out columns that are not relevant data

    if isempty(df)
        tracknum = 1
    elseif id == last(data.id)
        tracknum = last(data.track) + 1
    else
        tracknum = 1
    end

    for col in names(newdf)
        track = abs.([x for x in newdf[:, col] if !ismissing(x) && x != 0])
        append!(df, DataFrame(id = fill(id, length(track)), track = fill(tracknum, length(track)), speed = track))
        tracknum += 1
    end
      
    return df
end

# extract and compile all data into one DF

data = DataFrame()

for f in 45:48
    extractdata!(data, joinpath("./22spring/test2/data/", string(f, "Speed.csv")), "DA_N2")
end

for f in 52:54
    extractdata!(data, joinpath("./22spring/test2/data/", string(f, "Speed.csv")), "DA_CB")
end

for f in 59:64
    extractdata!(data, joinpath("./22spring/test2/data/", string(f, "Speed.csv")), "M9_N2")
end

for f in 70:73
    extractdata!(data, joinpath("./22spring/test2/data/", string(f, "Speed.csv")), "M9_CB")
end

# make categorical arrays for plotting
data.medium = categorical(map(i-> split(i, '_')[1], data.id))
data.worm = categorical(map(i-> split(i, '_')[2], data.id))
data.id = categorical(data.id, levels=["DA_N2", "DA_CB", "M9_N2", "M9_CB"])




# SUMMARY STATS

# individual track stats
tracks = groupby(data, [:id, :track])
trackstats = combine(tracks, :speed => mean => :mean, :speed => std => :std)

# condition stats from individual stats 
conditions = groupby(trackstats, [:id])
conditionstats = combine(conditions, :mean => mean => :meanofmean, :std => mean => :stdofmean, :mean => std => :meanofstd, :std => std => :stdofstd)

# condition stats from all data
all = groupby(data, [:id])
allstats = combine(all, :speed => mean => :mean, :speed => std => :std)



# PLOTS

# boxplot
fig = Figure(
)

ax = Axis(
    fig[1,1],
    xlabel = "Conditions",
    ylabel = "Average Speed (um/s)",
)

boxplot!(levelcode.(data.medium), data.speed, dodge = levelcode.(data.worm))

# violin plot
fig = Figure(
)

ax = Axis(
    fig[1,1],
    xlabel = "Conditions",
    ylabel = "Average Speed (um/s)",
)

violin!(levelcode.(data.medium), data.speed, dodge = levelcode.(data.worm))

# log histogram
DA_N2data = DataFrame()
for f in 45:48
    extractdata!(DA_N2data, joinpath("./22spring/test2/data/", string(f, "Speed.csv")), "DA_N2")
end
fig = Figure(
)
ax = Axis(
    fig[1,1],
    xlabel = "Log Average Speed (um/s)",
    title = "DA_N2",
)
hist!(log.(DA_N2data.speed)) # log transform data

# log boxplot
fig = Figure(
)

ax = Axis(
    fig[1,1],
    xlabel = "Conditions",
    ylabel = "Log Average Speed (um/s)",
)

boxplot!(levelcode.(data.medium), log.(data.speed), dodge = levelcode.(data.worm))

# log violin
fig = Figure(
)

ax = Axis(
    fig[1,1],
    xlabel = "Conditions",
    ylabel = "Log Average Speed (um/s)",
)

violin!(levelcode.(data.medium), log.(data.speed), dodge = levelcode.(data.worm))

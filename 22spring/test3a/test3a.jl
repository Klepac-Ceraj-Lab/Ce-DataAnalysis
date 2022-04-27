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

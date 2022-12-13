using CSV
using DataFrames
using Statistics
using Distances



existingdf = DataFrame(id=String[], track=Int[], xpos=Any[], ypos=Any[])
id = "blah"

tracks = CSV.read("/Users/anika/Desktop/Ce-DataAnalysis/dopamine_BL21/new11/test.csv", DataFrame; header=5) # import CSV to DataFrame

select!(tracks, Not([:Frame, :Time]))

ntracks = ncol(tracks) ÷ 2

for tr in 1:ntracks
    x = tracks[!, 2*tr-1]
    y = tracks[!, 2*tr]
        
    start_idx = findfirst(!ismissing, x) # get first non-missing
    end_idx = findlast(!ismissing, x) # get last non-missing
       
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

existingdf
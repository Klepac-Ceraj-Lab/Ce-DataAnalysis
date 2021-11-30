using CSV
using DataFrames
using GLMakie
using Statistics

# make DF from CSV
df = CSV.read("testresults.csv", DataFrame)

# tracks that are actually worms (from `3 labels.avi`)
#   worm 1: 3, 4, 9, 13, 15, 20, 24, 34, 39
#   worm 2: 41, 43, 45

# make new DF with just worm tracks
filterdf = filter(row -> row.avgSpeed > .132, df)
# doesn't work as well as I want it to bc it needs to be very accurate 
# to separate worm measurements from background measurements

# manually make new DF for each worm
worm1 = df[[3, 4, 9, 13, 15, 20, 24, 34, 39], :]
worm2 = df[[41, 43, 45], :]

# calculate mean and std Speed for each worm
mean1 = mean(worm1.avgSpeed)
std1 = std(worm1.avgSpeed)
mean2 = mean(worm2.avgSpeed)
std2 = std(worm2.avgSpeed)

# consolidate data into matrices to plot
worms = [1,2]
means = [mean1, mean2]
stds = [std1, std2]

# make figure
fig = Figure(
    )

ax = Axis(
    fig[1,1],
    xticks = ([1,2],["Worm 1","Worm 2"]),
    ylabel = "Average Speed (mm/s)",
)

barplot!(ax, worms, means)
errorbars!(worms, means, stds, whiskerwidth = 50)

# save figure
save("testfigure.png", fig)
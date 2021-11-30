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

# make barplot
fig1 = Figure(
)

ax1 = Axis(
    fig1[1,1],
    xticks = ([1,2],["Worm 1","Worm 2"]),
    ylabel = "Average Speed (mm/s)",
)

barplot!(ax1, worms, means)
errorbars!(worms, means, stds, whiskerwidth = 50)

# consolidate data for boxplot
x1 = repeat([1],length(worm1.avgSpeed))
y1 = worm1.avgSpeed
x2 = repeat([2],length(worm2.avgSpeed))
y2 = worm2.avgSpeed

# make boxplot
fig2 = Figure(
)

ax2 = Axis(
    fig2[1,1],
    xticks = ([1,2],["Worm 1","Worm 2"]),
    ylabel = "Average Speed (mm/s)",
)

boxplot!(ax2, x1, y1)
boxplot!(ax2, x2, y2)

# save figures
save("testbarplot.png", fig1)
save("testboxplot.png", fig2)
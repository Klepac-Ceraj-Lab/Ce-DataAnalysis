using CSV
using DataFrames
using GLMakie
using Statistics

# make DF from CSV
df = CSV.read("./22spring/test1-data.csv", DataFrame)

# make new dfs with specific data
speed = df[:, ["0-20s", "20-40s", "40-60s"]]
time = df[:, ["Forwards", "Backwards", "Not"]]
changes = df[:, "# Direction Changes"]

# calculate summary stats
# mean and std for each row/worm
indiv_means = mean.(eachrow(speed))
indiv_stds = std.(eachrow(speed))
# mean and std for time in each dir
time_means = mean.(eachcol(time))
time_stds = std.(eachcol(time))
# mean and std for dir changes
changes_means = [mean(changes)]
changes_stds = [std(changes)]

# histogram of instantaneous speeds

inst_speeds = vec(Matrix(speed))

fig1 = Figure(
)

ax1 = Axis(
    fig1[1,1],
    xlabel = "'Instantaneous' Speed (body bends/20s)",
    ylabel = "# of Occurances",
)

hist!(ax1, inst_speeds)

save("22spring/test1-insthist.png", fig1)

# histogram of average speeds
fig2 = Figure(
)

ax2 = Axis(
    fig2[1,1],
    xlabel = "Average Speed (body bends/20s)",
    ylabel = "# of Occurances",
)

hist!(ax2, indiv_means)

save("22spring/test1-avghist.png", fig2)

# scatterplot
fig3 = Figure(
)

ax3 = Axis(
    fig3[1,1],
    xlabel = "Average Speed (body bends/20s)",
    ylabel = "SD Speed (body bends/20s)",
)

scatter!(ax3, indiv_means, indiv_stds)

save("22spring/test1-scatter.png", fig3)


# barplot of time spent moving

directions = [1,2,3]

fig4 = Figure(
)

ax4 = Axis(
    fig4[1,1],
    xlabel = "Direction of Movement",
    xticks = ([1,2,3],["Fowards","Backwards", "Not"]),
    ylabel = "Time Spent Moving (s)",
)

barplot!(ax4, directions, time_means)
errorbars!(directions, time_means, time_stds, whiskerwidth = 50)

save("22spring/test1-timebar.png", fig4)


# barplot of direction changes

strains = [1]

fig5 = Figure(
)

ax5 = Axis(
    fig5[1,1],
    xlabel = "Strains",
    xticks = ([1], ["MT"]),
    ylabel = "# Direction Changes",
)

barplot!(ax5, strains, changes_means)
errorbars!(strains, changes_means, changes_stds, whiskerwidth = 50)

save("22spring/test1-dirbar.png", fig5)

# boxplot of average speeds

strains = repeat([1], length(indiv_means))

fig6 = Figure(
)

ax6 = Axis(
    fig6[1,1],
    xlabel = "Strains",
    xticks = ([1], ["MT"]),
    ylabel = "Average Speed (# body bends/20sec)",
)

boxplot!(strains, indiv_means)

save("22spring/test1-avgbox.png", fig6)

# boxplot of instantaneous speeds

strains = repeat([1], length(inst_speeds))

fig7 = Figure(
)

ax7 = Axis(
    fig7[1,1],
    xlabel = "Strains",
    xticks = ([1], ["MT"]),
    ylabel = "'Instantaneous' Speed (# body bends/20sec)",
)

boxplot!(strains, inst_speeds)

save("22spring/test1-instbox.png", fig7)

# violin plot of instantaneous speeds

strains = repeat([1], length(inst_speeds))

fig8 = Figure(
)

ax8 = Axis(
    fig8[1,1],
    xlabel = "Strains",
    xticks = ([1], ["MT"]),
    ylabel = "'Instantaneous' Speed (# body bends/20sec)",
)

violin!(strains, inst_speeds)

save("22spring/test1-instviolin.png", fig8)

# violin plot of average speeds

strains = repeat([1], length(indiv_means))

fig9 = Figure(
)

ax9 = Axis(
    fig9[1,1],
    xlabel = "Strains",
    xticks = ([1], ["MT"]),
    ylabel = "Average Speed (# body bends/20sec)",
)

violin!(strains, indiv_means)

save("22spring/test1-avgviolin.png", fig9)

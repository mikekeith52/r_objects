# Create a mode function
getmode <- function(v) {
   uniqv <- unique(v)
   uniqv[which.max(tabulate(match(v, uniqv)))]
}

# number of lottery simulations to run
sim = 10000
# Number of draws the player gets
draws = 50 # This is for regular lottery
# Number of numbers to match by drawing
matches = 20 # This is for regular lottery

# Set random seed for replicable results
set.seed(20)

# Sample winning 20 numbers and store results in dataframe
winners <- data.frame(matrix(0, nrow = sim, ncol = matches))
for (i in 1:sim){
 winners[i,] <- sort(sample(seq(0,99), matches)) # sort so it's in order
}

# Get an idea of the distribution of the sorted winning vectors
means <- 0
medians <- 0
mins <- 0
maxes <- 0
sds <- 0
vars <- 0
for (i in 1:matches){
  means[i] <- mean(winners[[i]])
  medians[i] <- median(winners[[i]])
  mins[i] <- min(winners[[i]])
  maxes[i] <- max(winners[[i]])
  sds[i] <- sd(winners[[i]])
  vars[i] <- sds[i]^2
}

# View distributions
means
medians
mins
maxes
sds
vars

# Winnig strategy could be to get the unique mins, maxes, and then a random
# draw of the remaining numbers based on medians of winning vectors

# To do this, call tidyverse, and create a not_in operator
library(tidyverse)
`%not_in%` <- purrr::negate(`%in%`)

# Show how many draws will be left after accounting for the unique set of maxes and mins
remaining <- draws - length(unique(c(maxes, mins)))

# Make the remaning draws from the medians of the winning vectors
last <- sample(subset(medians, medians %not_in% unique(c(mins, maxes))), min(matches, remaining))

# This could be a winner
winning_draws <- unique(sort(c(mins, maxes, last)))

# Call the winning set
winning_draws

# Another strategy could be to make draws of 50 from each winning vector and take
# the averages of these 50-length draws, although I think this skews the draw
# toward the middle of the distribution, without accounting for the 
# possible mins/maxes

# Create dataframe of winning draws for each winning vector
draw <- data.frame(matrix(0, nrow = sim, ncol = draws))
for (i in 1:sim){
  draw[i,] <- c(winners[i,], sample(subset(seq(0, 99), 
                                         seq(0,99) %not_in% winners[i,]), 
                                         30))
  draw[i,] <- sort(draw[i,])
}

# Take mean, median, mode of simulated winning draws for optimmal draw
pick_means <- 0
pick_medians <- 0
pick_modes <- 0
for (i in 1:draws){
  pick_means[i] <- as.integer(round(mean(draw[[i]]), 0))
  pick_medians[i] <- as.integer(median(draw[[i]]))
  pick_modes[i] <- getmode(draw[[i]])
}

# Choose means - it doesn't repeat
pick_means

# View the others
pick_medians
pick_modes

# The other strat is to just pick the 50 most common integers from the winning draws
draws_concat <- as.integer(draw[, 1])
for (i in 2:ncol(draw)){
  draws_concat <- c(draws_concat, as.integer(draw[, i]))
}

# View distribution
hist(draws_concat)
mean(draws_concat)
median(draws_concat)
getmode(draws_concat)

# Just for curiosity, do the same for the orignal numbers - now this is completely random
winners_concat <- as.integer(winners[, 1])
for (i in 2:ncol(winners)){
  winners_concat <- c(winners_concat, as.integer(winners[, i]))
}

# View histograms side-by-side
par(mfrow = c(1, 2))
hist(winners_concat, xlab = 'Draw Value', main = 'Winning Vectors', 
  probability = T, col = 'light blue')
lines(density(winners_concat))
hist(draws_concat, xlab = 'Draw Value', main = 'Winning Draws', 
  probability = T, col = 'light green')
lines(density(winners_concat))
# Look pretty much the same

# View distributions
mean(winners_concat)
median(winners_concat)
getmode(winners_concat)

# Make a dataframe with every unique value and how often it was drawn in a winning vector
most_common <- data.frame(table(draws_concat))
# Order by Freq desc
most_common <- most_common[order(most_common$Freq, decreasing = T), ]

# Change relevant column to integer form so it's easier to read later
# Factors have to be characters first then integers
most_common_draws <- as.integer(as.character(most_common$draws_concat))

# Take the first 50 elements of the vector
mode_draws <- sort(most_common_draws[1:50])

# Whichever feels better, go with that
pick_means # Might be more likely to get the consolidation prizes -- 15:19
winning_draws # More robust in capturing winning numbers on the margins
mode_draws # Kinda random, but I like to think there's method to it

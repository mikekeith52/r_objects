# Create simple, example dataframe
df <- data.frame(
  patients = c(1, 1, 1, 2, 2, 3, 3, 3, 3, 3), # unique identifier
  time = c(1, 5, 6, 2, 3, 1, 2, 6, 7, 8)      # this would usually be a date
)

# data is already sorted, but if it weren't, sorting would look like this
df <- df[order(df$patients, df$time),]

# view output
head(df, 10)

## Solution:
# First, get a count of how many total visits from each patient
patient_count <- data.frame(table(df$patients)) # This will be referenced in the following loop

# Create visit number minimum -- every patient visits at least once in this example
df$visit_number <- 1
# Loop through each patient
for (i in 1:nrow(patient_count)) { # loops through number of patients, not rows in df
  df$visit_number[(min(which(df$patients == patient_count[[1]][i]))):
  # finds where the unique ids are equal in the two dataframes
  ((max(which(df$patients == patient_count[[1]][i]))))] <-
    seq(1, patient_count[[2]][i], 1) # count up from 1 to total number of visits
}

# Output is exactly what we wanted
df


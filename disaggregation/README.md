# disaggregation_R
How to disaggregate a count in a dataset by a unique id in R

During a project completed at Florida State, I had to figure out a way to count the number of doctor's visits for 30,000 unique patients. For example, if patient 1 is in the dataset 5 times, I needed a count from 1 to 5, and this needed to be repeated for each patient. I searched online for a solution on R, but realized that no one has a good way to do this. And especially without importing several libraries and packages. I thought of my own solution on base R and am sharing the script in this repository so it can be of use to someone else.

The weaknesses of this solution are that it is not straightforward to read and it takes a long time to run on big datasets. It will work for very large datasets though.

Once a count of the visits is given, then other operations can be facilitated, such as a running total of dollars spent until the patient's last visit, etc.

# Data format
For this solution to work, the data needs to be formatted such that there are several unique individuals (patients/customers/etc.) all tagged with their own unique marker. There needs to be some indication of time/sequence in the data so that it can be sorted correctly (otherwise, the counts are randomly applied). That's it. The rest can be done in base R.

# Solution

```R
# Create simple, example dataframe
df <- data.frame(
  patients = c(1, 1, 1, 2, 2, 3, 3, 3, 3, 3), # unique identifier
  time = c(1, 5, 6, 2, 3, 1, 2, 6, 7, 8)      # this would usually be a date
)

# data is already sorted, but if it weren't, sorting would look like this
df <- df[order(df$patients, df$time),]

# view output
head(df, 10)

   patients time
1         1    1
2         1    5
3         1    6
4         2    2
5         2    3
6         3    1
7         3    2
8         3    6
9         3    7
10        3    8

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

   patients time visit_number
1         1    1            1
2         1    5            2
3         1    6            3
4         2    2            1
5         2    3            2
6         3    1            1
7         3    2            2
8         3    6            3
9         3    7            4
10        3    8            5
```

# Read panel data - from GitHub BuzzFeed
Master_DF <- read.csv("https://raw.githubusercontent.com/mikekeith52/nics-firearm-background-checks/master/data/nics-firearm-background-checks.csv")

# Get rid of observations that are not states (sorry Washington DC)
Master_DF <- subset(Master_DF, state %in% state.name)

# Install packages
install.packages(c('quantmod', 'zoo'))

# Paste each state abbreviation to the symbol ending in FRED
series_un <- paste0(state.abb, "UR") # unemployment rate per state
series_ci <- paste0(state.abb, "PHCI") # economic coincidental indicator by state

# Call the package
library(quantmod)

# Place string vectors in getSymbols() function
getSymbols(series_un,src="FRED", auto.assign=T) # Returns a vector of strings -- creates xts objects in local envir
getSymbols(series_ci,src="FRED", auto.assign=T) # Returns a vector of strings -- creates xts objects in local envir

# Write a list which will become populated with the time series in df form
UR_list <- list()
# Manually write each xts into a list and loop through
for (series in list(ALUR, AKUR, AZUR, ARUR, CAUR, COUR, CTUR, DEUR, FLUR, GAUR,
            HIUR, IDUR, ILUR, INUR, IAUR, KSUR, KYUR, LAUR, MEUR, MDUR,
            MAUR, MIUR, MNUR, MSUR, MOUR, MTUR, NEUR, NVUR, NHUR, NJUR,
            NMUR, NYUR, NCUR, NDUR, OHUR, OKUR, ORUR, PAUR, RIUR, SCUR,
            SDUR, TNUR, TXUR, UTUR, VTUR, VAUR, WAUR, WVUR, WIUR, WYUR)){
  UR_list[[which(series_un==ls(series))]] <- 
                             data.frame(zoo(series), # convert to zoo then to df
                             date=index(zoo(series)),# date converted from index (default in zoo) to string var
                             state=state.name[which(series_un==ls(series))], # create state var for matching
                             series=series_un[which(series_un==ls(series))]) # name the series for keeping track
}

# Create an empty dataframe to loop through UR_list and combine files
UR_series <- data.frame()
for (i in 1:length(UR_list)){
  colnames(UR_list[[i]]) <- c("UR", "date", "state", "series") # third column varies by state in each df--needs to be all the same
                                                               # this is also why we created the extra variables to keep track
  UR_series <- rbind(UR_series, UR_list[[i]])
}

# View progress
head(UR_series)

# Repeat for other series

# Concatenate vars to match back to master dataframe
UR_series$match <- paste0(substr(UR_series$date,1,7),"-",UR_series$state)

# Create an identical variable in the master df
Master_DF$match <- paste0(Master_DF$month, "-", Master_DF$state)

# Match back
Master_DF$UR <- UR_series$UR[match(Master_DF$match, UR_series$match)]

# See if it worked
head(Master_DF) ; tail(Master_DF)

# Quantmod Library From R to match statewide economic indicators to a panel dataframe

I recently undertook a project where I needed to download several time series for 50 individual states from the St. Louis Federal Reserve (FRED) website and match back to a master panel dataset. This was not easy to figure out--I could not find an example like this online so I had to come up with my own solution. I did not want to download data to my local machine--rather I would ideally keep all data floating in my local R environment. I also wanted to make use of the ```getSymbols()``` function from the ```quantmod``` package on R, which provides an easy way to download time series data from various websites, including Yahoo finance and FRED. 
```R
    # Paste each state abbreviation to the symbol ending in FRED
    series_un <- paste0(state.abb, "UR") # unemployment rate per state
    series_ci <- paste0(state.abb, "PHCI") # economic coincidental indicator by state

    # Call the package
    library(quantmod)
    # Place string vectors in getSymbols() function
    getSymbols(series_un, src="FRED", auto.assign=T) # Returns a vector of strings -- 
                                                     # creates xts objects in local envir

```
Luckily, FRED keeps a logically intuitive data-keeping system for data where series are available for all states. It is, from every example I've seen, the abbreviation of the state in question concatenated with the name of the series. For example, the unemployment-rate series for California is CAUR. This made creating and looping through string vectors easy.

The hard part was accessing the data once it had been downloaded. ```getSymbols()``` places extended time series (xts) objects in your local environment (with auto.assign set to TRUE) that have the same call symbol as the series written on FRED (CAUR from FRED is called by ```CAUR``` on R). Any attempt I made to form a vector of series without writing in the symbols to a list manually failed--any automated process I tried attempted to loop through a series of strings. Putting the function itself inside a loop also failed--the ```getSymbols()``` function creates the xts objects and stores them in the environment, but it returns a vector of strings.
```R
getSymbols(series_ci, src="FRED", auto.assign=T) # Returns a vector of strings -- 
                                                     # creates xts objects in local envir
```
```> [1] "ALPHCI" "AKPHCI" "AZPHCI" "ARPHCI" "CAPHCI" "COPHCI" "CTPHCI" "DEPHCI" "FLPHCI" "GAPHCI" "HIPHCI" "IDPHCI" "ILPHCI" "INPHCI" "IAPHCI" "KSPHCI" "KYPHCI" "LAPHCI" "MEPHCI" "MDPHCI" "MAPHCI" "MIPHCI" "MNPHCI" "MSPHCI" "MOPHCI" "MTPHCI" "NEPHCI" "NVPHCI" "NHPHCI" "NJPHCI" "NMPHCI" "NYPHCI" "NCPHCI" "NDPHCI" "OHPHCI" "OKPHCI" "ORPHCI" "PAPHCI" "RIPHCI" "SCPHCI" "SDPHCI" "TNPHCI" "TXPHCI" "UTPHCI" "VTPHCI" "VAPHCI" "WAPHCI" "WVPHCI" "WIPHCI" "WYPHCI"```

The solution I settled on was to simply write the series manually into a list and loop though them that way. Once done, the xts objects were easily converted into zoo objects using the ```zoo``` package, which then easily converted to dataframes. Matching them to the master panel dataframe was afterward simple.
```R
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
```
    
My solution works well and is relatively straighforward. It does involve some tedium--writing each series into a list manually, but overall, it works very well.


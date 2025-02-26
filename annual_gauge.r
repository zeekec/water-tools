# download and summarize annual flow at any gauge
# tutorial here: https://owi.usgs.gov/R/dataRetrieval.html#1


library(dataRetrieval)
library(tidyverse)
library(lubridate)

#get gauge number
siteNo <- readline(prompt="Enter a gauge number: ")

#siteNo <- "08330000"

# get station metadata
gauge_meta <- readNWISsite(siteNo)


# reasonable start date
startDate <- "1895-02-01"
endDate <- Sys.Date()

# statistics of interest - this is mean daily discharge
pCode <- "00060"
statCd <- "00003"

# retrieve data
gauge <- as_tibble(gauge <- readNWISdv(siteNo, pCode, startDate, endDate,
                    statCd))
# use pipes to rename flow variable, select ones we need, and
# add the year
startdate <- paste("annual flow\nUSGS gauge",
                   gauge_meta$site_no,
                   "\nData series start date: ",
                   gauge_daily$Date[1])
gauge_daily <- gauge %>%
  rename(flow = X_00060_00003) %>%
  select(Date, flow) %>%
  mutate(year=year(Date)) %>%
  filter(year < 2022)

# create annual average flows
# the *724 part converts cfs to af per year
gauge_annual <- summarize(group_by(gauge_daily, year), annual_flow=mean(flow)*724)

# plot average annual flows
p <- ggplot(gauge_annual, aes(year, annual_flow/1000)) +
  geom_line(data=gauge_annual, aes(x=year, y=mean(gauge_annual$annual_flow/1000)), colour="brown", size=0.5) +
  # geom_line(data=gauge_annual, aes(x=year, y=median(gauge_annual$annual_flow)), colour="red", size=0.5) +
  geom_bar(stat="identity") +
  ylab("acre feet") +
  xlab("Data: USGS; graph by John Fleck, University of New Mexico Water Resources Program") +
  ggtitle(gauge_meta$station_nm, subtitle="annual flow") +
  annotate("text", x=2023, y=mean(gauge_annual$annual_flow/1000), label="mean", size=3) +
  # annotate("text", x=2020, y=median(gauge_annual$annual_flow), label="median", size=3) +
  labs(title=gauge_meta$station_nm,
       subtitle=startdate,
       x = "year",
       y = "thousand acre feet",
       caption = "Data: USGS\ngraph: University of New Mexico Water Resources Program
       code: https://github.com/johnrfleck/water-tools") +
  theme(strip.text = element_text(face = "bold", size = 8))
print(p)

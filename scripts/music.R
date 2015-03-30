#                                         o8o            
#                                         `"'            
# ooo. .oo.  .oo.   oooo  oooo   .oooo.o oooo   .ooooo.  
# `888P"Y88bP"Y88b  `888  `888  d88(  "8 `888  d88' `"Y8 
#  888   888   888   888   888  `"Y88b.   888  888       
#  888   888   888   888   888  o.  )88b  888  888   .o8 
# o888o o888o o888o  `V88V"V8P' 8""888P' o888o `Y8bod8P' 

#           oooo                                                         
#           `888                                                         
#  .ooooo.   888   .ooooo.   .oooo.   ooo. .oo.   oooo  oooo  oo.ooooo.  
# d88' `"Y8  888  d88' `88b `P  )88b  `888P"Y88b  `888  `888   888' `88b 
# 888        888  888ooo888  .oP"888   888   888   888   888   888   888 
# 888   .o8  888  888    .o d8(  888   888   888   888   888   888   888 
# `Y8bod8P' o888o `Y8bod8P' `Y888""8o o888o o888o  `V88V"V8P'  888bod8P' 
#                                                              888       
#                                                              o888o      

library(ggplot2)
library(scales)
library(lubridate) # to extract components of time/date easily
library(plyr) # so we can use rbind.fill to merge datasets of different col lengths but same col names
library(grid) # so I can use unit()

setwd("~/persanalytics/")

# load huge file of all scrobbled tracks, tag it with s
scrobbles <- read.table("data/lastfm/data/scrobbles.tsv", sep = "\t", header = TRUE)
scrobbles$type <- "s"

# load file with loved tracks, tag it with l
loved <- read.table("data/lastfm/data/loved.tsv", sep = "\t", header = TRUE)
loved$type <- "l"

# merge the two files
music <- rbind.fill(scrobbles, loved)

# do some time and date formatting
music$detTime <- as.POSIXct(music$unixtime, tz = "EST", origin = "1970-01-01")
music$ISO.time <- as.POSIXct(music$ISO.time, tz = "EST", origin = "1970-01-01")

music$hour <- hour(music$detTime) # extract hour component
music$min <- minute(music$detTime) # extract minute component
music$wday <- wday(music$detTime, label=TRUE) # extract day of the week

music$ytime <- paste(music$hour, music$min, sep=":") # create hh:mm
music$ytime <- as.POSIXct(strptime(music$ytime, format="%H:%M")) # convert to POSIX

## data for tracks per day
dateList <- seq(as.Date(music$ISO.time[1]), as.Date(music$ISO.time[length(music$ISO.time)]), "days")

# produce days from beginning of collection to end
dateList <- as.data.frame(dateList)
colnames(dateList) <- "ISO.time"

music$play <- 1 # one play count per song/row
music.rawAggregate <- aggregate(play ~ ISO.time, data=music, sum) # play counts per day
music.rawAggregate$ISO.time <- paste(year(music.rawAggregate$ISO.time),
                                     month(music.rawAggregate$ISO.time),
                                     mday(music.rawAggregate$ISO.time),
                                     sep="-")

music.rawAggregate$ISO.time <- as.Date(music.rawAggregate$ISO.time, "%Y-%m-%d")

music.perday <- merge(dateList, music.rawAggregate, by="ISO.time", all=TRUE)
music.perday$play[is.na(music.perday$play)] <- 0
music.perday$ISO.time <- as.POSIXct(strptime(music.perday$ISO.time, "%Y-%m-%d"))

#            oooo                .   
#            `888              .o8   
# oo.ooooo.   888   .ooooo.  .o888oo 
#  888' `88b  888  d88' `88b   888   
#  888   888  888  888   888   888   
#  888   888  888  888   888   888 . 
#  888bod8P' o888o `Y8bod8P'   "888" 
#  888                               
# o888o                              

# all scrobbed tracks

png("plots/musicAll.png", width = 900)

music.splot <- ggplot(subset(music, type == "s") , aes(x = ISO.time, y = ytime)) +
  geom_point(size = .75, color = "purple", alpha = .8) +
  geom_point(data = subset(music, type == "l"), aes(x = ISO.time, y = ytime), color = "black") +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_datetime(breaks = date_breaks("4 month"), 
                   labels = date_format("%Y/%m")) +
  scale_y_datetime(breaks = date_breaks("1 hour"), 
                   labels = date_format("%H:%M"),
                   expand = c(0,60)) +
  xlab("Time (year/month)") +
  ylab("Time in day") +
  ggtitle("All scrobbled tracks")

print(music.splot)
dev.off()

png("plots/musicScrobbles.png", width = 900)

music.splot <- ggplot(subset(music, type == "s") , aes(x = ISO.time, y = ytime)) +
  geom_point(size = .75, color = "purple", alpha = .8) +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_datetime(breaks = date_breaks("4 month"), 
                   labels = date_format("%Y/%m")) +
  scale_y_datetime(breaks = date_breaks("1 hour"), 
                   labels = date_format("%H:%M"),
                   expand = c(0,60)) +
  xlab("Time (year/month)") +
  ylab("Time in day") +
  ggtitle("All scrobbled tracks")

print(music.splot)
dev.off()

# just loved tracks

png("plots/musicLoved.png", width = 900)

music.lplot <- ggplot(subset(music, type == "l"), aes(x = ISO.time, y = ytime)) +
  geom_point(color = "red", alpha = .8, size =  1.5) +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_datetime(breaks = date_breaks("4 month"), 
                   labels = date_format("%b %Y")) +
  scale_y_datetime(breaks = date_breaks("1 hour"), 
                   labels = date_format("%H:%M"),
                   expand = c(0,60)) +
  xlab("Time (year/month)") +
  ylab("Time in day") +
  ggtitle("Loved tracks")

print(music.lplot)
dev.off()

# Polar plot by day of week

png("plots/musicByDayOfWeek.png", width = 900)

# find min and max for legend
byDayOfWeek <- aggregate(play ~ wday, data = music, sum)
shortestDay <- signif(min(byDayOfWeek$play), 2)
longestDay <- signif(max(byDayOfWeek$play), 2)

music.polarPlot <- ggplot(music, aes(x=wday)) +
  geom_histogram(aes(y = ..count.., fill = ..count..), breaks = seq(1, 8),  position = "dodge") +
  coord_polar(start = 1) +
  theme_minimal(base_size = 16) +
  ylab("Plays") +
  xlab("Days/week") +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        legend.key.height = unit(50, "points")) +
  scale_fill_continuous(name = "plays",
                        low = "firebrick4",
                        high = "firebrick1",
                        breaks =  seq(shortestDay,
                                           longestDay, 
                                           by = 1000)) +
  ggtitle("Tracks per day of the week")

print(music.polarPlot)
dev.off()

# tracks per day

png("plots/musicTotalPerDay.png", width = 900)

music.lplot <- ggplot(music.perday, aes(x = ISO.time, y = play)) +
  geom_line(color = "red", alpha = .8, size =  .5) +
  geom_smooth() +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_datetime(breaks = date_breaks("4 month"), 
                   labels = date_format("%b %Y")) +
  xlab("Time (year/month)") +
  ylab("Plays") +
  ggtitle("Played tracks per day")

print(music.lplot)
dev.off()
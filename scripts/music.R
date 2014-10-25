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

setwd("~/persanalytics/")

# load huge file of all scrobbled tracks, tag it with s
scrobbles <- read.table("data/lastfm/data/scrobbles.tsv", sep = "\t", header = TRUE)
scrobbles$type = "s"

# load file with loved tracks, tag it with l
loved <- read.table("data/lastfm/data/loved.tsv", sep = "\t", header = TRUE)
loved$type = "l"

# merge the two files
music <- rbind.fill(scrobbles, loved)

# do some time and date formatting
music$detTime <- as.POSIXct(music$unixtime, tz = "EST", origin = "1970-01-01")
music$ISO.time <- as.POSIXct(music$ISO.time, tz = "EST", origin = "1970-01-01")

music$hour <- hour(music$detTime) # extract hour component
music$min <- minute(music$detTime) # extract minute component

music$ytime <- paste(music$hour, music$min, sep=":") # create hh:mm
music$ytime <- as.POSIXct(strptime(music$ytime, format="%H:%M")) # convert to POSIX

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
  geom_point(size = .75, color = "blue", alpha = .8) +
  geom_point(data = subset(music, type == "l"), aes(x = ISO.time, y = ytime), color = "red") +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_datetime(breaks = date_breaks("4 month"), labels = date_format("%Y/%m")) +
  scale_y_datetime(breaks = date_breaks("1 hour"), labels = date_format("%H:%M")) +
  xlab("Time (year/month)") +
  ylab("Time in day") +
  ggtitle("All scrobbled tracks")

print(music.splot)
dev.off()

png("plots/musicScrobbles.png", width = 900)

music.splot <- ggplot(subset(music, type == "s") , aes(x = ISO.time, y = ytime)) +
  geom_point(size = .75, color = "blue", alpha = .8) +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_datetime(breaks = date_breaks("4 month"), labels = date_format("%Y/%m")) +
  scale_y_datetime(breaks = date_breaks("1 hour"), labels = date_format("%H:%M")) +
  xlab("Time (year/month)") +
  ylab("Time in day") +
  ggtitle("All scrobbled tracks")

print(music.splot)
dev.off()


# just loved tracks

png("plots/musicLoved.png", width = 900)

music.lplot <- ggplot(subset(music, type == "l"), aes(x = ISO.time, y = ytime)) +
  geom_point(color = "red", alpha = .8) +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_datetime(breaks = date_breaks("4 month"), labels = date_format("%Y/%m")) +
  scale_y_datetime(breaks = date_breaks("1 hour"), labels = date_format("%H:%M")) +
  xlab("Time (year/month)") +
  ylab("Time in day") +
  ggtitle("Loved tracks")

print(music.lplot)
dev.off()
# `888                                       
#  oooo                                       
#  888  oooo   .ooooo.  oooo    ooo  .oooo.o 
#  888 .8P'   d88' `88b  `88.  .8'  d88(  "8 
#  888888.    888ooo888   `88..8'   `"Y88b.  
#  888 `88b.  888    .o    `888'    o.  )88b 
# o888o o888o `Y8bod8P'     .8'     8""888P' 
#                       .o..P'               
#                       `Y8P'                

setwd("~/persanalytics/")

#           oooo                                                         
#           `888                                                         
#  .ooooo.   888   .ooooo.   .oooo.   ooo. .oo.   oooo  oooo  oo.ooooo.  
# d88' `"Y8  888  d88' `88b `P  )88b  `888P"Y88b  `888  `888   888' `88b 
# 888        888  888ooo888  .oP"888   888   888   888   888   888   888 
# 888   .o8  888  888    .o d8(  888   888   888   888   888   888   888 
# `Y8bod8P' o888o `Y8bod8P' `Y888""8o o888o o888o  `V88V"V8P'  888bod8P' 
#                                                              888       
#                                                              o888o      

library(lubridate) # to extract components of time/date easily
library(ggplot2)  # for plotting
library(grid) # to use with ggplot for putting plots next to each other
library(scales) # specific use in labelling axes in plotting

airspace <- read.csv("~/log/keystrokes.log") # home machine
shuttle <- read.csv("~/Dropbox/shuttle-log/keystrokes-Shuttle.log") # portable machine

airspace$machine <- 1
shuttle$machine <- 2

keys <- rbind(airspace, shuttle) # merge data of two computers
keys$machine <- as.factor(keys$machine)
levels(keys$machine) <- c("Airspace", "Shuttle") # label machines

# The following block converts, breaks down, and puts together again
# dates of several forms and formats
# some columns will have POSIX-format time, and others will
# contain individual components, such as year, month, day, etc.
#
# There is probably redundancy that can be cleaned up in the block.
# It was written in a bit of a rush to try and get a few things working

keys$rtime <- as.POSIXlt(keys$minute, tz="EST", origin="1970-01-01") # convert numerical POSIX (1356747240) to readable data
keys$year <- year(keys$rtime) # extract year
keys$month <- month(keys$rtime) # extract month
keys$day <- wday(keys$rtime, label=TRUE) # extract day of the week
keys$mday <- mday(keys$rtime) # extract day of the month
keys$hour <- hour(keys$rtime) # extract hour component
keys$min <- minute(keys$rtime) # extract minute component

keys$xday <- paste(keys$year, keys$month, keys$mday, sep="-") # create: yyyy-mm-dd
keys$ytime <- paste(keys$hour, keys$min, sep=":") # create hh:mm

keys$xday <- as.POSIXct(strptime(keys$xday, "%Y-%m-%d")) # convert to POSIX
keys$ytime <- as.POSIXct(strptime(keys$ytime, format="%H:%M")) # convert to POSIX

daynames <- c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday") # create vector of day names

#                                                    oooo  oooo  
#                                                    `888  `888  
#  .ooooo.  oooo    ooo  .ooooo.  oooo d8b  .oooo.    888   888  
# d88' `88b  `88.  .8'  d88' `88b `888""8P `P  )88b   888   888  
# 888   888   `88..8'   888ooo888  888      .oP"888   888   888  
# 888   888    `888'    888    .o  888     d8(  888   888   888  
# `Y8bod8P'     `8'     `Y8bod8P' d888b    `Y888""8o o888o o888o 

theme_set(theme_minimal(base_size = 14)) # increases base text size a little bit

png("plots/polarAll.png", width=900)

keys.polarAll1 <- ggplot(keys, aes(x=hour)) +
  geom_histogram(aes(y = ..count.., fill= ..count..), breaks = seq(0, 24), width=2) +
  coord_polar(start = 0) +
  ylab("No. of mins per hour") +
  xlab("Hours (24)") +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        legend.position = "none") +
  scale_x_continuous("", limits = c(0, 24), breaks = seq(0, 24), labels = seq(0, 24)) +
  ggtitle("Minutes with keystrokes /hour\n (all time)"
  )

keys.polarAll2 <- ggplot(keys, aes(x=day)) +
  geom_histogram(aes(y = ..count.., fill= ..count..), breaks = seq(1, 8), width=1) +
  coord_polar(start = 1) +
  ylab("No. of mins per hour") +
  xlab("Days/week") +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        legend.position = "none") +
  ggtitle("Minutes with keystrokes /day\n (all time)"
  )

### draw next to each other
pushViewport(viewport(layout = grid.layout(1, 2)))
print(keys.polarAll1, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(keys.polarAll2, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))

dev.off() # close device/file

#                     oooo   o8o      .   
#                     `888   `"'    .o8   
#  .oooo.o oo.ooooo.   888  oooo  .o888oo 
# d88(  "8  888' `88b  888  `888    888   
# `"Y88b.   888   888  888   888    888   
# o.  )88b  888   888  888   888    888 . 
# 8""888P'  888bod8P' o888o o888o   "888" 
#           888                           
#          o888o                          

png("plots/polarSplit.png", width=900)

keys.polarSplit1 <- ggplot(keys, aes(x=hour)) +
  geom_histogram(aes(y = ..count.., fill= machine), breaks = seq(0, 24), binwidth = 48, position = "dodge") +
  coord_polar(start = 0) +
  theme_minimal(base_size = 16) +
  ylab("No. of mins per hour") +
  xlab("Hours (24)") +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        legend.position = "bottom") +
  scale_x_continuous("", limits = c(0, 24), breaks = seq(0, 24), labels = seq(0, 24)) +
  scale_fill_brewer(palette = "Paired") +
  ggtitle("Minutes with keystrokes \n/hour /machine (all time)"
  )

keys.polarSplit2 <- ggplot(keys, aes(x=day)) +
  geom_histogram(aes(y = ..count.., fill= machine), breaks = seq(1, 8), binwidth = 14, position = "dodge") +
  coord_polar(start = 1) +
  theme_minimal(base_size = 16) +
  ylab("No. of mins per hour") +
  xlab("Days/week") +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(palette = "Paired") +
  ggtitle("Minutes with keystrokes \n/day /machine (all time)"
  )

### draw next to each other
pushViewport(viewport(layout = grid.layout(1, 2)))
print(keys.polarSplit1, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(keys.polarSplit2, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))

dev.off() # close device/file

#                          .oooo.     .oooo.     .o        .o   
#                        .dP""Y88b   d8P'`Y8b  o888      .d88   
#  .oooo.o oo.ooooo.           ]8P' 888    888  888    .d'888   
# d88(  "8  888' `88b        .d8P'  888    888  888  .d'  888   
# `"Y88b.   888   888      .dP'     888    888  888  88ooo888oo 
# o.  )88b  888   888    .oP     .o `88b  d88'  888       888   
# 8""888P'  888bod8P'    8888888888  `Y8bd8P'  o888o     o888o  
#           888                                                 
#          o888o                                                

png("plots/polarSplit2014.png", width=900)

keys.polarSplit2014_1 <- ggplot(subset(keys, keys$year >= 2014), aes(x=hour)) +
  geom_histogram(aes(y = ..count.., fill= machine), breaks = seq(0, 24), binwidth = 48, position = "dodge") +
  coord_polar(start = 0) +
  ylab("No. of mins per hour") +
  xlab("Hours (24)") +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        legend.position = "bottom") +
  scale_x_continuous("", limits = c(0, 24), breaks = seq(0, 24), labels = seq(0, 24)) +
  scale_fill_brewer(palette = "Paired") +
  ggtitle("Minutes with keystrokes \n/hour /machine (2014)"
  )

keys.polarSplit2014_2 <- ggplot(subset(keys, keys$year >= 2014), aes(x=day)) + #
  geom_histogram(aes(y = ..count.., fill= machine), breaks = seq(1, 8), binwidth = 14, position = "dodge") +
  coord_polar(start = 1) +
  ylab("No. of mins per hour") +
  xlab("Days/week") +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(palette = "Paired") +
  ggtitle("Minutes with keystrokes \n/day /machine (2014)"
  )

### draw next to each other
pushViewport(viewport(layout = grid.layout(1, 2)))
print(keys.polarSplit2014_1, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(keys.polarSplit2014_2, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))

dev.off() # close device/file

# oooo                                                
# `888                                                
#  888 .oo.    .ooooo.  oooo  oooo  oooo d8b  .oooo.o 
#  888P"Y88b  d88' `88b `888  `888  `888""8P d88(  "8 
#  888   888  888   888  888   888   888     `"Y88b.  
#  888   888  888   888  888   888   888     o.  )88b 
# o888o o888o `Y8bod8P'  `V88V"V8P' d888b    8""888P' 

png("plots/keysOverTime.png", width=900)

keys.hoursAll <- ggplot(keys, aes(x=xday, y=ytime)) + 
  geom_point(aes(color=machine), alpha=.7, size=1) + 
  theme_minimal(base_size=16) +
  scale_y_datetime(breaks=date_breaks("1 hour"), labels = date_format("%H:%M")) +
  xlab("Days") +
  ylab("Hours of day") +
  theme(legend.position = "bottom") +
  guides(colour = guide_legend(override.aes = list(size = 5))) +
  scale_color_manual(name = "machine", values=c("#00BFC4", "#F8766D")) +
  ggtitle("Distribution of keystrokes by machine throughout the day")

print(keys.hoursAll)

dev.off() # close device/file

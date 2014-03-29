# script for crunching and plotting keystroke data

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

library(lubridate)
library(ggplot2)
library(grid)
library(scales)

airspace <- read.csv("~/log/keystrokes.log")
shuttle <- read.csv("~/Dropbox/shuttle-log/keystrokes-Shuttle.log")

airspace$machine <- 1
shuttle$machine <- 2

keys <- rbind(airspace, shuttle)
keys$machine <- as.factor(keys$machine)
levels(keys$machine) <- c("Airspace", "Shuttle")

keys$rtime <- as.POSIXlt(keys$minute, tz="EST", origin="1970-01-01")
keys$year <- year(keys$rtime) # extract year
keys$month <- month(keys$rtime)
keys$day <- wday(keys$rtime, label=TRUE) # extract day of the week
keys$mday <- mday(keys$rtime)
keys$hour <- hour(keys$rtime) # extract hour component
keys$min <- minute(keys$rtime)

keys$xday <- paste(keys$year, keys$month, keys$mday, sep="-")
keys$ytime <- paste(keys$hour, keys$min, sep=":")

keys$xday <- as.POSIXct(strptime(keys$xday, "%Y-%m-%d"))
keys$ytime <- as.POSIXct(strptime(keys$ytime, format="%H:%M"))

daynames <- c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")

#                                                    oooo  oooo  
#                                                    `888  `888  
#  .ooooo.  oooo    ooo  .ooooo.  oooo d8b  .oooo.    888   888  
# d88' `88b  `88.  .8'  d88' `88b `888""8P `P  )88b   888   888  
# 888   888   `88..8'   888ooo888  888      .oP"888   888   888  
# 888   888    `888'    888    .o  888     d8(  888   888   888  
# `Y8bod8P'     `8'     `Y8bod8P' d888b    `Y888""8o o888o o888o 

theme_set(theme_minimal(base_size = 14)) # increases base text size a little bit

png("plots/polarAll.png", width=1000)

keys.plot <- ggplot(keys, aes(x=hour)) +
  geom_histogram(aes(y = ..count.., fill= ..count..), breaks = seq(0, 24), width=2) +
  coord_polar(start = 0) +
  ylab("No. of mins per hour") +
  xlab("Hours (24)") +
  scale_x_continuous("", limits = c(0, 24), breaks = seq(0, 24), labels = seq(0, 24)) +
  ggtitle("No. of mins with keystrokes per hour\n (all time)"
  )

keys.plot2 <- ggplot(keys, aes(x=day)) +
  geom_histogram(aes(y = ..count.., fill= ..count..), breaks = seq(1, 8), width=1) +
  coord_polar(start = 1) +
  ylab("No. of mins per hour") +
  xlab("Days/week") +
  ggtitle("No. of mins with keystrokes per day\n (all time)"
  )

### draw next to each other
pushViewport(viewport(layout = grid.layout(1, 2)))
print(keys.plot, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(keys.plot2, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))

dev.off()

#                     oooo   o8o      .   
#                     `888   `"'    .o8   
#  .oooo.o oo.ooooo.   888  oooo  .o888oo 
# d88(  "8  888' `88b  888  `888    888   
# `"Y88b.   888   888  888   888    888   
# o.  )88b  888   888  888   888    888 . 
# 8""888P'  888bod8P' o888o o888o   "888" 
#           888                           
#          o888o                          

png("plots/polarSplit.png", width=1000)

keys.plot <- ggplot(keys, aes(x=hour)) +
  geom_histogram(aes(y = ..count.., fill= machine), breaks = seq(0, 24), binwidth = 48, position = "dodge") +
  coord_polar(start = 0) +
  ylab("No. of mins per hour") +
  xlab("Hours (24)") +
  scale_x_continuous("", limits = c(0, 24), breaks = seq(0, 24), labels = seq(0, 24)) +
  scale_fill_brewer(palette = "Paired") +
  ggtitle("No. of mins with keystrokes per hour, split by machine\n (all time)"
  )

keys.plot2 <- ggplot(keys, aes(x=day)) +
  geom_histogram(aes(y = ..count.., fill= machine), breaks = seq(1, 8), binwidth = 14, position = "dodge") +
  coord_polar(start = 1) +
  ylab("No. of mins per hour") +
  xlab("Days/week") +
  scale_fill_brewer(palette = "Paired") +
  ggtitle("No. of mins with keystrokes per day, split by machine\n (all time)"
  )

### draw next to each other
pushViewport(viewport(layout = grid.layout(1, 2)))
print(keys.plot, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(keys.plot2, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))

dev.off()

#                          .oooo.     .oooo.     .o        .o   
#                        .dP""Y88b   d8P'`Y8b  o888      .d88   
#  .oooo.o oo.ooooo.           ]8P' 888    888  888    .d'888   
# d88(  "8  888' `88b        .d8P'  888    888  888  .d'  888   
# `"Y88b.   888   888      .dP'     888    888  888  88ooo888oo 
# o.  )88b  888   888    .oP     .o `88b  d88'  888       888   
# 8""888P'  888bod8P'    8888888888  `Y8bd8P'  o888o     o888o  
#           888                                                 
#          o888o                                                

png("plots/polarSplit2014.png", width=1000)

keys.plot <- ggplot(subset(keys, keys$year >= 2014), aes(x=hour)) +
  geom_histogram(aes(y = ..count.., fill= machine), breaks = seq(0, 24), binwidth = 48, position = "dodge") +
  coord_polar(start = 0) +
  ylab("No. of mins per hour") +
  xlab("Hours (24)") +
  scale_x_continuous("", limits = c(0, 24), breaks = seq(0, 24), labels = seq(0, 24)) +
  scale_fill_brewer(palette = "Paired") +
  ggtitle("No. of mins with keystrokes per hour, split by machine\n (2014)"
  )

keys.plot2 <- ggplot(subset(keys, keys$year >= 2014), aes(x=day)) + #
  geom_histogram(aes(y = ..count.., fill= machine), breaks = seq(1, 8), binwidth = 14, position = "dodge") +
  coord_polar(start = 1) +
  ylab("No. of mins per hour") +
  xlab("Days/week") +
  scale_fill_brewer(palette = "Paired") +
  ggtitle("No. of mins with keystrokes per day, split by machine\n (2014)"
  )

### draw next to each other
pushViewport(viewport(layout = grid.layout(1, 2)))
print(keys.plot, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(keys.plot2, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))

dev.off()

# oooo                                                
# `888                                                
#  888 .oo.    .ooooo.  oooo  oooo  oooo d8b  .oooo.o 
#  888P"Y88b  d88' `88b `888  `888  `888""8P d88(  "8 
#  888   888  888   888  888   888   888     `"Y88b.  
#  888   888  888   888  888   888   888     o.  )88b 
# o888o o888o `Y8bod8P'  `V88V"V8P' d888b    8""888P' 

png("plots/keysOverTime.png", width=1000)

gghours <- ggplot(keys, aes(x=xday, y=ytime)) + 
  geom_point(aes(color=machine), alpha=.6, size=1) + 
  theme_minimal(base_size=14) +
  scale_y_datetime(breaks=date_breaks("1 hour"), labels = date_format("%H:%M")) +
  xlab("Days") +
  ylab("Hours of day") +
  guides(colour = guide_legend(override.aes = list(size = 4))) +
  ggtitle("Distribution of keystrokes by machine throughout the day")

print(gghours)

dev.off()

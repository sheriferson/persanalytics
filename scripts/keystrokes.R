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
library(gridExtra) # to use for aligning two plots for last 7 days
library(RColorBrewer) # to choose cool colours for plots
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

keys$rtime <- as.POSIXlt(keys$minute, tz = "EST", origin = "1970-01-01") # convert numerical POSIX (1356747240) to readable data
keys$year <- year(keys$rtime) # extract year
keys$month <- month(keys$rtime) # extract month
keys$day <- wday(keys$rtime, label = TRUE) # extract day of the week
keys$mday <- mday(keys$rtime) # extract day of the month
keys$hour <- hour(keys$rtime) # extract hour component
keys$min <- minute(keys$rtime) # extract minute component

keys$xday <- paste(keys$year, keys$month, keys$mday, sep = "-") # create: yyyy-mm-dd
keys$ytime <- paste(keys$hour, keys$min, sep = ":") # create hh:mm

keys$xday <- as.POSIXct(strptime(keys$xday, "%Y-%m-%d")) # convert to POSIX
keys$ytime <- as.POSIXct(strptime(keys$ytime, format = "%H:%M")) # convert to POSIX
# keys$xday <- as.POSIXct(keys$xday, format="%Y-%m-%d") # convert to POSIX
# keys$ytime <- as.POSIXct(keys$ytime, format="%H:%M") # convert to POSIX

daynames <- c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday") # create vector of day names

# give me a dataset with only the last 7 days and today
unixweek <- 604800
cutoff <- as.POSIXct(max(keys$minute) - unixweek, origin = "1970-01-01")
cutoff <- as.numeric(strptime(cutoff, format = "%Y-%m-%d"))
keys7 <- subset(keys, minute > cutoff)

# give me a dataset with only the last 14 days and today
unixtwoweeks <- unixweek * 2
cutoff <- as.POSIXct(max(keys$minute) - unixtwoweeks, origin = "1970-01-01")
cutoff <- as.numeric(strptime(cutoff, format = "%Y-%m-%d"))
keys14 <- subset(keys, minute > cutoff)


# get keystrokes totals for totals bar plot in last 7 and 14 days
k7 <- aggregate(strokes ~ xday * machine, data = keys7, FUN = sum)
k14 <- aggregate(strokes ~ xday * machine, data = keys14, FUN = sum)

#                                                    oooo  oooo  
#                                                    `888  `888  
#  .ooooo.  oooo    ooo  .ooooo.  oooo d8b  .oooo.    888   888  
# d88' `88b  `88.  .8'  d88' `88b `888""8P `P  )88b   888   888  
# 888   888   `88..8'   888ooo888  888      .oP"888   888   888  
# 888   888    `888'    888    .o  888     d8(  888   888   888  
# `Y8bod8P'     `8'     `Y8bod8P' d888b    `Y888""8o o888o o888o 

theme_set(theme_minimal(base_size = 16)) # increases base text size a little bit
machineColors <- rev(brewer.pal(3, "Set1")[1:2])

png("plots/polarAll.png", width = 900)

keys.polarAll1 <- ggplot(keys, aes(x = hour)) +
    geom_bar(aes(y = ..count.., fill = ..count..)) +
    coord_polar(start = 0) +
    ylab("No. of mins per hour") +
    xlab("Hours (24)") +
    theme(axis.text.y = element_blank(), 
          axis.ticks.y = element_blank(),
          legend.position = "none") +
    scale_fill_distiller(palette = "Blues") +
    ggtitle("Minutes with keystrokes /hour\n (all time)"
    )

keys.polarAll2 <- ggplot(keys, aes(x = day)) +
    geom_bar(aes(y = ..count.., fill = ..count..)) +
    coord_polar(start = 1) +
    ylab("No. of mins per hour") +
    xlab("Days/week") +
    theme(axis.text.y = element_blank(), 
          axis.ticks.y = element_blank(),
          legend.position = "none") +
    scale_fill_distiller(palette = "Blues") +
    ggtitle("Minutes with keystrokes /day\n (all time)"
    )

### draw next to each other
pushViewport(viewport(layout = grid.layout(1, 2)))
print(keys.polarAll1, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(keys.polarAll2, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))

dev.off() # close device/file

# oooo                                                
# `888                                                
#  888 .oo.    .ooooo.  oooo  oooo  oooo d8b  .oooo.o 
#  888P"Y88b  d88' `88b `888  `888  `888""8P d88(  "8 
#  888   888  888   888  888   888   888     `"Y88b.  
#  888   888  888   888  888   888   888     o.  )88b 
# o888o o888o `Y8bod8P'  `V88V"V8P' d888b    8""888P' 

png("plots/keysOverTime.png", width = 900)

keys.hoursAll <- ggplot(keys, aes(x = xday, y = ytime)) + 
  geom_point(aes(color = machine), alpha = .5, size = .25) + 
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  xlab("Days") +
  ylab("Hours of day") +
  scale_y_datetime(breaks = date_breaks("1 hour"),
                   labels = date_format("%H:%M", tz = "America/Toronto"),
                   limits = range(keys$ytime),
                   expand = c(0,60)) +
  scale_x_datetime(breaks = date_breaks("1 month"),
                   labels = date_format("%b %Y"),
                   limits = range(keys$xday),
                   expand = c(0.03,0)
                   ) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  guides(colour = guide_legend(override.aes = list(size = 5))) +
  scale_color_manual(name = "machine", values = machineColors) +
  ggtitle("Distribution of keystrokes by machine throughout the day")

print(keys.hoursAll)

dev.off() # close device/file

#                   o8o        .o8                     
#                   `"'       "888                     
# oooo oooo    ooo oooo   .oooo888   .ooooo.  oooo d8b 
#  `88. `88.  .8'  `888  d88' `888  d88' `88b `888""8P 
#   `88..]88..8'    888  888   888  888ooo888  888     
#    `888'`888'     888  888   888  888    .o  888     
#     `8'  `8'     o888o `Y8bod88P" `Y8bod8P' d888b    

png("plots/keysOverTime_wider.png", width = 1600, 600)
print(keys.hoursAll)
dev.off()

#   ooooooooo          .o8                                 
#  d"""""""8'         "888                                 
#        .8'      .oooo888   .oooo.   oooo    ooo  .oooo.o 
#       .8'      d88' `888  `P  )88b   `88.  .8'  d88(  "8 
#      .8'       888   888   .oP"888    `88..8'   `"Y88b.  
#     .8'        888   888  d8(  888     `888'    o.  )88b 
#    .8'         `Y8bod88P" `Y888""8o     .8'     8""888P' 
#                                     .o..P'               
#                                    `Y8P'                

png("plots/keysOverTime_7days.png", width = 500, height = 750)

keys.barHours <- ggplot(keys7, aes(x = xday, y = ytime)) + 
    geom_point(aes(color = machine, size = strokes), alpha = .4) +
    scale_size(range = c(2, 12)) +
    theme_bw() + 
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          legend.position = "none",
          panel.grid.minor.x = element_blank(),
          panel.grid.major = element_blank(),
          plot.margin = unit(c(1,5,-32,4), units = "points")) +
    xlab("") +
    ylab("Time of day") +
    scale_x_datetime(breaks = date_breaks("1 day"),
                     expand = c(.125, 45)
                     ) +
    scale_y_datetime(breaks = date_breaks("2 hours"),
                     labels = date_format("%H:%M", tz = "America/Toronto"),
                     limits = range(keys7$ytime)
                    ) +
    guides(colour = guide_legend(override.aes = list(size = 5))) +
    scale_color_manual(name = "machine", values = machineColors) +
    ggtitle("keystrokes / machine (last 7 days)")

keys.barTotals <- ggplot(k7, aes(x = xday, y = strokes)) + 
    geom_bar(aes(color = machine, fill = machine), stat = "identity") +
    theme_bw() +
    theme(plot.margin = unit(c(0,5,1,1),units = "points"),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          legend.position = "bottom") +
    scale_x_datetime(breaks = date_breaks("1 day"), 
                     labels = date_format("%a%n%b %d") # "Wed\n Nov 11
                    ) +
    scale_color_manual(name = "machine", values = machineColors) +
    scale_fill_manual(name = "machine", values = machineColors) +
    # scale_fill_gradient(low = "#00BFC4", high = "#F8766D") +
    xlab("Day") +
    ylab("Keystrokes")

grid.arrange(keys.barHours, keys.barTotals, heights = c(4/6, 2/6))

dev.off() # close device/file

#   .o        .o            .o8                                 
# o888      .d88           "888                                 
#  888    .d'888       .oooo888   .oooo.   oooo    ooo  .oooo.o 
#  888  .d'  888      d88' `888  `P  )88b   `88.  .8'  d88(  "8 
#  888  88ooo888oo    888   888   .oP"888    `88..8'   `"Y88b.  
#  888       888      888   888  d8(  888     `888'    o.  )88b 
# o888o     o888o     `Y8bod88P" `Y888""8o     .8'     8""888P' 
#                                          .o..P'               
#                                          `Y8P'                

png("plots/keysOverTime_14days.png", width = 800, height = 750)

keys14.barHours <- ggplot(keys14, aes(x = xday, y = ytime)) + 
  geom_point(aes(color = machine, size = strokes), alpha = .4) +
  scale_size(range = c(2, 12)) +
  theme_bw() + 
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.position = "none",
        panel.grid.minor.x = element_blank(),
        panel.grid.major = element_blank(),
        plot.margin = unit(c(1,5,-32,4), units = "points")) +
  xlab("") +
  ylab("Time of day") +
  scale_x_datetime(breaks = date_breaks("1 day"),
                   expand = c(.085, 45)
  ) +
  scale_y_datetime(breaks = date_breaks("2 hours"),
                   labels = date_format("%H:%M", tz = "America/Toronto"),
                   limits = range(keys7$ytime)
  ) +
  guides(colour = guide_legend(override.aes = list(size = 5))) +
  scale_color_manual(name = "machine", values = machineColors) +
  ggtitle("keystrokes / machine (last 7 days)")

keys14.barTotals <- ggplot(k14, aes(x = xday, y = strokes)) + 
  geom_bar(aes(color = machine, fill = machine), stat = "identity") +
  theme_bw() +
  theme(plot.margin = unit(c(0,5,1,1),units = "points"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "bottom") +
  scale_x_datetime(breaks = date_breaks("1 day"), 
                   labels = date_format("%a%n%b %d") # "Wed\n Nov 11
  ) +
  scale_color_manual(name = "machine", values = machineColors) +
  scale_fill_manual(name = "machine", values = machineColors) +
  # scale_fill_gradient(low = "#00BFC4", high = "#F8766D") +
  xlab("Day") +
  ylab("Keystrokes")

grid.arrange(keys14.barHours, keys14.barTotals, heights = c(4/6, 2/6))

dev.off() # close device/file

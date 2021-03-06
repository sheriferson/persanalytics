#     .                   .o8            
#   .o8                  "888            
# .o888oo  .ooooo.   .oooo888   .ooooo.  
#   888   d88' `88b d88' `888  d88' `88b 
#   888   888   888 888   888  888   888 
#   888 . 888   888 888   888  888   888 
#   "888" `Y8bod8P' `Y8bod88P" `Y8bod8P' 

# A quick script to load in the text files for current
# and completed tasks, count them, save them to a .csv file.

# It is important to note that these todos are being managed by a program
# that I currently have no control over. I have to deal with the formatting
# of the files as that program saves them.

#           oooo                                                         
#           `888                                                         
#  .ooooo.   888   .ooooo.   .oooo.   ooo. .oo.   oooo  oooo  oo.ooooo.  
# d88' `"Y8  888  d88' `88b `P  )88b  `888P"Y88b  `888  `888   888' `88b 
# 888        888  888ooo888  .oP"888   888   888   888   888   888   888 
# 888   .o8  888  888    .o d8(  888   888   888   888   888   888   888 
# `Y8bod8P' o888o `Y8bod8P' `Y888""8o o888o o888o  `V88V"V8P'  888bod8P' 
#                                                              888       
#                                                              o888o      

setwd("~/persanalytics/")

# read current todos file
tasksnow <- read.table("~/Dropbox/Text/tasks/tasks.txt", 
                       sep="|", # id and todo text are separate by pipe '|'
                       header=FALSE, # no header/column names
                       strip.white=TRUE # strip white space
                       )

# read file with completed tasks
tasksdone <- read.table("~/Dropbox/Text/tasks/.tasks.txt.done", 
                        sep="|", # id and todo text are separate by pipe '|'
                        header=FALSE, # no header/column names
                        strip.white=TRUE, # strip white space
                        quote = "", # disabled quoting to deal with format of completed tasks file
                        row.names = NULL # no row names when importing data into R
                        )

# number of pending/current tasks
tnow <- nrow(tasksnow)

# number of completed tasks
tdone <- nrow(tasksdone)

#  .oooo.o  .oooo.   oooo    ooo  .ooooo.  
# d88(  "8 `P  )88b   `88.  .8'  d88' `88b 
# `"Y88b.   .oP"888    `88..8'   888ooo888 
# o.  )88b d8(  888     `888'    888    .o 
# 8""888P' `Y888""8o     `8'     `Y8bod8P' 

# check if file already exists, if it does, append
# time, number of now, number of done
# if it doesn't exist, write header, and then write data

datatowrite <- ifelse(file.exists("data/todos.csv"),
                      paste(paste(Sys.time(), "t", tnow, sep=","), paste(Sys.time(), "d", tdone, sep=","), sep="\n"),
                      paste(paste("ttime", "tlist", "tcount", sep=","), paste(paste(Sys.time(), "t", tnow, sep=","), paste(Sys.time(), "d", tdone, sep=","), sep="\n"), sep="\n")
                      )

# write to file
write(datatowrite, 
      file="data/todos.csv",
      append=TRUE)

#            oooo                .                                            
#            `888              .o8                                            
# oo.ooooo.   888   .ooooo.  .o888oo oo.ooooo.  oooo d8b  .ooooo.  oo.ooooo.  
#  888' `88b  888  d88' `88b   888    888' `88b `888""8P d88' `88b  888' `88b 
#  888   888  888  888   888   888    888   888  888     888ooo888  888   888 
#  888   888  888  888   888   888 .  888   888  888     888    .o  888   888 
#  888bod8P' o888o `Y8bod8P'   "888"  888bod8P' d888b    `Y8bod8P'  888bod8P' 
#  888                                888                           888       
# o888o                              o888o                         o888o      

library(ggplot2) # plotting
library(scales) # for handling time breaks on x axis
library(lubridate)
library(zoo)    # for handling rolling mean calculation

todos <- read.csv("data/todos.csv")
todos$ttime <- as.POSIXct(todos$ttime)
levels(todos$tlist) <- c("done", "current")

# prepare data for plotting tasks done per day
todos$year <- year(todos$ttime) # extract year
todos$month <- month(todos$ttime) # extract month
todos$day <- mday(todos$ttime) # extract day of the week

todos.done <- subset(todos, tlist == "done") # separate out the completed numbers
todos.done.perday <- aggregate(tcount ~ day * month * year, data = todos.done, max)
todos.done.perday$prevTcount <- c(rep(NA,1),head(todos.done.perday$tcount,-1))

todos.done.perday$completedSinceYesterday <- todos.done.perday$tcount - todos.done.perday$prevTcount

todos.done.perday$xday <- paste(todos.done.perday$year, 
                                todos.done.perday$month, 
                                todos.done.perday$day, sep="-") # create: yyyy-mm-dd
todos.done.perday$xday <- as.Date(todos.done.perday$xday)

# set an outlier cutoff so that one perhaps erroneous or weird day
# doesn't throw the plot off
outlierCutoff <- mean(todos.done.perday$completedSinceYesterday, na.rm = TRUE) + (5 * sd(todos.done.perday$completedSinceYesterday, na.rm = TRUE))

## todos.done.perday only includes rows for days on which I completed tasks
## which means that plots will be skewed because of missing days
## Need to fill in rows for missing days

alldays <- seq.Date(from = as.Date(min(todos.done.perday$xday)), 
                    to = as.Date(max(todos.done.perday$xday)), 
                    "days")

alldays <- data.frame(alldays)
colnames(alldays) <- c("xday")

todos.done.perday <- merge(alldays, todos.done.perday,
                           by.x = "xday",
                           by.y = "xday",
                           all.x = TRUE)

missingDays <- is.na(todos.done.perday$completedSinceYesterday)
todos.done.perday$completedSinceYesterday[missingDays] <- 0
todos.done.perday$xday <- as.POSIXct(strptime(todos.done.perday$xday, "%Y-%m-%d")) # convert to POSIX

### completed per day with a rolling mean
# the above plot doesn't look very informative. the loess smooth line is a bit informative
# but the line plot is not.
# let's try using a rolling mean

# there are two problems to handle:
# 1. the first value of completedSinceYesterday is NA. This throws off rollmean
# 2. the number of values returned by rollmean is the number of values given
#    to it minus the size of the window for the rolling mean minus 1
#
# current proposed solution is to set the size of the rolling average window
# to a variable x,
# produce the rolling average vector
# cut down the data frame to nrows - x - 1
# add the rolling average vector which should now match the dataframe in length
# plot

window = 10
rollingTodos <- todos.done.perday[-1,]
rollingCompleted <- rollmean(rollingTodos$completedSinceYesterday, window)

rollingTodos <- rollingTodos[-seq(window-1),]
rollingTodos$rolled <- rollingCompleted

#            oooo                .   
#            `888              .o8   
# oo.ooooo.   888   .ooooo.  .o888oo 
#  888' `88b  888  d88' `88b   888   
#  888   888  888  888   888   888   
#  888   888  888  888   888   888 . 
#  888bod8P' o888o `Y8bod8P'   "888" 
#  888                               
# o888o                              

# plot all over time

png("plots/todos.png", width=900)

todos.overall <- ggplot(todos, aes(x = ttime, y = tcount, group = tlist)) + 
  geom_line(aes(colour = tlist), size = 1) +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab("Time") +
  ylab("Count") +
  ggtitle("Current and done todos over time") +
  scale_color_manual(name = "list", values=c("#00BFC4", "#F8766D")) +
  scale_x_datetime(breaks=date_breaks("1 month"), labels = date_format("%Y %b"))

print(todos.overall)
dev.off()

# completed per day

png("plots/todos_completedPerDay.png", width=900)

todos.completedPerDay <- ggplot(todos.done.perday, aes(x = xday, y = completedSinceYesterday)) + 
  geom_line(colour="#00BFC4") +
  geom_smooth(method = "loess") +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab("Time") +
  ylab("Completed todos") +
  ggtitle("Completed todos per day") +
  geom_hline(yintercept = tail(todos.done.perday$completedSinceYesterday, 1), color = 'red', alpha = 0.5) +
  scale_x_datetime(breaks=date_breaks("1 month"), 
                   labels = date_format("%b %Y")) +
  scale_y_continuous(breaks = 1:outlierCutoff) +
  coord_cartesian(ylim = c(1, outlierCutoff))

print(todos.completedPerDay)
dev.off()

# completed per day rolled edition

png("plots/todos_completedPerDay_rolled.png", width=900)

todos.RolledCompletedPerDay <- ggplot(rollingTodos, aes(x = xday, y = rolled)) + 
  geom_line(colour="#8FC3Eb", size = .75) +
  geom_smooth(method = "loess") +
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab("Time") +
  ylab("Completed todos") +
  ggtitle("Completed todos per day (rolling mean with 10-day window)") +
  geom_hline(yintercept = tail(rollingTodos$rolled, 1), color = 'red', alpha = 0.5) +
  scale_x_datetime(breaks=date_breaks("1 month"), 
                   labels = date_format("%Y %b")) +
  scale_y_continuous(breaks = 1:max(todos.done.perday$completedSinceYesterday, na.rm = T))

print(todos.RolledCompletedPerDay)
dev.off()

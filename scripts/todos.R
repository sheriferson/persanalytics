# A quick script to load in the text files for current
# and completed tasks, count them, save them to a .csv file.

# Plotting coming soon.

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
# oo.ooooo.   888   .ooooo.  .o888oo 
#  888' `88b  888  d88' `88b   888   
#  888   888  888  888   888   888   
#  888   888  888  888   888   888 . 
#  888bod8P' o888o `Y8bod8P'   "888" 
#  888                               
# o888o                              

library(scales) # for handling time breaks on x axis

todos <- read.csv("data/todos.csv")
todos$ttime <- as.POSIXct(todos$ttime)
levels(todos$tlist) <- c("done", "current")
png("plots/todos.png", width=900)

todos.overall <- ggplot(todos, aes(x = ttime, y = tcount, group = tlist)) + 
  geom_line(aes(colour = tlist), size = 2) +
  theme_bw(base_size = 16) +
  xlab("Time") +
  ylab("Count") +
  scale_color_manual(name = "machine", values=c("#00BFC4", "#F8766D")) +
    scale_x_datetime(breaks=date_breaks("1 day"), labels = date_format("%b %d"))

print(todos.overall)

dev.off()

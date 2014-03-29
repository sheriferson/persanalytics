# A quick script to load in the text files for current
# and completed tasks, count them, save them to a .csv file
# and plot those numbers

setwd("~/persanalytics/data/")

# read current todo file
tasksnow <- read.table("~/Dropbox/Text/tasks/tasks.txt", sep="|", header=FALSE, strip.white=TRUE)

# read file with completed tasks
tasksdone <- read.table("~/Dropbox/Text/tasks/.tasks.txt.done", 
                        sep="|", 
                        header=FALSE, 
                        strip.white=TRUE,
                        quote = "",
                        row.names = NULL
                        )

# number of pending tasks
tnow <- nrow(tasksnow)

# number of completed tasks
tdone <- nrow(tasksdone)

# check if file already exists, if it does, append
# time, number of now, number of done
# if it doesn't exist
# write header, and then write data

datatowrite <- ifelse(file.exists("data/todos.csv"),
                      paste(paste(Sys.time(), "t", tnow, sep=","), paste(Sys.time(), "d", tdone, sep=","), sep="\n"),
                      paste(paste("ttime", "tlist", "tcount", sep=","), paste(paste(Sys.time(), "t", tnow, sep=","), paste(Sys.time(), "d", tdone, sep=","), sep="\n"), sep="\n")
                      )

# write to file
write(datatowrite, 
      file="data/todos.csv",
      append=TRUE)
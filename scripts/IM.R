#           oooo                      .   
#           `888                    .o8   
#  .ooooo.   888 .oo.    .oooo.   .o888oo 
# d88' `"Y8  888P"Y88b  `P  )88b    888   
# 888        888   888   .oP"888    888   
# 888   .o8  888   888  d8(  888    888 . 
# `Y8bod8P' o888o o888o `Y888""8o   "888" 

library(stringr)  # to use str_extract wit regex to parse xml logs
library(ggplot2)  # for plotting
library(scales)   # help with formatting axes in plots

# the following block executes a bash command to merge all nested .xml
# log files into one big merged one. Then switches back to default
# working directory.
setwd("~/persanalytics/data/IM/Jabber.sherif@ssoliman.com/")
system('find . -type f -print0 | xargs -0 cat > ~/persanalytics/data/IM/mergedIM_ss.xml')

setwd("~/persanalytics/data/IM/Jabber.sherif@fastmail.fm")
system('find . -type f -print0 | xargs -0 cat > ~/persanalytics/data/IM/mergedIM_fm.xml')

setwd("~/persanalytics/data/IM/GTalk.thespeckofme@gmail.com/")
system('find . -type f -print0 | xargs -0 cat > ~/persanalytics/data/IM/mergedIM_gm.xml')

setwd("~/persanalytics/")

# load data files
clogs_s <- as.data.frame(readLines("data/IM/mergedIM_ss.xml"))
colnames(clogs_s) <- c("raw")
clogs_s$account = 3

clogs_f <- as.data.frame(readLines("data/IM/mergedIM_fm.xml"))
colnames(clogs_f) <- c("raw")
clogs_f$account = 2

clogs_g <- as.data.frame(readLines("data/IM/mergedIM_gm.xml"))
colnames(clogs_g) <- c("raw")
clogs_g$account = 1

clogs <- rbind(clogs_g, clogs_f, clogs_s)

# remove lines that contain status updates, sign ons, etc.
# those can be fun to play with later. For now, I only want
# messages.
mess <- clogs[grep("^<message", clogs$raw),]
mess$account <- as.factor(mess$account)

# Extract sender email.
mess$senderemail <- str_extract(mess$raw, perl('(?<=sender=\").+@.+com(?=\")'))

# Tag as 'sherif' or 'other'
mess$side <- as.factor(ifelse(mess$senderemail=="sherif@ssoliman.com", 'sherif', 'other'))

# Extract time
mess$time <- str_extract(mess$raw, perl('(?<=time=\").*?(?=[-+][0-9]{2}:?[0-9]{2}\")'))

# Do some cleanup, then create one column for yyyy-mm-dd,
# and another for hh:mm:ss
mess$time <- gsub("T", " ", mess$time)
mess$time <- as.POSIXct(mess$time, format='%Y-%m-%d %H:%M:%S')
mess$days <- as.POSIXct(str_extract(mess$time, perl('^[0-9]{4}-[0-9]{2}-[0-9]{2}')), format='%Y-%m-%d')
mess$clock <- as.POSIXct(str_extract(mess$time, perl('[0-9]{2}:[0-9]{2}:[0-9]{2}$')), format="%H:%M")

# Extract alias/nickname.
mess$alias <- str_extract(mess$raw, perl('(?<=alias=\").+?[^\"](?=\")'))

# Extract message content.
# Not perfect. It still has some html in there, but it's good
# enough for now.
mess$message <- str_extract(mess$raw, perl('(?<=div>).+?(?=</[sd])'))
mess$message <- gsub("<span.+?>", "", mess$message)

#            oooo                .   
#            `888              .o8   
# oo.ooooo.   888   .ooooo.  .o888oo 
#  888' `88b  888  d88' `88b   888   
#  888   888  888  888   888   888   
#  888   888  888  888   888   888 . 
#  888bod8P' o888o `Y8bod8P'   "888" 
#  888                               
# o888o                              

# Overall.

png("plots/chatOverall.png", width = 900)

mess.overall <- ggplot(mess, aes(x = days, y = clock)) + 
  geom_point(aes(color = account), alpha = .7, size = 1) +
  theme_bw(base_size = 16) +
  theme(legend.position = "none") +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  guides(colour = guide_legend(override.aes = list(size = 5))) +
  scale_x_datetime(breaks = date_breaks("4 months"), labels = date_format("%Y/%m")) +
  scale_y_datetime(breaks = date_breaks("1 hour"), labels = date_format("%H:%M")) +
#   scale_color_manual(name = "acc", values=c("#0C3452", "#0B5CA0", "#1A9FF9")) +
  xlab("Days (Year/month)") +
  ylab("Hours of day") +
  ggtitle("Instant messages sent/received since 2009")

print(mess.overall)
dev.off()
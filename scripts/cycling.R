# script for crunching and plotting cycling data

setwd("~/persanalytics/")
cycling <- read.csv("data/cycling.csv")

#           oooo                                                         
#           `888                                                         
#  .ooooo.   888   .ooooo.   .oooo.   ooo. .oo.   oooo  oooo  oo.ooooo.  
# d88' `"Y8  888  d88' `88b `P  )88b  `888P"Y88b  `888  `888   888' `88b 
# 888        888  888ooo888  .oP"888   888   888   888   888   888   888 
# 888   .o8  888  888    .o d8(  888   888   888   888   888   888   888 
# `Y8bod8P' o888o `Y8bod8P' `Y888""8o o888o o888o  `V88V"V8P'  888bod8P' 
#                                                              888       
#                                                              o888o      

# remove workouts without cadence data
cycling <- cycling[cycling$Total.Strokes != "--",]

# clean up formatting of these variables to make them numeric and remove
# non-numeric characters
cycling$Calories <- as.numeric(gsub(",", "", cycling$Calories))
cycling$Total.Strokes <- as.numeric(gsub(",", "", cycling$Total.Strokes))

# converting Avg.HR from factor to numeric is messy
# see:
#http://stackoverflow.com/questions/3418128/how-to-convert-a-factor-to-an-integer-numeric-without-a-loss-of-information
cycling$Avg.HR <- as.numeric(levels(cycling$Avg.HR))[cycling$Avg.HR]

# create a fake 'average gear' score by dividing total number of pedal
# strokes by total distance covered
# higher score means smaller gears used, on average
cycling$pseudoAvgGear <- cycling$Total.Strokes / cycling$Distance

#            oooo                .            
#            `888              .o8            
# oo.ooooo.   888   .ooooo.  .o888oo  .oooo.o 
#  888' `88b  888  d88' `88b   888   d88(  "8 
#  888   888  888  888   888   888   `"Y88b.  
#  888   888  888  888   888   888 . o.  )88b 
#  888bod8P' o888o `Y8bod8P'   "888" 8""888P' 
#  888                                        
# o888o                                       

library(ggplot2) # for plotting
library(RColorBrewer) # for choices of colour

png("plots/cyclingGearHR.png", width = 900)

cycling.GearHR <- ggplot(cycling, aes(x=pseudoAvgGear, y=Avg.HR)) + 
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position="none") +
  geom_point(aes(size = (1/pseudoAvgGear)+2, colour = Avg.HR)) + 
  scale_colour_continuous(low="white", high="red") +
  geom_smooth(colour = "#00BFC4", size = 1.5, alpha=.20, method = "loess") +
  xlab("Pseudo average gear score (total strokes / distance)") +
  scale_x_reverse() +
  ylab("Average heart rate (bpm)")
  
print(cycling.GearHR)

dev.off()
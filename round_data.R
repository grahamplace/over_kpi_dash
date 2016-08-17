round_file <- function(file) {
  setwd("/Users/Graham/Desktop/OneDrive/School/iXperience/Over/over_kpi_dash/data")
  data <- read.csv(file)
  data[,-1] <- round(data[,-1], digits = 2)
  
  write.csv(data, file, row.names = F)
}



setwd("/Users/Graham/Desktop/OneDrive/School/iXperience/Over/over_kpi_dash/data")

data <- read.csv(file)
data <- data[,-1]
write.csv(data, file, row.names = F)
 

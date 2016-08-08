collect_kpis <- function() {
  
  load_packages()
  
  get_auth()
  
  #create df to store all scraped values
  weekly_kpis <- data.frame(
    "new_users" = NA,
    "active_users" = NA,
    "new_designs" = NA,
    "revenue" = NA,
    "paying_users" = NA,
    "conversion_rate" = NA,
    "avg_spent" = NA,
    "completed_projects_per_user" = NA,
    "collects_per_user" = NA,
    "new_projects_per_user" = NA,
    "n_retention_1" = NA,
    "n_retention_3" = NA,
    "n_retention_7" = NA,
    "n_retention_30" = NA,
    "unbounded_retention_1" = NA,
    "unbounded_retention_3" = NA,
    "unbounded_retention_7" = NA,
    "unbounded_retention_30" = NA,
    "stickiness" = NA
  )
  
  #set up browser for all scraping
  #checkForServer(update = F)
  #startServer(args = c("-port 5556"), log = FALSE, invisible = FALSE)
  
  #assuming server is up and running from terminal or script
  browser <- remoteDriver(port = 5555)
  browser$open()
  browser$navigate("https://amplitude.com/login")
  browser$findElement(using = 'css selector', '#login-email')$sendKeysToElement(list(amp_email))
  browser$findElement(using = 'css selector', '#login-password')$sendKeysToElement(list(amp_password, key = 'enter'))
  
  #scrape and add all kpis from Amplitude
  #new users
  weekly_kpis$new_users <- new_users()
  
  #active users
  weekly_kpis$active_users <- active_users()
  
  #new designs
  weekly_kpis$new_designs <- new_designs()
  
  #revenue
  weekly_kpis$revenue <- revenue()
  
  #paying users
  weekly_kpis$paying_users <- paying_users()
  
  #conversion rate
  weekly_kpis$conversion_rate <- conversion_rate()
  
  #average spent per paying user
  weekly_kpis$avg_spent <- avg_spent()
  
  #average completed projects per user
  weekly_kpis$completed_projects_per_user <- completed_projects_per_user()
  
  #average collects per user 
  weekly_kpis$collects_per_user <- collects_per_user()
  
  #average new projects per user
  weekly_kpis$new_projects_per_user <- new_projects_per_user()
  
  #all retention data 
  weekly_kpis$n_retention_1 <- n_retention(1)
  weekly_kpis$n_retention_3 <- n_retention(3)
  weekly_kpis$n_retention_7 <- n_retention(7)
  weekly_kpis$n_retention_30 <- n_retention(30)
  weekly_kpis$unbounded_retention_1 <- unbounded_retention(1)
  weekly_kpis$unbounded_retention_3 <- unbounded_retention(3)
  weekly_kpis$unbounded_retention_7 <- unbounded_retention(7)
  weekly_kpis$unbounded_retention_30 <- unbounded_retention(30)
  
  #stickiness
  weekly_kpis$stickiness <- stickiness()
  
  #return collected data
  return(weekly_kpis)
  
}

#get amplitude login info from file, store in env. variables
get_auth <- function() {
  wd <- getwd()
  path <- paste(wd, "/auth_info.R", sep = "")
  #sourcing auth file puts login info in environment variables 
  source(path)
}

#load necessary packages for scraping 
load_packages <- function() {
  library(RSelenium)
  
}
collect_kpis <- function() {
  
  #load the packages needed to scrape 
  load_packages()
  
  #load authorization info into environment
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
  #startServer(args = c("-port 5555"), log = FALSE, invisible = FALSE)
  
  #assuming server is up and running from terminal or script
  browser <- remoteDriver(port = 5555)
  browser$open()
  browser$navigate("https://amplitude.com/login")
  browser$findElement(using = 'css selector', '#login-email')$sendKeysToElement(list(amp_email))
  browser$findElement(using = 'css selector', '#login-password')$sendKeysToElement(list(amp_password, key = 'enter'))
  
  #scrape and add all kpis from Amplitude
  #new users
  weekly_kpis$new_users <- new_users(browser)
  
  #active users
  weekly_kpis$active_users <- active_users(browser)
  
  #new designs
  weekly_kpis$new_designs <- new_designs(browser)
  
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
  weekly_kpis$n_retention_1 <- n_retention_day1(browser)
  weekly_kpis$n_retention_3 <- n_retention_day3(browser)
  weekly_kpis$n_retention_7 <- n_retention_day7(browser)
  weekly_kpis$n_retention_30 <- n_retention_day30(browser)
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
  library(rvest)
}

#weekly new users 
new_users <- function(browser) {
 
  browser$navigate("https://amplitude.com/app/146509/home?range=Last%207%20Days&i=1&m=new&vis=line")
  
  #browser$navigate("https://amplitude.com/app/146509/home/dashboards?folder=Global%20dashboards")
  
  # user_button <- browser$findElement(using = 'css selector', 'a.btn:nth-child(2)')
  # user_button$clickElement()
  # 
  # type_button <- browser$findElement(using = 'css selector', ' .main-window > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2)')
  # type_button$clickElement()
  # 
  # new_button <- browser$findElement(using = 'css selector', 'li.select2-results-dept-0:nth-child(2)')
  # new_button$clickElement()
  # 
  # daily_button <- browser$findElement(using = 'css selector', '.main-window > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1)')
  # daily_button$clickElement()
  # 
  # choice_button <- browser$findElement(using = 'css selector', 'li.select2-results-dept-0:nth-child(1)')
  # choice_button$clickElement()
  # 
  # length_button <- browser$findElement(using = 'css selector', '.main-window > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(2)')
  # length_button$clickElement()
  # 
  # last_button <- browser$findElement(using = 'css selector', 'body > div:nth-child(28) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1)')
  # last_button$clickElement()
  # 
  # last_button <- browser$findElement(using = 'css selector', 'div.xqSWtCAaz25tSo_sUapF6:nth-child(1)')
  # last_button$clickElement()
  # 
  # span_button <- browser$findElement(using = 'css selector', 'body > div:nth-child(28) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(3)')
  # span_button$clickElement()
  # 
  # span_field <- browser$findElement(using = 'css selector', '.LQWsjz7q2nMz0lwfKrrN')
  # span_field$sendKeysToElement(list("7", key = 'enter'))
  # 
  # apply_button <- browser$findElement(using = 'css selector', '  body > div:nth-child(28) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > button:nth-child(1)')
  # apply_button$clickElement()
  
  total <- 0
  
  day_1 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(1)')
  total <- total + as.integer(gsub(",", "", day_1$getElementText()[[1]]))
  
  day_2 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(2)')
  total <- total + as.integer(gsub(",", "", day_2$getElementText()[[1]]))
  
  day_3 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(3)')
  total <- total + as.integer(gsub(",", "", day_3$getElementText()[[1]]))
  
  day_4 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(4)')
  total <- total + as.integer(gsub(",", "", day_4$getElementText()[[1]]))
  
  day_5 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(5)')
  total <- total + as.integer(gsub(",", "", day_5$getElementText()[[1]]))
  
  day_6 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(6)')
  total <- total + as.integer(gsub(",", "", day_6$getElementText()[[1]]))
  
  day_7 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(7)')
  total <- total + as.integer(gsub(",", "", day_7$getElementText()[[1]]))
  
  return(total)
}

#weekly active users 
active_users <- function(browser) {
  
  browser$navigate("https://amplitude.com/app/146509/home?range=Last%207%20Days&i=1&m=active&vis=line")
  
  total <- 0
  
  day_1 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(1)')
  total <- total + as.integer(gsub(",", "", day_1$getElementText()[[1]]))
  
  day_2 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(2)')
  total <- total + as.integer(gsub(",", "", day_2$getElementText()[[1]]))
  
  day_3 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(3)')
  total <- total + as.integer(gsub(",", "", day_3$getElementText()[[1]]))
  
  day_4 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(4)')
  total <- total + as.integer(gsub(",", "", day_4$getElementText()[[1]]))
  
  day_5 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(5)')
  total <- total + as.integer(gsub(",", "", day_5$getElementText()[[1]]))
  
  day_6 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(6)')
  total <- total + as.integer(gsub(",", "", day_6$getElementText()[[1]]))
  
  day_7 <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(7)')
  total <- total + as.integer(gsub(",", "", day_7$getElementText()[[1]]))
  
  return(total)
}


#weekly number of paying users 
paying_users <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/revenue/summary?e=%7B%22event_type%22:%22revenue_amount%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&m=paying&sset=%7B%22segmentIndex%22:0%7D&vis=line&range=Last%207%20Days&i=1")
  
  total <- 0
  
  day_1 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div')
  total <- total + as.integer(gsub(",", "", day_1$getElementText()[[1]]))
  
  day_2 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > div')
  total <- total + as.integer(gsub(",", "", day_2$getElementText()[[1]]))
  
  day_3 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(3) > div:nth-child(2) > div')
  total <- total + as.integer(gsub(",", "", day_3$getElementText()[[1]]))
  
  day_4 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(4) > div:nth-child(2) > div')
  total <- total + as.integer(gsub(",", "", day_4$getElementText()[[1]]))
  
  day_5 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(5) > div:nth-child(2) > div')
  total <- total + as.integer(gsub(",", "", day_5$getElementText()[[1]]))
  
  day_6 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(6) > div:nth-child(2) > div')
  total <- total + as.integer(gsub(",", "", day_6$getElementText()[[1]]))
  
  day_7 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(7) > div:nth-child(2) > div')
  total <- total + as.integer(gsub(",", "", day_7$getElementText()[[1]]))
  
  return(total)
}

stickiness <- function(browser, monthly_active) {
  browser$navigate("https://amplitude.com/app/146509/home?range=Last%207%20Days&i=1&m=active&vis=line")
  
  daily_active <- browser$findElement(using = 'css selector', '.time-series-table-right > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(7)')
  daily_active <-  as.integer(gsub(",", "", daily_active$getElementText()[[1]]))
  
  stickiness <- daily_active / monthly_active
  
  return(stickiness)
}

n_retention_day1 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=nday&range=Last%203%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  n_reten <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > div')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

n_retention_day3 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=nday&range=Last%205%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(4) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

n_retention_day7 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=nday&range=Last%209%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(8) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

n_retention_day30 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=nday&range=Last%2032%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  n_reten <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(31) > div:nth-child(2) > div')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

unbounded_retention_day1 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=rolling&range=Last%2030%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

unbounded_retention_day3 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=nday&range=Last%2032%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(4) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

unbounded_retention_day7 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=nday&range=Last%2032%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(8) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

unbounded_retention_day30 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=rolling&range=Last%2060%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(31) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}
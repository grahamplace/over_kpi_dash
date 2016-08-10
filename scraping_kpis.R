collect_kpis <- function() {
  
  #load the packages needed to scrape 
  load_packages()
  
  #load authorization info into environment
  get_auth()
  
  #create df to store all scraped values
  weekly_kpis <- data.frame(
    "new_users" = NA,
    "weekly_active_users" = NA,
    "monthly_active_users" = NA,
    "avg_daily_active_users" = NA,
    "completed_projects" = NA,
    "revenue" = NA,
    "weekly_paying_users" = NA,
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
  Sys.sleep(15)
  browser$findElement(using = 'css selector', '#login-email')$sendKeysToElement(list(amp_email))
  browser$findElement(using = 'css selector', '#login-password')$sendKeysToElement(list(amp_password, key = 'enter'))
  Sys.sleep(15)
  
  #scrape and add all kpis from Amplitude
  
  #new users
  weekly_kpis$new_users <- new_users(browser)
  
  #get values for 3 cohorts
  cohorts <- get_cohorts(browser)
  
  #get weekly active from scraped cohorts data
  weekly_kpis$weekly_active_users <- cohorts$weekly_active
  
  #get monthly active from scraped cohorts data
  weekly_kpis$monthly_active_users <- cohorts$monthly_active
  
  #avg daily active users
  weekly_kpis$avg_daily_active_users <- avg_daily_active_users(browser)
  
  #completed projects made in last week
  weekly_kpis$completed_projects <- completed_projects(browser)
  
  #revenue
  weekly_kpis$revenue <- revenue(browser)
  
  #weekly paying users
  weekly_kpis$weekly_paying_users <- cohorts$weekly_paying
  
  #conversion rate
  weekly_kpis$conversion_rate <- 100*weekly_kpis$weekly_paying_users/weekly_kpis$weekly_active_users
  
  #average spent per paying user
  weekly_kpis$avg_spent <- weekly_kpis$revenue/weekly_kpis$weekly_paying_users
  
  #average completed projects per user
  weekly_kpis$completed_projects_per_user <- weekly_kpis$completed_projects/weekly_kpis$weekly_active_users
  
  #average collects per user 
  weekly_kpis$collects_per_user <- collects_per_user(browser, weekly_kpis$weekly_active_users)
  
  #average new projects per user
  weekly_kpis$new_projects_per_user <- new_projects_per_user(browser, weekly_kpis$weekly_active_users)
  
  #all retention data 
  weekly_kpis$n_retention_1 <- n_retention_day1(browser)
  weekly_kpis$n_retention_3 <- n_retention_day3(browser)
  weekly_kpis$n_retention_7 <- n_retention_day7(browser)
  weekly_kpis$n_retention_30 <- n_retention_day30(browser)
  weekly_kpis$unbounded_retention_1 <- unbounded_retention_day1(browser)
  weekly_kpis$unbounded_retention_3 <- unbounded_retention_day3(browser)
  weekly_kpis$unbounded_retention_7 <- unbounded_retention_day7(browser)
  weekly_kpis$unbounded_retention_30 <- unbounded_retention_day30(browser)
  
  #stickeness
  weekly_kpis$stickiness <- 100*weekly_kpis$avg_daily_active_users/weekly_kpis$monthly_active_users
  
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
  Sys.sleep(10)
  
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

#scrape and sort 3 cohort values 
get_cohorts <- function(browser) {
  
  browser$navigate("https://amplitude.com/app/146509/cohorts/list?folder=My%20cohorts")
  Sys.sleep(10)
  
  recompute1 <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(1) > td:nth-child(4)')
  recompute1$clickElement()
  Sys.sleep(10)
  
  recompute2 <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(2) > td:nth-child(4)')
  recompute2$clickElement()
  Sys.sleep(10)
  
  recompute3 <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(3) > td:nth-child(4)')
  recompute3$clickElement()
  Sys.sleep(10)
  
  
  
  nums <- 1:3
  nums[1] <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(1) > td:nth-child(2)')$getElementText()
  nums[2] <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(2) > td:nth-child(2)')$getElementText()
  nums[3] <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(3) > td:nth-child(2)')$getElementText()
    
  nums <- sort(as.numeric(gsub(",", "", nums)))
  
  df <- data.frame("weekly_paying" = nums[1], "weekly_active" = nums[2], "monthly_active" = nums[3])
  
  return(df)
}

#daily_active users 
avg_daily_active_users <- function(browser) {
  
  browser$navigate("https://amplitude.com/app/146509/home?range=Last%207%20Days&i=1&m=active&vis=line")
  Sys.sleep(10)
  
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
  
  return(total/7)
  
}

#weekly completed projects
completed_projects <- function(browser) {
  
  browser$navigate("https://amplitude.com/app/146509/events/summary?range=Last%207%20Days&i=1&m=totals&vis=table&e=creating%20-%20completed:share")
  Sys.sleep(10)
  
  total <- 0
  
  day_1 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(1)')
  total <- total + as.integer(gsub(",", "", day_1$getElementText()[[1]]))
  
  day_2 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(2)')
  total <- total + as.integer(gsub(",", "", day_2$getElementText()[[1]]))
  
  day_3 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(3)')
  total <- total + as.integer(gsub(",", "", day_3$getElementText()[[1]]))
  
  day_4 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(4)')
  total <- total + as.integer(gsub(",", "", day_4$getElementText()[[1]]))
  
  day_5 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(5)')
  total <- total + as.integer(gsub(",", "", day_5$getElementText()[[1]]))
  
  day_6 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(6)')
  total <- total + as.integer(gsub(",", "", day_6$getElementText()[[1]]))
  
  day_7 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(7)')
  total <- total + as.integer(gsub(",", "", day_7$getElementText()[[1]]))
  
  return(total)
}

#weekly number of paying users 
paying_users <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/revenue/summary?e=%7B%22event_type%22:%22revenue_amount%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&m=paying&sset=%7B%22segmentIndex%22:0%7D&vis=line&range=Last%207%20Days&i=1")
  Sys.sleep(10)
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

#weekly revenue
revenue <- function(browser) {
  
  browser$navigate("https://amplitude.com/app/146509/revenue/summary?e=%7B%22event_type%22:%22revenue_amount%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&m=total&sset=%7B%22segmentIndex%22:0%7D&vis=line&range=Last%207%20Days&i=1")
  Sys.sleep(10)
  
  total <- 0
  
  day_1 <- browser$findElement(using = 'css selector', '._-RJAwFhEBtcoTxxZMRk8L > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2)')
  total <- total + as.integer(gsub("\\$", "", gsub(",", "", day_1$getElementText()[[1]])))
  
  day_2 <- browser$findElement(using = 'css selector', '._-RJAwFhEBtcoTxxZMRk8L > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(2) > div:nth-child(2)')
  total <- total + as.integer(gsub("\\$", "", gsub(",", "", day_2$getElementText()[[1]])))
  
  day_3 <- browser$findElement(using = 'css selector', '._-RJAwFhEBtcoTxxZMRk8L > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(3) > div:nth-child(2)')
  total <- total + as.integer(gsub("\\$", "", gsub(",", "", day_3$getElementText()[[1]])))
  
  day_4 <- browser$findElement(using = 'css selector', '._-RJAwFhEBtcoTxxZMRk8L > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(4) > div:nth-child(2)')
  total <- total + as.integer(gsub("\\$", "", gsub(",", "", day_4$getElementText()[[1]])))
  
  day_5 <- browser$findElement(using = 'css selector', '._-RJAwFhEBtcoTxxZMRk8L > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(5) > div:nth-child(2)')
  total <- total + as.integer(gsub("\\$", "", gsub(",", "", day_5$getElementText()[[1]])))
  
  day_6 <- browser$findElement(using = 'css selector', '._-RJAwFhEBtcoTxxZMRk8L > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(6) > div:nth-child(2)')
  total <- total + as.integer(gsub("\\$", "", gsub(",", "", day_6$getElementText()[[1]])))
  
  day_7 <- browser$findElement(using = 'css selector', '._-RJAwFhEBtcoTxxZMRk8L > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(7) > div:nth-child(2)')
  total <- total + as.integer(gsub("\\$", "", gsub(",", "", day_7$getElementText()[[1]])))
  
  return(total)
}

#weekly collects per user
collects_per_user <- function(browser, active_users) {
  
  browser$navigate("https://amplitude.com/app/146509/events/summary?range=Last%207%20Days&i=1&m=totals&vis=table&e=collecting%20-%20tapped:collect")
  Sys.sleep(10)
  
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
  
  return(total/active_users)
}

#average new projects per user
new_projects_per_user <- function(browser, active_users){
  
  browser$navigate("https://amplitude.com/app/146509/events/summary?range=Last%207%20Days&i=1&m=totals&vis=table&e=creating%20-%20tapped:new_project")
  Sys.sleep(10)
  
  total <- 0
  
  day_1 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(1)')
  total <- total + as.integer(gsub(",", "", day_1$getElementText()[[1]]))
  
  day_2 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(2)')
  total <- total + as.integer(gsub(",", "", day_2$getElementText()[[1]]))
  
  day_3 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(3)')
  total <- total + as.integer(gsub(",", "", day_3$getElementText()[[1]]))
  
  day_4 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(4)')
  total <- total + as.integer(gsub(",", "", day_4$getElementText()[[1]]))
  
  day_5 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(5)')
  total <- total + as.integer(gsub(",", "", day_5$getElementText()[[1]]))
  
  day_6 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(6)')
  total <- total + as.integer(gsub(",", "", day_6$getElementText()[[1]]))
  
  day_7 <- browser$findElement(using = 'css selector', '.dragger > tr:nth-child(1) > td:nth-child(7)')
  total <- total + as.integer(gsub(",", "", day_7$getElementText()[[1]]))
  
  
  return(total/active_users)
}

n_retention_day1 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=nday&range=Last%203%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  Sys.sleep(10)
  
  n_reten <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > div')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

n_retention_day3 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=nday&range=Last%205%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(10)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(4) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

n_retention_day7 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=nday&range=Last%209%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(10)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(8) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

n_retention_day30 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=nday&range=Last%2032%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(10)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(31) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

unbounded_retention_day1 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=rolling&range=Last%2030%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  Sys.sleep(10)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

unbounded_retention_day3 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=rolling&range=Last%2030%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(10)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(4) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
  
}

unbounded_retention_day7 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=rolling&range=Last%2030%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(10)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(8) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

unbounded_retention_day30 <- function(browser) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=rolling&range=Last%2060%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(10)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(31) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
}

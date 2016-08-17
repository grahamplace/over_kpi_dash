#!/usr/bin/Rscript
collect_kpis <- function() {
  print("In collect_kpis...")
  #for EC2 instance
  setwd("/home/ubuntu/over")
  
  print("loading packages...")
  #load the packages needed to scrape 
  load_packages()
  
  print("getting auth info...")
  #load authorization info into environment
  get_auth()
  
  print("creating dataframe...")
  #create df to store all scraped values
  weekly_kpis <- data.frame(
    "date" = Sys.Date(),
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
  
  print("checking for server...")
  #set up browser for all scraping
  checkForServer()
  
  print("starting server...")
  startServer()
  
  print("calling remote driver...")
  browser <- remoteDriver(browser = "phantomjs")
  
  print("opening browser...")
  tryCatch({
    browser$open()
  }, error  = function(e) {
    print("unable to open browser, trying again...")
    browser$open()
  }, finally = {
    
  }
  )
 
  print("navigating to amplitude...")
  tryCatch({
    browser$navigate("https://amplitude.com/login")
    Sys.sleep(20)
    print("logging into amplitude...")
    browser$findElement(using = 'css selector', '#login-email')$sendKeysToElement(list(amp_email))
    browser$findElement(using = 'css selector', '#login-password')$sendKeysToElement(list(amp_password, key = 'enter'))
    Sys.sleep(20)
  }, error  = function(e) {
    browser$navigate("https://amplitude.com/login")
    Sys.sleep(60)
    print("error thrown: logging into amplitude with longer wait time...")
    browser$findElement(using = 'css selector', '#login-email')$sendKeysToElement(list(amp_email))
    browser$findElement(using = 'css selector', '#login-password')$sendKeysToElement(list(amp_password, key = 'enter'))
    Sys.sleep(60)
  }, finally = {
    
  }
  )
  
  #scrape and add all kpis from Amplitude
  #new users
  tryCatch({
    weekly_kpis$new_users <- new_users(browser, 20)
  }, error  = function(e) {
    print("error first time scraping new users, trying with longer wait time...")
    weekly_kpis$new_users <- new_users(browser, 60)
  }, finally = {
  }
  )

  
  #get values for 3 cohorts
  print("scraping cohorts...")
  tryCatch({
    cohorts <- get_cohorts(browser, 20)
  }, error  = function(e) {
    print("error first time scraping cohorts, trying with longer wait time...")
    cohorts <- get_cohorts(browser, 60)
  }, finally = {
  }
  )

  
  #get weekly active from scraped cohorts data
  weekly_kpis$weekly_active_users <- cohorts$weekly_active
  print("weekly active users:")
  print(cohorts$weekly_active)

  
  #get monthly active from scraped cohorts data
  weekly_kpis$monthly_active_users <- cohorts$monthly_active
  print("monthly active users:")
  print(cohorts$monthly_active)

  
  #avg daily active users
  tryCatch({
    weekly_kpis$avg_daily_active_users <- avg_daily_active_users(browser, 20)
  }, error  = function(e) {
    print("error first time scraping daily active users, trying with longer wait time...")
    weekly_kpis$avg_daily_active_users <- avg_daily_active_users(browser, 60)
  }, finally = {
  }
  )

  
  #completed projects made in last week
  tryCatch({
    weekly_kpis$completed_projects <- completed_projects(browser, 20)
  }, error  = function(e) {
    print("error first time scraping completed projects, trying with longer wait time...")
    weekly_kpis$completed_projects <- completed_projects(browser, 60)
  }, finally = {
  }
  )

  
  #revenue
  tryCatch({
    weekly_kpis$revenue <- revenue(browser, 20)
  }, error  = function(e) {
    print("error first time scraping revenue, trying with longer wait time...")
    weekly_kpis$revenue <- revenue(browser, 60)
  }, finally = {
  }
  )

  
  #weekly paying users
  weekly_kpis$weekly_paying_users <- cohorts$weekly_paying
  print("weekly paying users:")
  print(cohorts$weekly_paying)
  
  #conversion rate
  print("conversion rate:")
  print(round(100*weekly_kpis$weekly_paying_users/weekly_kpis$weekly_active_users, digits = 2))
  weekly_kpis$conversion_rate <- round(100*weekly_kpis$weekly_paying_users/weekly_kpis$weekly_active_users, digits = 2)
  
  #average spent per paying user
  print("avg spent per paying user:")
  print(round(weekly_kpis$revenue/weekly_kpis$weekly_paying_users, digits = 2))
  weekly_kpis$avg_spent <- round(weekly_kpis$revenue/weekly_kpis$weekly_paying_users, digits = 2)
  
  #average completed projects per user
  print("completed projects per user:")
  print(round(weekly_kpis$completed_projects/weekly_kpis$weekly_active_users, digits = 2))
  weekly_kpis$completed_projects_per_user <- round(weekly_kpis$completed_projects/weekly_kpis$weekly_active_users, digits = 2)
  
  #average collects per user 
  print("collects per user:")
  tryCatch({
    weekly_kpis$collects_per_user <- collects_per_user(browser, weekly_kpis$weekly_active_users, 20)
  }, error  = function(e) {
    print("error first time collects per user, trying with longer wait time...")
    tryCatch({
      weekly_kpis$collects_per_user <- collects_per_user(browser, weekly_kpis$weekly_active_users, 60)
    }, error  = function(e) {
      print("error second time collects per user, trying with even longer wait time...")
      weekly_kpis$collects_per_user <- collects_per_user(browser, weekly_kpis$weekly_active_users, 120)
    }, finally = {
    }
    )
  }, finally = {
  }
  )
  
  #average new projects per user
  print("average new projects per user:")
  tryCatch({
    weekly_kpis$new_projects_per_user <- new_projects_per_user(browser, weekly_kpis$weekly_active_users, 20)
  }, error  = function(e) {
    print("error first time collects per user, trying with longer wait time...")
    weekly_kpis$new_projects_per_user <- new_projects_per_user(browser, weekly_kpis$weekly_active_users, 60)
  }, finally = {
  }
  )

  
  #all retention data 
  tryCatch({
    weekly_kpis$n_retention_1 <- n_retention_day1(browser, 20)
    weekly_kpis$n_retention_3 <- n_retention_day3(browser, 20)
    weekly_kpis$n_retention_7 <- n_retention_day7(browser, 20)
    weekly_kpis$n_retention_30 <- n_retention_day30(browser, 20)
    weekly_kpis$unbounded_retention_1 <- unbounded_retention_day1(browser, 20)
    weekly_kpis$unbounded_retention_3 <- unbounded_retention_day3(browser, 20)
    weekly_kpis$unbounded_retention_7 <- unbounded_retention_day7(browser, 20)
    weekly_kpis$unbounded_retention_30 <- unbounded_retention_day30(browser, 20)
  }, error  = function(e) {
    print("error first time scraping retention, trying with longer wait time...")
    weekly_kpis$n_retention_1 <- n_retention_day1(browser, 60)
    weekly_kpis$n_retention_3 <- n_retention_day3(browser, 60)
    weekly_kpis$n_retention_7 <- n_retention_day7(browser, 60)
    weekly_kpis$n_retention_30 <- n_retention_day30(browser, 60)
    weekly_kpis$unbounded_retention_1 <- unbounded_retention_day1(browser, 60)
    weekly_kpis$unbounded_retention_3 <- unbounded_retention_day3(browser, 60)
    weekly_kpis$unbounded_retention_7 <- unbounded_retention_day7(browser, 60)
    weekly_kpis$unbounded_retention_30 <- unbounded_retention_day30(browser, 60)
  }, finally = {
  }
  )
  
  
  #stickeness
  print("stickiness:")
  print(round(100*weekly_kpis$avg_daily_active_users/weekly_kpis$monthly_active_users, digits = 2))
  weekly_kpis$stickiness <- round(100*weekly_kpis$avg_daily_active_users/weekly_kpis$monthly_active_users, digits = 2)
  
  #return collected data
  print("Done scraping, returning dataframe of collected values")
  
  #print("stopping server...")
  #browser$closeServer()
  
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
new_users <- function(browser, n) {
 
  browser$navigate("https://amplitude.com/app/146509/home?range=Last%207%20Days&i=1&m=new&vis=line")
  Sys.sleep(n)
  
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
  
  print("new users:")
  print(total)

  return(total)
}

#scrape and sort 3 cohort values 
get_cohorts <- function(browser, n) {
  
  browser$navigate("https://amplitude.com/app/146509/cohorts/list?folder=My%20cohorts")
  Sys.sleep(n)
  
  recompute1 <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(1) > td:nth-child(4)')
  recompute1$clickElement()
  Sys.sleep(n)
  
  recompute2 <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(2) > td:nth-child(4)')
  recompute2$clickElement()
  Sys.sleep(n)
  
  recompute3 <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(3) > td:nth-child(4)')
  recompute3$clickElement()
  Sys.sleep(n)
  
  
  
  nums <- 1:3
  nums[1] <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(1) > td:nth-child(2)')$getElementText()
  nums[2] <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(2) > td:nth-child(2)')$getElementText()
  nums[3] <- browser$findElement(using = 'css selector', 'tr.ng-scope:nth-child(3) > td:nth-child(2)')$getElementText()
    
  nums <- sort(as.numeric(gsub(",", "", nums)))
  
  df <- data.frame("weekly_paying" = nums[1], "weekly_active" = nums[2], "monthly_active" = nums[3])
  
  return(df)
}

#daily_active users 
avg_daily_active_users <- function(browser, n) {
  
  browser$navigate("https://amplitude.com/app/146509/home?range=Last%207%20Days&i=1&m=active&vis=line")
  Sys.sleep(n)
  
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
  
  print("average daily active users: ")
  print(round(total/7, digits = 2))
  return(round(total/7, digits = 2))
  
}

#weekly completed projects
completed_projects <- function(browser, n) {
  
  browser$navigate("https://amplitude.com/app/146509/events/summary?range=Last%207%20Days&i=1&m=totals&vis=table&e=creating%20-%20completed:share")
  Sys.sleep(n)
  
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
  
  print("completed projects: ")
  print(total)
  return(total)
}

#weekly revenue
revenue <- function(browser, n) {
  
  browser$navigate("https://amplitude.com/app/146509/revenue/summary?e=%7B%22event_type%22:%22revenue_amount%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&m=total&sset=%7B%22segmentIndex%22:0%7D&vis=line&range=Last%207%20Days&i=1")
  Sys.sleep(n)
  
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
  
  print("revenue: ")
  print(total)
  return(total)
}

#weekly collects per user
collects_per_user <- function(browser, active_users, n) {
  
  browser$navigate("https://amplitude.com/app/146509/events/summary?range=Last%207%20Days&i=1&m=totals&vis=table&e=collecting%20-%20tapped:collect")
  Sys.sleep(n)
  
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
  
  print(round(total/active_users, digits = 2))
  return(round(total/active_users, digits = 2))
}

#average new projects per user
new_projects_per_user <- function(browser, active_users, n){
  
  browser$navigate("https://amplitude.com/app/146509/events/summary?range=Last%207%20Days&i=1&m=totals&vis=table&e=creating%20-%20tapped:new_project")
  Sys.sleep(n)
  
  total <- 0
  
  day_1 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > div:nth-child(1) > div.loading-wrapper.ng-isolate-scope > div.loading-window > div.window-content.chart.chart-type-control.ng-scope > div.table-fixed-wrapper.events-summary-table-wrapper.ng-scope > div.table-fixed-wrapper-right > table > tbody > tr > td:nth-child(1)')
  total <- total + as.integer(gsub(",", "", day_1$getElementText()[[1]]))
  
  day_2 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > div:nth-child(1) > div.loading-wrapper.ng-isolate-scope > div.loading-window > div.window-content.chart.chart-type-control.ng-scope > div.table-fixed-wrapper.events-summary-table-wrapper.ng-scope > div.table-fixed-wrapper-right > table > tbody > tr > td:nth-child(2)')
  total <- total + as.integer(gsub(",", "", day_2$getElementText()[[1]]))
  
  day_3 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > div:nth-child(1) > div.loading-wrapper.ng-isolate-scope > div.loading-window > div.window-content.chart.chart-type-control.ng-scope > div.table-fixed-wrapper.events-summary-table-wrapper.ng-scope > div.table-fixed-wrapper-right > table > tbody > tr > td:nth-child(3)')
  total <- total + as.integer(gsub(",", "", day_3$getElementText()[[1]]))
  
  day_4 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > div:nth-child(1) > div.loading-wrapper.ng-isolate-scope > div.loading-window > div.window-content.chart.chart-type-control.ng-scope > div.table-fixed-wrapper.events-summary-table-wrapper.ng-scope > div.table-fixed-wrapper-right > table > tbody > tr > td:nth-child(4)')
  total <- total + as.integer(gsub(",", "", day_4$getElementText()[[1]]))
  
  day_5 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > div:nth-child(1) > div.loading-wrapper.ng-isolate-scope > div.loading-window > div.window-content.chart.chart-type-control.ng-scope > div.table-fixed-wrapper.events-summary-table-wrapper.ng-scope > div.table-fixed-wrapper-right > table > tbody > tr > td:nth-child(5)')
  total <- total + as.integer(gsub(",", "", day_5$getElementText()[[1]]))
  
  day_6 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > div:nth-child(1) > div.loading-wrapper.ng-isolate-scope > div.loading-window > div.window-content.chart.chart-type-control.ng-scope > div.table-fixed-wrapper.events-summary-table-wrapper.ng-scope > div.table-fixed-wrapper-right > table > tbody > tr > td:nth-child(6)')
  total <- total + as.integer(gsub(",", "", day_6$getElementText()[[1]]))
  
  day_7 <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > div:nth-child(1) > div.loading-wrapper.ng-isolate-scope > div.loading-window > div.window-content.chart.chart-type-control.ng-scope > div.table-fixed-wrapper.events-summary-table-wrapper.ng-scope > div.table-fixed-wrapper-right > table > tbody > tr > td:nth-child(7)')
  total <- total + as.integer(gsub(",", "", day_7$getElementText()[[1]]))
  
  print(round(total/active_users, digits = 2))
  return(round(total/active_users, digits = 2))
}

n_retention_day1 <- function(browser, n) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=nday&range=Last%203%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  Sys.sleep(n)
  
  n_reten <- browser$findElement(using = 'css selector', '#main > div > div.main-content.ng-scope > div > div.ng-scope > react-component > div > div:nth-child(3) > div:nth-child(2) > div > div > div > div > div:nth-child(2) > div > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > div')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
  
  print("n day retention (1): ")
  print(n_reten)
  return(n_reten)
}

n_retention_day3 <- function(browser, n) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=nday&range=Last%205%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(n)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(4) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
  
  print("n day retention (3): ")
  print(n_reten)
  return(n_reten)
}

n_retention_day7 <- function(browser, n) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=nday&range=Last%209%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(n)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(8) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
  
  print("n day retention (7): ")
  print(n_reten)
  return(n_reten)
}

n_retention_day30 <- function(browser, n) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=nday&range=Last%2032%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(n)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(31) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
  
  print("n day retention (30): ")
  print(n_reten)
  return(n_reten)
}

unbounded_retention_day1 <- function(browser, n) {
  browser$navigate("https://amplitude.com/app/146509/retention?se={%22event_type%22:%22_new%22,%22filters%22:[],%22group_by%22:[]}&re={%22event_type%22:%22_active%22,%22filters%22:[],%22group_by%22:[]}&cg=User&rm=rolling&range=Last%2030%20Days&i=1&sset={%22segmentIndex%22:0}&vis=line")
  Sys.sleep(n)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
  
  print("unbounded retention (1): ")
  print(n_reten)
  return(n_reten)
}

unbounded_retention_day3 <- function(browser, n) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=rolling&range=Last%2030%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(n)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(4) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
  
  print("unbounded retention (3): ")
  print(n_reten)
  return(n_reten)
}

unbounded_retention_day7 <- function(browser, n) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=rolling&range=Last%2030%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(n)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(8) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
  
  print("unbounded retention (7): ")
  print(n_reten)
  return(n_reten)
}

unbounded_retention_day30 <- function(browser, n) {
  browser$navigate("https://amplitude.com/app/146509/retention?se=%7B%22event_type%22:%22_new%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&re=%7B%22event_type%22:%22_active%22,%22filters%22:%5B%5D,%22group_by%22:%5B%5D%7D&cg=User&rm=rolling&range=Last%2060%20Days&i=1&sset=%7B%22segmentIndex%22:0%7D&vis=line")
  Sys.sleep(n)
  
  n_reten <- browser$findElement(using = 'css selector', 'react-component.ng-scope > div:nth-child(1) > div:nth-child(3) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(31) > div:nth-child(2) > div:nth-child(1)')
  n_reten <- as.numeric(gsub("%", "", n_reten$getElementText()[[1]]))
  
  print("unbounded retention (30): ")
  print(n_reten)
  return(n_reten)
}

#script 
print(Sys.time())
print("starting script...")
print("calling collect_kpis()...")
today_data <- collect_kpis()
print("creating date file names...")
today <- Sys.Date()
today_file <- paste(today, ".csv", sep ="")
last_week <- today - 7
last_week_file <- paste(last_week, ".csv", sep ="")

print("changing working directory to stored data folder...")
setwd("/home/ubuntu/over/data")
print("reading last week's data in...")
last_week_data <- read.csv(last_week_file)

#to_remove <- today - 8
#file_to_remove <- paste(to_remove, ".csv", sep = "")
#if (file.exists(file_to_remove)) file.remove(file_to_remove)

print("combining last week and this week...")
data <- rbind(today_data, last_week_data[1,])

print("writing csv...")
write.csv(data, today_file, row.names = F)
print(Sys.time())
print("Done. Today's CSV is written!")



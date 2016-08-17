require 'csv' 
require 'date'

SCHEDULER.every '20s', :first_in => 0 do |job|

  today = Time.now.strftime("%Y-%m-%d")
  today_file = today + ".csv"

  path = '/Users/Graham/Desktop/OneDrive/School/iXperience/Over/over_kpi_dash/data/' + today_file

  metrics = CSV.read(path)
  
  current_new_users = metrics[1][1]
  last_new_users = metrics[2][1]

  current_active_users = metrics[1][2]
  last_active_users = metrics[2][2]

  current_completed_projects = metrics[1][5]
  last_completed_projects = metrics[2][5]

  current_revenue = metrics[1][6]
  last_revenue = metrics[2][6]

  current_paying_users = metrics[1][7]
  last_paying_users = metrics[2][7] 

  current_conversion_rate = metrics[1][8]
  last_conversion_rate = metrics[2][8] 

  current_avg_spent = metrics[1][9]
  last_avg_spent = metrics[2][9] 

  current_projects_per_user = metrics[1][10]
  last_projects_per_user = metrics[2][10] 

  current_collects_per_user = metrics[1][11]
  last_collects_per_user = metrics[2][11] 

  current_new_projects_per_user = metrics[1][12]
  last_new_projects_per_user = metrics[2][12] 

  current_n_1 = metrics[1][13]
  last_n_1 = metrics[2][13] 

  current_n_3 = metrics[1][14]
  last_n_3 = metrics[2][14] 

  current_n_7 = metrics[1][15]
  last_n_7 = metrics[2][15] 

  current_n_30 = metrics[1][16]
  last_n_30 = metrics[2][16] 


  current_u_1 = metrics[1][17]
  last_u_1 = metrics[2][17] 

  current_u_3 = metrics[1][18]
  last_u_3 = metrics[2][18] 

  current_u_7 = metrics[1][19]
  last_u_7 = metrics[2][19] 

  current_u_30 = metrics[1][20]
  last_u_30 = metrics[2][20] 

  current_stickiness = metrics[1][21]
  last_stickiness = metrics[2][21] 

  black = 1
  default = 0


  send_event('today_date', {value: today})

  send_event('new_users', {current: current_new_users, last: last_new_users, color: black})

  send_event('active_users', {current: current_active_users, last: last_active_users, color: default})

  send_event('completed_projects', {current: current_completed_projects, last: last_completed_projects, color: default})
  
  send_event('revenue', {current: current_revenue, last: last_revenue, color: default})

  send_event('paying_users', {current: current_paying_users, last: last_paying_users, color: default})

  send_event('conversion_rate', {current: current_conversion_rate, last: last_conversion_rate, color: default})

  send_event('avg_spent', {current: current_avg_spent, last: last_avg_spent })

  send_event('projects_per_user', {current: current_projects_per_user, last: last_projects_per_user, color: default})

  send_event('collects_per_user', {current: current_collects_per_user, last: last_collects_per_user, color: default})

  send_event('new_projects_per_user', {current: current_new_projects_per_user, last: last_new_projects_per_user, color: default})

  send_event('n_retention', {new_1: current_n_1, old_1: last_n_1, new_3: current_n_3, old_3: last_n_3, new_7: current_n_7, old_7: last_n_7, new_30: current_n_30, old_30: last_n_30, color: default})

  send_event('u_retention', {new_1: current_u_1, old_1: last_u_1, new_3: current_u_3, old_3: last_u_3, new_7: current_u_7, old_7: last_u_7, new_30: current_u_30, old_30: last_u_30, color: default})

  send_event('stickiness', {current: current_stickiness, last: last_stickiness, color: default})

end

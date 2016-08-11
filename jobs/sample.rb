require 'csv'    
current_valuation = 0
current_karma = 0

SCHEDULER.every '15s' do
  grades = CSV.read('/Users/Graham/Desktop/OneDrive/School/iXperience/Over/sweet_dashboard_project/jobs/test.csv')
  last_valuation = current_valuation
  last_karma     = current_karma
  current_valuation = grades[1][1].to_i
  current_karma     = rand(200000)

  send_event('valuation', { current: current_valuation, last: last_valuation })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('synergy',   { value: rand(100) })
end

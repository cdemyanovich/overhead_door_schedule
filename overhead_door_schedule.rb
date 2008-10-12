require 'hpricot'
require 'open-uri'
require 'icalendar'

calendar = Icalendar::Calendar.new

schedule = Hpricot(open("http://ezleagues.ezfacility.com/team.aspx?team_id=341983"))

games = schedule.search('table#ctl00_C_Schedule1_GridView1 > tr.RowStyle | table#ctl00_C_Schedule1_GridView1 > tr.AlternateRowStyle')
games.each do |game|
  raw_details = game.children_of_type('td')
  details = raw_details.map { |d| d.inner_text.to_s.strip }
  
  next if details[4] == "Final" # skip games already played
  
  game_date_regex = /\w{3}-(\w{3}) (\d{1,2})/
  match_data = game_date_regex.match(details[0])
  
  raise ArgumentError, "invalid game date: #{details[0]}" if match_data.nil?
  
  month, day = match_data[1], match_data[2]
  year = %w(Jan Feb Mar).include?(month) ? 2009 : 2008
  
  event = Icalendar::Event.new
  event.summary = "#{details[1]} vs. #{details[3]}"
  event.location = "S2: #{details[5]}"
  event.dtstart = DateTime.parse("#{month} #{day}, #{year} #{details[4]}")
  event.duration = "PT1H" # 1 hour
    
  calendar.add_event(event)
end

File.open('overhead_door_fall_2008_09.ics', 'w') do |file|
  file.puts calendar.to_ical
end
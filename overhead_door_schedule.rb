require 'hpricot'
require 'open-uri'
require 'icalendar'

calendar = Icalendar::Calendar.new

schedule = Hpricot(open("http://ezleagues.ezfacility.com/team.aspx?team_id=341983"))

games = schedule.search('table#ctl00_C_Schedule1_GridView1 > tr.RowStyle | table#ctl00_C_Schedule1_GridView1 > tr.AlternateRowStyle')
games.each do |game|
  raw_details = game.children_of_type('td')
  details = raw_details.map { |d| d.inner_text.to_s.strip }
  # details.each_with_index { |d, i| puts "[#{i}] = #{d}" }
  event = Icalendar::Event.new
  event.summary = "#{details[3]} @ #{details[1]}"
  event.location = "Twin Star: #{details[5]}"
  event.dtstart = DateTime.parse("#{details[0]} at #{details[4]}")
  event.duration = "PT1H" # 1 hour
    
  calendar.add_event(event)
end

File.open('overhead_door_fall_2008_09.ics', 'w') do |file|
  file.puts calendar.to_ical
end
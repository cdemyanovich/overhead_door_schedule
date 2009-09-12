require 'nokogiri'
require 'open-uri'
require 'ri_cal'

doc = Nokogiri::HTML(open('http://s2-arena.ezleagues.ezfacility.com/teams/479482/Overhead-Door.aspx'))

calendar = RiCal.Calendar do |cal|

  doc.css('table#_ctl0_C_Schedule1_GridView1 > tr.RowStyle', 'table#_ctl0_C_Schedule1_GridView1 > tr.AlternateRowStyle').each do |game|
    date_href = game.children[0].css('a')[0]['href']
    game_date = date_href.scan(/\d{1,2}\/\d{1,2}\/\d{4}/)[0]
    game_time = game.children[4].content.strip
  
    home_team = game.children[1].content.strip
    away_team = game.children[3].content.strip
  
    cal.event do |event|
      event.summary = "#{home_team} vs. #{away_team}"
      event.dtstart =  DateTime.parse("#{game_date} #{game_time}")
      event.duration = "PT1H" # 1 hour
      event.location = "S2 Ice Arena"
    end
  end
  
end

File.open('overhead_door_fall_2009_10.ics', 'w') do |file|
  file.puts calendar.export_to(file)
end

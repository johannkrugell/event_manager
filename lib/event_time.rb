# frozen_string_literal: true

require 'csv'
require 'time'
require 'date'

def open_file
  CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
end

def time_targeting
  contents = open_file
  date_hour = []
  date_day = []
  contents.each do |row|
    date_hour << Time.strptime(row[:regdate], '%m/%d/%y %k:%M').hour
    date_day << Time.strptime(row[:regdate], '%m/%d/%y %k:%M').strftime('%A')
  end
  count_hours_day(date_hour)
  count_hours_day(date_day)
end

def count_hours_day(hours_or_days)
  frequency = {}
  hours_or_days.group_by { |unit| unit }.each do |key, value|
    frequency[key] = value.count
  end
  p frequency.sort_by { |_key, value| value }.to_h
end

time_targeting

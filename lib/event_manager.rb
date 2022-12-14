# frozen_string_literal: false

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcodes(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_mobile_number(mobile_number)
  mobile_number = mobile_number.gsub(/[-(). ]/, '').to_s
  if mobile_number.length == 10 || (mobile_number.length == 11 && mobile_number.slice(0) == '1')
    mobile_number.slice(mobile_number.length - 10, 10).insert(3, '-').insert(7, '-')
  else
    'xxx-xxx-xxxx'
  end
end

puts 'Event Manager initialized'
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcodes(row[:zipcode])
  mobile_number = clean_mobile_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end

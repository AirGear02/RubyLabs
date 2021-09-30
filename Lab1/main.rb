require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'json'

require_relative 'json_to_csv'

MAX_PAGES     = 10
URL           = "https://auto.ria.com/uk/legkovie/city/chernovczy/?page=%d"
JSON_FILENAME = "items.json"
CSV_FILENAME  = "items.csv"

items = []
MAX_PAGES.times do |page_number|
  puts "Parsing page #{page_number + 1}"
  page = Nokogiri::HTML(URI.open(URL % [page_number + 1]))

  items += page.css('section.ticket-item').map do |item|
    content  = item.at('div.content-bar')
    car_info = item.at('div.hide')

    img_url = content.at('div.ticket-photo > a > picture img')['src']
    info    = content.at('div.content')

    price        = info.at('div.price-ticket')['data-main-price']
    distance     = info.at('li.js-race').text[/\d+/].to_i
    location     = info.at('li.js-location').text.split.first
    has_accident = !info.at("div.base_information > span[data-state='state']").nil?

    {
      :id              => item['data-advertisement-id'],
      :brand           => car_info['data-mark-name'],
      :model           => car_info['data-model-name'],
      :year            => car_info['data-year'],
      :price           => price,
      :distance        => distance,
      :location        => location,
      :was_in_accident => has_accident,
      :img_url         => img_url,
    }
  rescue
    puts "Parse item error. Skipping..."
  end
end

errors_count = items.count(nil)

puts "\nSuccessfully parsed items: #{items.count - errors_count}"
puts "Errors: #{errors_count}"

File.write(JSON_FILENAME, JSON.pretty_generate(items.compact))

convert_json_to_csv(JSON_FILENAME, CSV_FILENAME)




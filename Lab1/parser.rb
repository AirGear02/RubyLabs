require 'csv'
require 'mechanize'

require_relative 'car'

class Parser

  BASE_URL = "https://auto.ria.com/uk/legkovie/state/chernovczy/?page=%d"

  attr_accessor :max_pages, :start_page, :items

  def initialize(start_page, max_pages)
    @max_pages  = max_pages
    @start_page = start_page
    @agent      = Mechanize.new
    @items      = []
  end

  def parse_item(item)
    content  = item.at('div.content-bar')
    car_info = item.at('div.hide')

    img_url = content.at('div.ticket-photo > a > picture img')['src']
    info    = content.at('div.content')

    price        = info.at('div.price-ticket')['data-main-price']
    distance     = info.at('li.js-race').text[/\d+/].to_i
    location     = info.at('li.js-location').text.split(/\s\(/).first.strip
    has_accident = !info.at("div.base_information > span[data-state='state']").nil?
    id           = item['data-advertisement-id']
    brand        = car_info['data-mark-name']
    model        = car_info['data-model-name']
    year         = car_info['data-year']

    Car.new(id, brand, model, year, price, distance, location, has_accident, img_url)
  end

  def parse_curr_page
    @items += @curr_page.search('section.ticket-item').map { |item| parse_item(item) rescue error puts error }
    self
  end

  def next_page
    next_page_link = @curr_page.at('a.js-next')
    @curr_page     = @agent.click(next_page_link)
  end

  def parse
    @curr_page     = @agent.get(BASE_URL % @start_page)
    @items         = []
    pages_to_parse = @max_pages - @start_page + 1
    pages_to_parse.times do |curr_page_number|
      puts "Parsing page #{curr_page_number + @start_page}"
      parse_curr_page
      next_page
      puts @curr_page.uri.to_s
    end
    @items.compact!
    self
  end

  def to_json(file_path)
    File.write(file_path, JSON.pretty_generate(@items))
    self
  end

  def to_csv(file_path)
    csv_result = CSV.generate do |csv|
      csv << @items.first.instance_variables.map {|variable_name| variable_name[1..-1]}
      @items.each { |item| csv << item.values }
    end
    File.write(file_path, csv_result)
    self
  end

end


require 'json'
require 'csv'

def convert_json_to_csv(json_filename, output_filename)
  file = open(json_filename)
  items = JSON.parse(file.read)
  column_names = items.first.keys
  csv_result = CSV.generate do |csv|
    csv << column_names
    items.each { |item| csv << item.values }
  end
  File.write(output_filename, csv_result)
end

require 'crawlbase'
require 'nokogiri'
require 'yaml'

crawlbase_token = 'crawlbase_token'
url_field='url'
keywords = 'keywords'
yaml_loaded = YAML.load_file('config.yaml')
dest_options = yaml_loaded['parameters']

if !dest_options.has_key?(crawlbase_token) || dest_options[crawlbase_token].nil?
  raise Exception, "No crawlbase_token given"
end
if !dest_options.has_key?(url_field) || dest_options[url_field].nil?
  raise Exception, "No url given"
end
keywords_array = dest_options[keywords]

api = Crawlbase::API.new(token: dest_options[crawlbase_token])

url = dest_options[url_field]
html = api.get(url)

doc = Nokogiri::HTML(html.body)
not_found = "not_found"
product_name = doc.at('#productTitle')&.text
product_name = product_name.nil? ? not_found : product_name.strip

product_price_whole = doc.css('span.a-price-whole')[0]
product_price_whole = product_price_whole.nil? ? not_found : product_price_whole.text

product_price_fraction = doc.css('span.a-price-fraction')[0]
product_price_fraction = product_price_fraction.nil? ? not_found : product_price_fraction.text

product_num_ratings = doc.at('#acrCustomerReviewText')&.text
product_num_ratings = product_num_ratings.nil? ? not_found : product_num_ratings.strip

puts "Basic extractions: \n"
puts "Amazon Product URL: #{url}"
puts "Amazon Product Name: #{product_name}"
puts "Amazon Product Price: #{product_price_whole}#{product_price_fraction}"
puts "Number of ratings: #{product_num_ratings}"

puts "Custom extractions: \n"
keywords_array.each { |custom_element|
  custom_extraction = doc.at("##{custom_element}")&.text
  custom_extraction = custom_extraction.nil? ? not_found : custom_extraction.strip
  puts "#{custom_element} extracted: #{custom_extraction}"
}

search_for_string = 'search_string'
if dest_options.has_key?(search_for_string) && !dest_options[search_for_string].nil?
  search_string = dest_options[search_for_string]
  search_string.each{ |search_item|
    if search_item.nil?
      next
    end
  puts "------searching for #{search_item}------"
  doc.traverse do |node|
    if !node.text.nil? && node.text.include?(search_item)
      unless !node.respond_to?(:parent) || node.parent.nil?
        puts node.parent.to_html
        puts "-----------------------"
        break
      end
    end
  end
    puts "------End search for #{search_item}------"
    puts "\n"
  }
end
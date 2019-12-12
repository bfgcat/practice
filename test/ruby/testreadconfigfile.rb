# rubytest.rb
#
# First arg is an xml file.
# parse using nokigiri gem

require 'nokogiri'

#input_array = ARGV
#puts "input array length: " + input_array.length.to_s
## test if not just one arg
#xml_str_file = input_array[0]

puts "input array length: " + ARGV.length.to_s
# test if not just one arg
xml_str_file = ARGV[0]

puts "filename: " + xml_str_file

# open and parse file to get
#	hostname
#	username
#	password
#	dbname
config = Nokogiri::XML(File.open(xml_str_file))

database = config.at_xpath('//database')
host = database.at_xpath('//host').content
username = database.at_xpath('//username').content
password = database.at_xpath('//password').content
databasename = database.at_xpath('//databasename').content

puts "\n"
puts "DB host:         " + host
puts "DB username:     " + username
puts "DB password:     " + password
puts "DB databasename: " + databasename









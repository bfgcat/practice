#testmysql.rb
#
# Open DashboadDB and write record
#
# Args
#   1 - database config file (xml)
#   2 - data record to write (xml)
#
require 'mysql2'
require 'nokogiri' # for parsing xml files

begin
  len = ARGV.length.to_s
  puts "arg len: " + len
  # if ARGV.length.to_s != 2
  #if len != 2
  #  abort ("Error, script requires 2 arguments. Path to DB config file and path to data record")
  #end
      
  xml_str_file = ARGV[0]     # path to db configuration file
  record_str_file = ARGV[1]  # path to file with data for record to be inserted
  
  # Test if files exist and are readable
  
  
  puts "\nTest connection to DashboardDB\n\n"
  
  # get database configuration from config file
  puts "filename: " + xml_str_file
  
  # open and parse config file to get: hostname, username, password, dbname
  config = Nokogiri::XML(File.open(xml_str_file))
  
  database = config.at_xpath('//database')
  host = database.at_xpath('//host').content
  username = database.at_xpath('//username').content
  password = database.at_xpath('//password').content
  databasename = database.at_xpath('//databasename').content
  
  dashboardDB = Mysql2::Client.new(:host => host, :username => username,  :password => password, :databasename => databasename)
  sql_query = "use " + databasename
  dashboardDB.query (sql_query)
  
  # open and parse the database record file to get branch, build, status, lastbuildtime
  dbrecord = Nokogiri::XML(File.open(record_str_file))
  
  record = dbrecord.at_xpath('//record')
  branch = record.at_xpath('//branch').content
  build = record.at_xpath('//build').content
  status = record.at_xpath('//status').content
  lastbuildtime = record.at_xpath('//lastbuildtime').content
  
  sql_query = "INSERT INTO t_buildstatus (c_branch, c_build, c_status, c_lastbuild) VALUES ('" + branch + "','" + build + "','" + status + "','" + lastbuildtime + "')"
  
  puts sql_query
  rs_insert = dashboardDB.query(sql_query)
  puts "\n\n"
  
  # DEBUG: run a query to see if record was added
  sql_query = "select * from t_buildstatus where c_branch = 'dbtest'"
  rs_select = dashboardDB.query(sql_query)
  
  rs_select.each do |h|
    puts h
  end

rescue Mysql2::Error => e
  puts "SQL error caught"
  puts e.errno
  puts e.error
	
ensure
  dashboardDB.close if dashboardDB

end

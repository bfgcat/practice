# rubytest.rb
#

require 'rubygems'
require 'json'
require 'pp'

begin
		myjson = File.read('mtdevops_push.json')
		myparsed = JSON.parse(myjson)
		
		# pp myparsed
		
		puts myparsed['repository']

end
# jenkinstest.rb
#
# 2016-08-22	Brian Gillespie	Created
#
# Test usage of ruby gem jenkins_api_client
#
#

require 'jenkins_api_client'
require 'json'
require 'pp'  # pp = pretty print

begin

	@client = JenkinsApi::Client.new(:server_url => 'http://devops-jksrv02.metratech.com:8080')
	
	puts @client.job.list("^mvp*")
	
	puts @job = @client.job
	
end

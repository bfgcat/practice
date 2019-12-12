# testparseargs.rb
#
# Args:
#  -f db config file path
#  -b branch
#  -n build
#  -s status
#  -l lastbuildtime

require 'trollop'

opts = Trollop::options do
  opt :filename, "Database configuration file, required", :type => String
  opt :branch, "Branch, required", :type => String
  opt :build, "Build Number as a 4 digit sting with leading zeroes, required", :type => String
  opt :status, "Build Status, required", :type => String
  opt :lastbuildtime, "Last Build Time, required", :type => String
end

puts
puts opts
puts
puts "filename: " + opts[:filename] if opts[:filename_given]
puts "branch:   " + opts[:branch] if opts[:branch_given]
puts "build:    " + opts[:build] if opts[:build_given]
puts "status:   " + opts[:status] if opts[:status_given]
puts "lastbuildtime: " + opts[:lastbuildtime] if opts[:lastbuildtime_given]
puts

error = $false

if opts[:filename_given]
    puts "filename given"
end
if opts[:branch_given]
    puts "branch given"
end
if opts[:build_given]
    puts "build given"
end
if opts[:status_given]
    puts "status given"
end
if opts[:lastbuildtime_given]
    puts "lastbuildtime given"
end

puts

unless opts[:filename_given]
    puts "argument filename missing"
    error = true
end
unless opts[:branch_given]
    puts "argument branch missing"
    error = true
end
unless opts[:build_given]
    puts "argument build missing"
    error = true
end
unless opts[:status_given]
    puts "argument status missing"
    error = true
end
unless opts[:lastbuildtime_given]
    puts "argument lastbuildtime missing"
    error = true
end

if error
    abort "\nERROR. Aborting script. \nMissing argument(s)"
end

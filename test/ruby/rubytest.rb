# rubytest.rb
#

myfile = "index.html"
lastline = ""
tfailed = -1
ttotal = -1

f = File.open(myfile, "r")

f.each_line { |line|
		# test if last line contains "<div class="counter">NN</div>"
		# and current line contains either "<p>failures</p>" or "<p>tests</p>"
		
		if ( (m1 = /<div class="counter">(\d*)<\/div>/.match(lastline) )&& (m2 = /<p>(tests|failures)<\/p>/.match(line)) )
				puts m1[1]
				puts m2[1]
		end

		lastline = line
}

f.close

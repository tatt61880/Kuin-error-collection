require 'find'
require 'open3'

curDir = Dir.pwd
Dir::chdir("..")
dir = Dir.pwd

count = 0
Find.find(dir) {|fpath|
	Find.prune if(fpath == curDir)
	if fpath =~ /main.kn$/
		outputFile = curDir + "/output.txt"
		out, err, status = Open3.capture3("cmd.exe /Q /C \"kuincl -i #{fpath} -e cui -q > #{outputFile}\"")
		File.open(outputFile, 'r'){|f|
			buff = f.read().encode("UTF-8", "UTF-16LE")
			if buff =~ /^\[Error\]/
				err = buff[8, 6]
				if fpath =~ /#{err}\/\w+.kn$/
					puts "#{err} ok"
				else
					puts "Error #{fpath} [#{err}]"
					count += 1
				end
			else
				puts "Error #{fpath}"
				puts " #{buff}"
				count += 1
			end
		}
	end
}
if count == 0
	puts "Congratulations!"
else
	puts "Count for unexpected result = #{count}."
end

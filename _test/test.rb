require 'find'
require 'open3'

curDir = Dir.pwd
Dir::chdir("..")
dir = Dir.pwd

tempFilename = "__temp__.txt"
tempFilepath = "#{curDir}/#{tempFilename}"

countOk = 0
countEmpty = 0
countUnexpected = 0
Find.find(dir){|fpath|
	Find.prune if(fpath == curDir)
	if fpath =~ /main.kn$/
		out, err, status = Open3.capture3("cmd.exe /Q /C \"kuincl -i #{fpath} -e cui -q > #{tempFilepath}\"")
		File.open(tempFilepath, 'r'){|f|
			buff = f.read().encode("UTF-8", "UTF-16LE")
			if buff =~ /^\[Error\]/
				err = buff[8, 6]
				if fpath =~ /#{err}\/\w+.kn$/
					puts "#{err} ok"
					countOk += 1
				else
					puts "Error #{fpath} [#{err}]"
					countUnexpected += 1
				end
			else
				puts "Error #{fpath}"
				puts " #{buff}"
				countUnexpected += 1
			end
		}
	else
		if fpath =~ /#{dir}\/\w+/ && File::ftype(fpath) == "directory"
			if Dir.glob("#{fpath}/*.kn").count == 0
				countEmpty += 1
				puts fpath
			end
		end
	end
}
File.unlink tempFilepath

puts "#{countOk}/#{countOk + countUnexpected} (empty-folder: #{countEmpty})"
if countUnexpected == 0
	puts "Congratulations!"
else
	puts "Count for unexpected result = #{countUnexpected}."
end

system("pause")

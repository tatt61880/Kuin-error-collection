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
	if fpath =~ /main.(kn|bat)$/
		Dir.chdir(File::dirname(fpath))
		if fpath =~ /main.kn$/
			out, err, status = Open3.capture3("cmd.exe /Q /C \"kuincl -i main.kn -e exe -s ../../KuinInKuin/build/deploy_exe/sys/ -q > #{tempFilepath}\"")
		else
			out, err, status = Open3.capture3("cmd.exe /Q /C \"main.bat > #{tempFilepath}\" ../../KuinInKuin/build/deploy_exe/sys/")
		end
		File.open(tempFilepath, 'r'){|f|
			buff = f.read().encode("UTF-8", "Shift_JIS")
			if buff =~ /^0x[0-9A-F]+:/
				err = buff[0, 10]
				if fpath =~ /#{err}\/main.(kn|bat)$/
					puts "#{err} ok"
					countOk += 1
				else
					puts "Unexpected result: #{fpath} [#{err}]"
					# puts "#{buff}"
					countUnexpected += 1
				end
			else
				puts "Unexpected result: #{fpath}"
				puts "#{buff}"
				countUnexpected += 1
			end
		}
	else
		if fpath =~ /#{dir}\/\w+$/ && File::ftype(fpath) == "directory"
			if Dir.glob("#{fpath}/main.kn").count == 0 && Dir.glob("#{fpath}/main.bat").count == 0
				countEmpty += 1
				puts fpath + " has no main.(kn|bat)"
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

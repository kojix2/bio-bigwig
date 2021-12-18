require "mkmf"

globs = [".", "libBigWig"].map do |directory|
  File.join(File.dirname(__FILE__), directory)
end.join(",")

$objs = Dir.glob("{#{globs}}/*.c").map do |file|
  File.join(File.dirname(file), "#{File.basename(file, ".c")}.o")
end

create_makefile("bio/bigwig/bigwigext")

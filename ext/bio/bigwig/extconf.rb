require "mkmf"

# check curl
have_library("curl", "curl_easy_init")
have_header("libbigwig/bigWig.h")

$srcs = Dir.glob("libBigWig/*.c", base: __dir__)
           .map { |src| File.expand_path(src, __dir__) }
           .unshift(File.expand_path("bigwigext.c", __dir__))
$objs = $srcs.map { |src| src.gsub(/\.c\z/, ".o") }

create_makefile("bio/bigwig/bigwigext")

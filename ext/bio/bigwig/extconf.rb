require "mkmf"

$objs = Dir.glob(["{.,libBigWig}/*.c"], base: __dir__)
           .map { |f| File.expand_path(f, __dir__) }
           .map { |f| f.sub(/\.c$/, ".o") }

# $INCFLAGS << " -I$(srcdir)/libBigWig"
# $VPATH    << "$(srcdir)/libBigWig"

create_makefile("bio/bigwig/bigwigext")

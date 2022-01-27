# frozen_string_literal: true

require "mkmf"

# https://github.com/taf2/curb/blob/master/ext/extconf.rb
dir_config("curl")
if find_executable("curl-config")
  $CFLAGS << " #{`curl-config --cflags`.strip} -g"
  $LIBS << if ENV["STATIC_BUILD"]
             " #{`curl-config --static-libs`.strip}"
           else
             " #{`curl-config --libs`.strip}"
           end
  ca_bundle_path = `curl-config --ca`.strip
  if !ca_bundle_path.nil? && (ca_bundle_path != "")
    $defs.push(%(-D HAVE_CURL_CONFIG_CA))
    $defs.push(%(-D CURL_CONFIG_CA='#{ca_bundle_path.inspect}'))
  end
end

$objs = Dir.glob(["{.,libBigWig}/*.c"], base: __dir__)
           .map { |f| File.expand_path(f, __dir__) }
           .map { |f| f.sub(/\.c$/, ".o") }

# $INCFLAGS << " -I$(srcdir)/libBigWig"
# $VPATH    << "$(srcdir)/libBigWig"

create_makefile("bio/bigwig/bigwigext")

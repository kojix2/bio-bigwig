require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rake/extensiontask"

Rake::ExtensionTask.new do |ext|
  ext.name    = "bigwigext"
  ext.ext_dir = "ext/bio/bigwig"
  ext.lib_dir = "lib/bio/bigwig"
end

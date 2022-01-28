# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rake/extensiontask"

task build: :compile

Rake::ExtensionTask.new("bigwigext") do |ext|
  ext.ext_dir = "ext/bio/bigwig"
  ext.lib_dir = "lib/bio/bigwig"
end

desc "Remove object file"
task :remove_object_file do
  FileUtils.rm_f("ext/bio/bigwig/bigwigext.o")
  FileUtils.rm_f("ext/bio/bigwig/bigwigext.bundle")
end

task default: %i[
  remove_object_file
  compile
  remove_object_file
  test
]

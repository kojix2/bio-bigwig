# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "tty-command"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]

cmd = TTY::Command.new
ext = RbConfig::CONFIG["SOEXT"]

namespace :libbigwig do
  desc "Compile LibBigWig"
  task :build do
    Dir.chdir("libBigWig") do
      cmd.run "make"
      cmd.run "mkdir -p ../vendor"
      cmd.run "mv libBigWig.#{ext} ../vendor/libBigWig.#{ext}"
    end
  end

  desc "Cleanup"
  task :clean do
    Dir.chdir("libBigWig") do
      cmd.run "make clean"
      cmd.run "rm ../vendor/libBigWig.#{ext}"
    end
  end
end

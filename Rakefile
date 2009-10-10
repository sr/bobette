require "rake/testtask"

Rake::TestTask.new(:default) do |t|
  t.test_files = FileList["test/*_test.rb"]
  t.libs << "test"
end

begin
  require "mg"
  MG.new("bobette.gemspec")
rescue LoadError
end

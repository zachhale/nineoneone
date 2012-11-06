require 'nineoneone'
require 'yaml'

desc "Run"
task :run do
  twitter_credentials = YAML.load_file('settings.yml')['twitter_credentials']
  notifier = NineOneOne::TwitterNotifier.new(twitter_credentials)
  runner = NineOneOne::Runner.new(notifier)
  runner.run(:at_least, 5)
end

# for testing
desc "Parse"
task :at_least_3 do
  parser = NineOneOne::Parser.new
  results = parser.at_least(3)

  results.each do |location, rows|
    puts location
    rows.each do |row|
      puts row.inspect
    end
    puts
  end
end
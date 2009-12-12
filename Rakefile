require 'nineoneone'

desc "Run"
task :run do
  settings = YAML.load_file('settings.yml')
  recipients = settings['notify']
  
  runner = NineOneOne::Runner.new(recipients)
  runner.watch(:at_least, 3)
end

desc "Parse"
task :at_least_2 do
  parser = NineOneOne::Parser.new
  results = parser.at_least(2)

  results.each do |location, rows|
    puts location
    rows.each do |row|
      puts row.inspect
    end
    puts
  end
end
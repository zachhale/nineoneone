require 'nineoneone'

desc "Go"
task :go do
  # settings = YAML.load('settings.yml')
  # recipients = settings['notify']
  # puts recipients.inspect
  
  NineOneOne::Parser.new.top(5).each do |line|
    puts line.inspect
  end
end
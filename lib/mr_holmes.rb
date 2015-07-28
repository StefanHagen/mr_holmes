$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'mr_holmes/node'
require 'mr_holmes/player'

require 'yaml'

class Sherlock

  VERSION = "0.0.5"

end # End Of Class

@root = Node.root

require 'locations/baker_street'
# require 'locations/lauriston_gardens'

@root.find(:player).get_location.describe
@root.find(:player).get_scene.describe
puts

loop do
  player = @root.find(:player)

  print "What now? "

  input = gets.chomp
  verb = input.split(' ').first

  case verb
  when "load"
    @root = Node.load
    puts "Loaded"
  when "save"
    Node.save(@root)
    puts "Saved current game progression... "
  when "quit"
    puts "Goodbye! "
    exit
  else
    player.command(input)
  end
end
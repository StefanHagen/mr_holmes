require 'sherlock/node'
require 'sherlock/player'
require 'yaml'

class Sherlock

  VERSION = "0.0.1"

end # End Of Class

root = Node.root do

  location(:baker_street) do
    self.desc = <<-DESC
      Your current location is Baker Street, London. It's the street that you call home, and where your chambers are. You share your
      rooms with dr. Watson, on the first and second floor of 221B. The landlady is a kind, older woman called Mrs. Hudson.
    DESC

    self.short_desc = <<-DESC
      LOCATION: Baker Street
    DESC

    scene(:side_walk) do
      self.exit_west = :hall_way_ground_floor
      self.desc = <<-DESC
        You are standing on the sidewalk in front of 221B Baker Str. You are facing north, with the front door of your chambers to your west.
      DESC
      self.short_desc = <<-DESC
        SCENE: Sidewalk in front of 221B Baker Str.
      DESC

      player do

        item(:pipe, 'pipe', 'clay', 'empty') do
          self.open = true
          self.desc = <<-DESC
            A clay pipe for times when extraordinary concentration of thought is needed. Used with tobacco and matches.
          DESC
          self.short_desc = <<-DESC
            A clay pipe.
          DESC
          self.script_accept = <<-SCRIPT 
            if [:tobacco].include?(args[0].tag) && children.empty?
              return true
            elsif !children.empty?
              puts "The pipe is already filled with tobacco..."
              return false
            else
              puts "You can't put that in the pipe..."
              return false
            end
          SCRIPT
        end
        item(:tobacco, 'tobacco', 'strong', 'dry') do
          self.desc = <<-DESC
            Dry tobacco used to fill a pipe.
          DESC
          self.short_desc = <<-DESC
            Dry tobacco.
          DESC
        end
        item(:matches, 'matches', 'dry') do
          self.desc = <<-DESC
            These matches can be used on multiple items, when a flame is needed.
          DESC
          self.short_desc = <<-DESC
            Box of matches.
          DESC
          self.script_use = <<-SCRIPT
            if args[0].tag == :pipe
              if !args[0].children.empty?
                puts "You lit your pipe"
                return
              else
                puts "Put tobacco in your pipe before lighting it"
              end
            else
              puts "You can't use matches on that"
              return
            end
          SCRIPT
        end

      end # End Of Player

    end # End Of Scene 'Sidewalk'

    scene(:hall_way_ground_floor) do
      self.exit_east = :side_walk
      self.exit_up = :hall_way_first_floor
      self.desc = <<-DESC
        You are in the hallway on the ground floor of 221B Baker Str. Your chambers are up the stairs, on the first and
        second floor. The front door leading to the sidewalk outside is east of you.
      DESC
      self.short_desc = <<-DESC
        SCENE: Ground floor hallway of 221B Baker Str.
      DESC
      item(:table, 'table') do
        self.desc = <<-DESC
          A small table in the hallway on the ground floor. Any mail or telegrams recieved when you are not at home is usually
          put on this table.
        DESC
        self.short_desc = <<-DESC
          A small table.
        DESC
        self.presence = <<-PRES
          You see a small table placed against the wall.
        PRES
        item(:telegram_1, 'telegram_1') do
          self.desc = <<-DESC
            TELEGRAM: Mysterious case - stop - Lauriston Gardens nr. 3 - stop - come as soon as possible - stop - Lestrade
          DESC
          self.short_desc = <<-DESC
            A Telegram from detective inspector Lestrade.
          DESC
        end
      end
    end # End Of Scene 'Hallway Grd. Floor'

    scene(:hall_way_first_floor) do
      self.exit_north = :sitting_room_first_floor
      self.exit_down = :hall_way_ground_floor
      self.desc = <<-DESC
        You find yourself in the hallway on the first floor of 221B Baker Str. North of you is the door to your sitting room. Down the stairs
        you will find the ground floor hallway.
      DESC
      self.short_desc = <<-DESC
        SCENE: First floor hallway of 221B Baker Str.
      DESC
    end # End of Scene 'Hallway First Floor'

    scene(:sitting_room_first_floor) do
      self.exit_south = :hall_way_first_floor
      self.desc = <<-DESC
        You are in your sitting room on the first floor of 221B Baker Str. The windows to your east provide a view
        of Baker Str. itself, and to your south is the door to the first floor stairwell.
      DESC
      self.short_desc = <<-DESC
        SCENE: Sitting room at 221B Baker Str.
      DESC
    end # End Of Scene 'Sitting Room First Floor'

  end # End of Location 'Baker Street'

end # End Of Root

root.find(:player).get_location.describe
root.find(:player).get_scene.describe
puts

loop do
  player = root.find(:player)

  print "What now? "

  input = gets.chomp
  verb = input.split(' ').first

  case verb
  when "load"
    root = Node.load
    puts "Loaded previously saved game... "
  when "save"
    Node.save(root)
    puts "Saved current game progression... "
  when "quit"
    puts "Goodbye! "
    exit
  else
    player.command(input)
  end
end
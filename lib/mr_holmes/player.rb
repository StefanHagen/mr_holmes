require "yaml"

class Player < Node

  # ----------------------------------------------------------------- Basics

  # Main command interpreter
  def command(words)
    verb, *words = words.split(" ")
    verb = "do_#{verb}"
    if respond_to?(verb)
      send(verb, *words)
      puts
    else
      puts "I don't know how to do that."
    end
  end

  # Provide command shortcuts
  %w{ north south east west up down }.each do|dir|
    define_method("do_#{dir}") do
      do_go(dir)
    end

    define_method("do_#{dir[0]}") do
      do_go(dir)
    end
  end

  # ----------------------------------------------------------------- Actions

  # Move the player around between scenes
  def do_go(direction, *a)
    dest = get_scene.send("exit_#{direction}")
    if dest.nil?
      puts "You can't go that way."
    else
      dest = get_location.find(dest)
      if dest.script("enter", direction)
        get_location.move(self, dest)
      end
      get_location.describe
      get_scene.describe
    end
  end

  # Display current scene information
  def do_look(*a)
    puts
    puts get_scene.long_description
  end

  # Display the items currently in the player's inventory
  def do_inventory(*a)
    if children.empty?
      puts
      puts "INVENTORY"
      puts
      puts "You have nothing in your inventory..."
    else
      puts
      puts "INVENTORY"
      puts
      children.each do |c|
        puts " - #{c.name}"
      end
    end
  end

  # Move an item from the current scene to your inventory
  def do_take(*thing)
    thing = get_scene.find(thing)
    return if thing.nil?
    if thing.script("take")
      puts "Taken. " if get_location.move(thing, self)
    end
  end

  # Move an item from your inventory to the current scene 
  def do_drop(*thing)
    move(thing.join(" "), get_scene)
  end

  # Set the value of an item's "open" attribute
  def open_close(thing, state)
    container = get_scene.find(thing)
    return if container.nil?
    if container.open == state
      puts "It's already #{state ? 'open' : 'closed'}"
    else
      container.open = state
    end
  end

  # Open an item in the current scene
  def do_open(*thing)
    open_close(thing, true)
  end

  # Close an item in the current scene
  def do_close(*thing)
    open_close(thing, false)
  end

  # Put an item in or on another item
  def do_put(*words)
    prepositions = [' in ', ' on ']
    prep_regex = Regexp.new("(#{prepositions.join('|')})")
    item_words, _, cont_words = words.join(' ').split(prep_regex)
    if cont_words.nil?
      puts "You want to put what where?"
      return
    end
    item = get_scene.find(item_words)
    container = get_scene.find(cont_words)
    return if item.nil? || container.nil?
    if container.script("accept", item)
      get_scene.move(item, container)
    end
  end

  # Use an item on another item
  def do_use(*words)
    prepositions = %w{ in on with }
    prepositions.map!{|p| " #{p} " }
    prep_regex = Regexp.new("(#{prepositions.join('|')})")
    item1_words, _, item2_words = words.join(' ').split(prep_regex)
    if item2_words.nil?
      puts "I don't quite understand you."
      return
    end
    item1 = get_scene.find(item1_words)
    item2 = get_scene.find(item2_words)
    return if item1.nil? || item2.nil?
    item1.script('use', item2)
  end

  # Examine an item closely
  def do_examine(*thing)
    item = get_scene.find(thing)
    return if item.nil?
    item.described = false
    item.describe
  end

  # ----------------------------------------------------------------- Alias methods

  alias_method :do_get, :do_take
  alias_method :do_i, :do_inventory
  alias_method :do_inv, :do_inventory

  # ----------------------------------------------------------------- Debugging

  def do_root(*a)
    STDOUT.puts get_root
  end

  # Display the complete node structure
  def do_map(*a)
    STDOUT.puts get_root
  end

  # Display the complete node structure in detail
  def do_map_detailed(*a)
    STDOUT.puts get_root.to_s(true)
  end

end
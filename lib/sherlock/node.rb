require "yaml"
require "ostruct"
require "sherlock/string"

class Node < OpenStruct

  # Method to fix YAML conversions and handling
  def init_with(c)
    c.map.keys.each do|k|
      instance_variable_set("@#{k}", c.map[k])
    end

    @table.keys.each do|k|
      new_ostruct_member(k)
    end
  end

  # Save node structure to YAML
  def self.save(node, file='save.yaml')
    File.open(file, 'w+') do|f|
      f.puts node.to_yaml
    end
  end

  # Load node structure from YAML file
  def self.load(file='save.yaml')
    yaml = YAML::load_file(file)
  end

  # Override 'puts' method for scene descriptions
  def puts(*s)
    STDOUT.puts( s.join(' ').word_wrap )
  end

  # Define possible node types
  DEFAULTS = {
    :root => { :open => true },
    :location => { :open => true },
    :scene => { :open => true },
    :item => { :open => false, },
    :player => { :open => true }
  }

  # Initialize node
  def initialize(parent=nil, tag=nil, defaults={}, &block)
    super()
    defaults.each { |k,v| send("#{k}=", v) }
    self.parent = parent
    self.parent.children << self unless parent.nil?
    self.tag = tag
    self.children = []
    instance_eval(&block) unless block.nil?
  end

  # Create root
  def self.root(&block)
    Node.new(nil, :root, &block)
  end

  # Create location
  def location(tag, &block)
    Node.new(self, tag, DEFAULTS[:location], &block)
  end

  # Create scene
  def scene(tag, &block)
    Node.new(self, tag, DEFAULTS[:scene], &block)
  end

  # Create item
  def item(tag, name, *words, &block)
    i = Node.new(self, tag, DEFAULTS[:item])
    i.name = name
    i.words = words
    i.instance_eval(&block) if block_given?
  end

  # Create player
  def player(&block)
    Player.new(self, :player, DEFAULTS[:player], &block)
  end

  # ----------------------------------------------------------------- Finding Nodes

  # Method to find node
  def find(node_data)
    case node_data
    when Symbol
      find_by_tag(node_data)
    when String
      find_by_string(node_data)
    when Array 
      find_by_string(node_data)
    when Node 
      node_data
    end
  end

  # Find node by tag
  def find_by_tag(tag)
    return self if self.tag == tag
    children.each do |c|
      result = c.find_by_tag(tag)
      return result unless result.nil?
    end
    return nil
  end

  # Find node by name
  def find_by_name(words, nodes=[])
    words = words.split unless words.is_a?(Array)
    nodes << self if words.include?(name)
    children.each do |c|
      c.find_by_name(words, nodes)
    end
    return nodes
  end

  # Find node by string
  def find_by_string(words)
    words = words.split unless words.is_a?(Array)
    nodes = find_by_name(words)
    if nodes.empty?
      puts "I don't see that here"
      return nil
    end
    # Score nodes by number of matching adjectives
    nodes.each do |i|
      i.search_score = (words & i.words).length
    end
    # Sort highest scoring nodes to beginning of list
    nodes.sort! do |a,b|
      a.search_score <=> b.search_score
    end
    # Remove nodes with a lower score than the first node in the list
    nodes.delete_if do |i|
      i.search_score < nodes.first.search_score
    end
    # Interpret the results
    if nodes.length == 1
      return nodes.first
    else
      puts "Which item do you mean?"
      nodes.each do |i|
        puts " * #{i.name} (#{i.words.join(', ')})"
      end
      return nil
    end
  end

  # ----------------------------------------------------------------- Traversing Upwards

  # Get scene
  def get_scene
    if parent.parent.tag == :root
      return self
    else
      return parent.get_scene
    end
  end

  # Get location
  def get_location
    if parent.tag == :root
      return self
    else
      return parent.get_location
    end
  end

  # Get root
  def get_root
    if tag == :root || parent.nil?
      return self
    else
      return parent.get_root
    end
  end

  def ancestors(list=[])
    if parent.nil?
      return list
    else
      list << parent
      return parent.ancestors(list)
    end
  end

  # ----------------------------------------------------------------- Hidden Nodes

  # Check if node is hidden
  def hidden?
    if parent.tag == :root || parent.tag == :location
      return false
    elsif parent.open == false
      return true
    else
      return parent.hidden?
    end
  end

  # ----------------------------------------------------------------- Moving Nodes

  # Move node
  def move(object, to, check=true)
    item = find(object)
    dest = find(to)
    return if item.nil?
    if check && item.hidden?
      puts "You can't get to that right now"
      return
    end
    return if dest.nil?
    if check && dest.hidden? || dest.open == false
      puts "You can't put that there"
      return
    end
    if dest.ancestors.include?(item)
      puts "Are you trying to destroy the universe?"
      return
    end
    item.parent.children.delete(item)
    dest.children << item
    item.parent = dest
  end

  # ----------------------------------------------------------------- Executing Script

  def script(key, *args)
    if respond_to?("script_#{key}")
      return eval(self.send("script_#{key}"))
    else
      return true
    end
  end

  # ----------------------------------------------------------------- Descriptions

  def described?
    if respond_to?(:described)
      self.described
    else 
      false
    end
  end

  def describe
    base = ""
    if !described? && respond_to?(:desc)
      self.described = true
      base << desc
    elsif respond_to?(:short_desc)
      base << short_desc
    else
      base << "You are in #{tag}"
    end

    # Append presence of children nodes if open
    if open
      children.each do|c|
        base << (c.presence || '')
      end
    end

    puts
    puts base

  end

  def short_description
    if respond_to?(:short_desc)
      short_desc
    else
      tag.to_s
    end
  end

  def long_description
    if respond_to?(:desc)
      desc
    else
      tag.to_s
    end
  end

  # ----------------------------------------------------------------- Rendering Nodes

  # Render node structure
  def to_s(verbose=false, indent='')
    bullet = if parent && parent.tag == :root
               '#'
             elsif parent && parent.parent.tag == :root
               '*'
             elsif tag == :player
               '@'
             elsif tag == :root
               '>'
             elsif open == true
               'O'
             else
               '-'
             end

    str = "#{indent}#{bullet} #{tag}\n"

    if verbose
      self.table.each do|k,v|
        if k == :children
          str << "#{indent+'  '}#{k}=#{v.map(&:tag)}\n"
        elsif v.is_a?(Node)
          str << "#{indent+'  '}#{k}=#{v.tag}\n"
        else
          str << "#{indent+'  '}#{k}=#{v}\n"
        end
      end
    end

    children.each do|c|
      str << c.to_s(verbose, indent + '  ')
    end

    return str
  end

end
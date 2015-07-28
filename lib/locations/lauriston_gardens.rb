@root.location(:lauriston_gardens) do
  self.desc = <<-DESC
    Lauriston Gardens no. 3, the place where Gregson wanted you to come. A small garden sprinkled over with scattered 
    eruption of sickly plants separates the house from the street, and is traversed by a narrow pathway, yellowish in
    colour, and consisting apperently of a mixture of clay and of gravel. The whole place is very sloppy from the rain
    which has fallen throughout the night.
  DESC

  self.short_desc = <<-DESC
    LOCATION: Lauriston Gardens no. 3
  DESC

  scene(:side_walk_lauriston_gardens) do
    self.exit_west = :lauriston_house_hallway
    self.desc = <<-DESC
      You are standing on the sidewalk, in front of the house. A brick wall separates the garden from the sidewalk.
    DESC
    self.short_desc = <<-DESC
      SCENE: Sidewalk in front of Lauriston Gardens no. 3
    DESC
  end # End Of Scene 'Sidewalk'

end # End of Location 'Lauriston Gardens'
class KNIGHTS
  attr_accessor :starting_pos, :current_position, :name

  def initialize(name = '', x_pos = 2, y_pos = 1)
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @starting_pos = [x_pos, y_pos]
    @current_position = [@x_pos, @y_pos]
    @knight_transforms = [
      [[@x_pos - 1, @y_pos + 2], [@x_pos + 1, @y_pos + 2]],
      [[@x_pos - 1, @y_pos - 2], [@x_pos + 1, @y_pos - 2]]

    ]
  end

  def self.make_knights
    @white_knight_left = KNIGHTS.new('white_knight', 2, 1)
    @white_knight_right = KNIGHTS.new('white_knight', 7, 1)
    @black_knight_left = KNIGHTS.new('black_knight', 2, 8)
    @black_knight_right = KNIGHTS.new('black_knight', 7, 8)
    @knights = @white_knight_left, @white_knight_right, @black_knight_left, @black_knight_right
  end

  def move_knight(new_x, new_y)
    @knight_transforms.each do |all_transform|
      next unless all_transform.include?([new_x, new_y])

      @new_position = [new_x, new_y]
      @x_pos = new_x
      @y_pos = new_y
    end
    p @new_position
  end
end

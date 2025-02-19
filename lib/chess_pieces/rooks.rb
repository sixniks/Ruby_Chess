class ROOKS
  attr_accessor :starting_pos, :current_position, :name

  def initialize(name, x_pos = 8, y_pos = 8)
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @current_position = [@x_pos, @y_pos]
    @starting_pos = [x_pos, y_pos]
  end

  def self.make_rooks
    @black_rook_left = ROOKS.new('black_rook', 1, 8)
    @black_rook_right = ROOKS.new('black_rook', 8, 8)
    @white_rook_left = ROOKS.new('white_rook', 1, 1)
    @white_rook_right = ROOKS.new('white_rook', 8, 1)
    @rooks = @black_rook_left, @black_rook_right, @white_rook_left, @white_rook_right
  end

  def move_rook(new_x, new_y)
    rook_transforms = [
      (0..7).map { |i| [[@x_pos + i, @y_pos]] }, # horizontal right
      (0..7).map { |i| [[@x_pos - i, @y_pos]] }, # horizontal left
      (0..7).map { |i| [[@x_pos, @y_pos + i]] }, # vertical up
      (0..7).map { |i| [[@x_pos, @y_pos - i]] } # vertical down

    ]
    rook_transforms.each do |all_transform|
      all_transform.each do |transform|
        next unless transform.include?([new_x, new_y])

        @new_position = [new_x, new_y]
        @x_pos = new_x
        @y_pos = new_y
      end
    end
    p @new_position
  end
end

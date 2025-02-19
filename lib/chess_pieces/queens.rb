class QUEENS
  attr_accessor :starting_pos, :current_position, :name

  def initialize(name = '', x_pos = 4, y_pos = 8)
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @current_position = [@x_pos, @y_pos]
    @starting_pos = [x_pos, y_pos]
  end

  def self.make_queens
    @black_queen = QUEENS.new('black_queen', 4, 8)
    @white_queen = QUEENS.new('white_queen', 4, 1)
    @queens = @black_queen, @white_queen
  end

  def move_queen(new_x, new_y)
    queen_transforms = [
      (0..7).map { |i| [[@x_pos, @y_pos + i]] }, # vertical up
      (0..7).map { |i| [[@x_pos, @y_pos - i]] }, # vertical down
      (0..7).map { |i| [[@x_pos + i, @y_pos]] }, # horizontal right
      (0..7).map { |i| [[@x_pos - i, @y_pos]] }, # horizontal left
      (0..7).map { |i| [[@x_pos - i, @y_pos + i]] }, # diagonaol up-left
      (0..7).map { |i| [[@x_pos + i, @y_pos + i]] }, # diagonaol up-right
      (0..7).map { |i| [[@x_pos - i, @y_pos - i]] }, # diagonaol down-left
      (0..7).map { |i| [[@x_pos + i, @y_pos - i]] }  # diagonaol down-right
    ]
    queen_transforms.each do |all_transform|
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

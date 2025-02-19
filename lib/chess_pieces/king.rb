class KINGS
  attr_accessor :starting_pos, :kings, :current_position, :name

  def initialize(name, x_pos = 5, y_pos = 8)
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @starting_pos = [x_pos, y_pos]
    @current_position = [@x_pos, @y_pos]
  end

  def self.make_kings
    @white_king = KINGS.new('white_king', 5, 1)
    @black_king = KINGS.new('black_king', 5, 8)
    @kings = @white_king, @black_king
  end

  def move_king(new_x, new_y)
    king_transforms = [
      (0..1).map { |i| [[@x_pos, @y_pos + i]] }, # vertical up
      (0..1).map { |i| [[@x_pos, @y_pos - i]] }, # vertical down
      (0..1).map { |i| [[@x_pos + i, @y_pos]] }, # horizontal right
      (0..1).map { |i| [[@x_pos - i, @y_pos]] }, # horizontal left
      (0..1).map { |i| [[@x_pos - i, @y_pos + i]] }, # diagonaol up-left
      (0..1).map { |i| [[@x_pos + i, @y_pos + i]] }, # diagonaol up-right
      (0..1).map { |i| [[@x_pos - i, @y_pos - i]] }, # diagonaol down-left
      (0..1).map { |i| [[@x_pos + i, @y_pos - i]] }  # diagonaol down-right
    ]
    king_transforms.each do |all_transform|
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

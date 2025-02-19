class BISHOPS
  attr_accessor :starting_pos, :bishop_white_right, :bishops, :current_position, :name

  def initialize(name, x_pos = 3, y_pos = 8)
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @starting_pos = [x_pos, y_pos]
    @current_position = [@x_pos, @y_pos]
  end

  def self.make_bishops
    @bishop_black_left = BISHOPS.new('bishop_black', 3, 8)
    @bishop_black_right = BISHOPS.new('bishop_black', 6, 8)
    @bishop_white_left = BISHOPS.new('bishop_white', 3, 1)
    @bishop_white_right = BISHOPS.new('bishop_white', 6, 1)
    @bishops = @bishop_black_left, @bishop_black_right, @bishop_white_left, @bishop_white_right
  end

  def move_bishop(new_x, new_y)
    bishop_transforms = [
      (1..7).map { |i| [[@x_pos - i, @y_pos + i]] }, # diagonaol up-left
      (1..7).map { |i| [[@x_pos + i, @y_pos + i]] }, # diagonaol up-right
      (1..7).map { |i| [[@x_pos - i, @y_pos - i]] }, # diagonaol down-left
      (1..7).map { |i| [[@x_pos + i, @y_pos - i]] }  # diagonaol down-right
    ]
    bishop_transforms.each do |all_transform|
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
# bishop1 = BISHOPS.new

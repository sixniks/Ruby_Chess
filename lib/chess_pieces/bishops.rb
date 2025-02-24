class BISHOPS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :bishop_transforms, :transforms, :has_moved, :range

  def initialize(name = '', x_pos = 5, y_pos = 1)
    @bishops_arr = []
    @has_moved = false
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @starting_pos = [x_pos, y_pos]
    @current_x = @x_pos
    @current_y = @y_pos
    @current_position = [@x_pos, @y_pos]
    @range = (0..7)
    @transforms = [
      @range.map { |i| [[@x_pos - i, @y_pos + i]] }, # diagonaol up-left
      @range.map { |i| [[@x_pos + i, @y_pos + i]] }, # diagonaol up-right
      @range.map { |i| [[@x_pos - i, @y_pos - i]] }, # diagonaol down-left
      @range.map { |i| [[@x_pos + i, @y_pos - i]] }, # diagonaol down-right
      @range.map { |i| [[@x_pos, @y_pos]] } # No move
    ]
  end

  def make_bishops
    @bishop_black_left = BISHOPS.new('bishop_black', 3, 8)
    @bishop_black_right = BISHOPS.new('bishop_black', 6, 8)
    @bishop_white_left = BISHOPS.new('bishop_white', 3, 1)
    @bishop_white_right = BISHOPS.new('bishop_white', 6, 1)
    @bishops = @bishop_black_left, @bishop_black_right, @bishop_white_left, @bishop_white_right
  end

  def move_bishop(selected_position, new_position, total_board)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]
    new_position.map do |num|
      if num > 8 || num < 1
        puts 'Please select a position that is within the board'
        return false
      end
    end
    bishop_to_move = find_bishop(selected_position, total_board)

    bishop_to_move.transforms = [
      bishop_to_move.range.map { |i| [[@x_pos - i, @y_pos + i]] }, # diagonaol up-left
      bishop_to_move.range.map { |i| [[@x_pos + i, @y_pos + i]] }, # diagonaol up-right
      bishop_to_move.range.map { |i| [[@x_pos - i, @y_pos - i]] }, # diagonaol down-left
      bishop_to_move.range.map { |i| [[@x_pos + i, @y_pos - i]] }, # diagonaol down-right
      bishop_to_move.range.map { |i| [[@x_pos, @y_pos]] } # No move
    ]
    p bishop_to_move
    total_board.delete(bishop_to_move)
    bishop_to_move.transforms.join.each_char.each_slice(2).to_a.each do |item|
      next unless item.map!(&:to_i) == new_position

      bishop_to_move.current_position = new_position
      bishop_to_move.has_moved = true
      bishop_to_move.y_pos = new_position[1]
      bishop_to_move.x_pos = new_position[0]
      @x_pos = new_position[0]
      @y_pos = new_position[1]
      bishop_to_move.current_y = new_position[1]
      bishop_to_move.current_x = new_position[0]
      # bishop_to_move.transforms = @transforms
      total_board << bishop_to_move
      return total_board
    end
    puts 'Invalid move'
    false
  end

  def find_bishop(selected_position, total_board)
    total_board.flatten.find { |bishop| bishop.instance_variable_get(:@current_position) == selected_position }
  end
end

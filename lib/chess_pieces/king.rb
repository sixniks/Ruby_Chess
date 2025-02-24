class KINGS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :king_transforms, :transforms, :has_moved, :range

  def initialize(name = '', x_pos = 5, y_pos = 1)
    @kings_arr = []
    @has_moved = false
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @starting_pos = [x_pos, y_pos]
    @current_x = @x_pos
    @current_y = @y_pos
    @current_position = [@x_pos, @y_pos]
    @range = (0..1)
    @transforms = [
      @range.map { |i| [[@x_pos, @y_pos + i]] }, # vertical up
      @range.map { |i| [[@x_pos, @y_pos - i]] }, # vertical down
      @range.map { |i| [[@x_pos + i, @y_pos]] }, # horizontal right
      @range.map { |i| [[@x_pos - i, @y_pos]] }, # horizontal left
      @range.map { |i| [[@x_pos - i, @y_pos + i]] }, # diagonaol up-left
      @range.map { |i| [[@x_pos + i, @y_pos + i]] }, # diagonaol up-right
      @range.map { |i| [[@x_pos - i, @y_pos - i]] }, # diagonaol down-left
      @range.map { |i| [[@x_pos + i, @y_pos - i]] }, # diagonaol down-right
      @range.map { |i| [[@x_pos, @y_pos]] } # No move
    ]
  end

  def make_kings
    @black_king = KINGS.new('black_king', 5, 8)
    @white_king = KINGS.new('white_king', 5, 1)
    @kings = @black_king, @white_king
  end

  def move_king(selected_position, new_position, total_board)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]
    new_position.map do |num|
      if num > 8 || num < 1
        puts 'Please select a position that is within the board'
        return false
      end
    end
    king_to_move = find_king(selected_position, total_board)

    king_to_move.transforms = [
      king_to_move.range.map { |i| [[@x_pos, @y_pos + i]] }, # vertical up
      king_to_move.range.map { |i| [[@x_pos, @y_pos - i]] }, # vertical down
      king_to_move.range.map { |i| [[@x_pos + i, @y_pos]] }, # horizontal right
      king_to_move.range.map { |i| [[@x_pos - i, @y_pos]] }, # horizontal left
      king_to_move.range.map { |i| [[@x_pos - i, @y_pos + i]] }, # diagonaol up-left
      king_to_move.range.map { |i| [[@x_pos + i, @y_pos + i]] }, # diagonaol up-right
      king_to_move.range.map { |i| [[@x_pos - i, @y_pos - i]] }, # diagonaol down-left
      king_to_move.range.map { |i| [[@x_pos + i, @y_pos - i]] }, # diagonaol down-right
      king_to_move.range.map { |i| [[@x_pos, @y_pos]] } # No move
    ]
    p king_to_move
    total_board.delete(king_to_move)
    king_to_move.transforms.join.each_char.each_slice(2).to_a.each do |item|
      next unless item.map!(&:to_i) == new_position

      king_to_move.current_position = new_position
      king_to_move.has_moved = true
      king_to_move.y_pos = new_position[1]
      king_to_move.x_pos = new_position[0]
      @x_pos = new_position[0]
      @y_pos = new_position[1]
      king_to_move.current_y = new_position[1]
      king_to_move.current_x = new_position[0]
      # king_to_move.transforms = @transforms
      total_board << king_to_move
      return total_board
    end
    puts 'Invalid move'
    false
  end

  def find_king(selected_position, total_board)
    total_board.flatten.find { |king| king.instance_variable_get(:@current_position) == selected_position }
  end
end

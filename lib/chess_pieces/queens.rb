class QUEENS
  # TO DO:
  # First turn move 2 spaces
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :queen_transforms, :transforms, :has_moved, :range

  def initialize(name = '', x_pos = 4, y_pos = 1)
    @queens_arr = []
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

  def make_queens
    @black_queen = QUEENS.new('black_queen', 4, 8)
    @white_queen = QUEENS.new('white_queen', 4, 1)
    @queens = @black_queen, @white_queen
  end

  def move_queen(selected_position, new_position, total_board)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]
    new_position.map do |num|
      if num > 8 || num < 1
        puts 'Please select a position that is within the board'
        return false
      end
    end
    queen_to_move = find_queen(selected_position, total_board)

    queen_to_move.transforms = [
      queen_to_move.range.map { |i| [[@x_pos, @y_pos + i]] }, # vertical up
      queen_to_move.range.map { |i| [[@x_pos, @y_pos - i]] }, # vertical down
      queen_to_move.range.map { |i| [[@x_pos + i, @y_pos]] }, # horizontal right
      queen_to_move.range.map { |i| [[@x_pos - i, @y_pos]] }, # horizontal left
      queen_to_move.range.map { |i| [[@x_pos - i, @y_pos + i]] }, # diagonaol up-left
      queen_to_move.range.map { |i| [[@x_pos + i, @y_pos + i]] }, # diagonaol up-right
      queen_to_move.range.map { |i| [[@x_pos - i, @y_pos - i]] }, # diagonaol down-left
      queen_to_move.range.map { |i| [[@x_pos + i, @y_pos - i]] }, # diagonaol down-right
      queen_to_move.range.map { |i| [[@x_pos, @y_pos]] } # No move
    ]
    p queen_to_move
    total_board.delete(queen_to_move)
    queen_to_move.transforms.join.each_char.each_slice(2).to_a.each do |item|
      next unless item.map!(&:to_i) == new_position

      queen_to_move.current_position = new_position
      queen_to_move.has_moved = true
      queen_to_move.y_pos = new_position[1]
      queen_to_move.x_pos = new_position[0]
      @x_pos = new_position[0]
      @y_pos = new_position[1]
      queen_to_move.current_y = new_position[1]
      queen_to_move.current_x = new_position[0]
      # queen_to_move.transforms = @transforms
      total_board << queen_to_move
      return total_board
    end
    puts 'Invalid move'
    false
  end

  def find_queen(selected_position, total_board)
    total_board.flatten.find { |queen| queen.instance_variable_get(:@current_position) == selected_position }
  end
end

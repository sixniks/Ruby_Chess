class ROOKS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :rooks_transforms, :transforms, :has_moved, :range

  def initialize(name = '', x_pos = 5, y_pos = 1)
    @rookss_arr = []
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
      @range.map { |i| [[@x_pos + i, @y_pos]] }, # horizontal right
      @range.map { |i| [[@x_pos - i, @y_pos]] }, # horizontal left
      @range.map { |i| [[@x_pos, @y_pos + i]] }, # vertical up
      @range.map { |i| [[@x_pos, @y_pos - i]] }, # vertical down
      @range.map { |i| [[@x_pos, @y_pos]] } # No move
    ]
  end

  def make_rooks
    @black_rook_left = ROOKS.new('black_rook', 1, 8)
    @black_rook_right = ROOKS.new('black_rook', 8, 8)
    @white_rook_left = ROOKS.new('white_rook', 1, 1)
    @white_rook_right = ROOKS.new('white_rook', 8, 1)
    @rooks = @black_rook_left, @black_rook_right, @white_rook_left, @white_rook_right
  end

  def move_rooks(selected_position, new_position, total_board)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]
    new_position.map do |num|
      if num > 8 || num < 1
        puts 'Please select a position that is within the board'
        return false
      end
    end
    rooks_to_move = find_rooks(selected_position, total_board)

    rooks_to_move.transforms = [
      rooks_to_move.range.map { |i| [[@x_pos + i, @y_pos]] }, # horizontal right
      rooks_to_move.range.map { |i| [[@x_pos - i, @y_pos]] }, # horizontal left
      rooks_to_move.range.map { |i| [[@x_pos, @y_pos + i]] }, # vertical up
      rooks_to_move.range.map { |i| [[@x_pos, @y_pos - i]] }, # vertical down
      rooks_to_move.range.map { |i| [[@x_pos, @y_pos]] } # No move
    ]
    # p rooks_to_move
    total_board.delete(rooks_to_move)
    rooks_to_move.transforms.join.each_char.each_slice(2).to_a.each do |item|
      next unless item.map!(&:to_i) == new_position

      rooks_to_move.current_position = new_position
      rooks_to_move.has_moved = true
      rooks_to_move.y_pos = new_position[1]
      rooks_to_move.x_pos = new_position[0]
      @x_pos = new_position[0]
      @y_pos = new_position[1]
      rooks_to_move.current_y = new_position[1]
      rooks_to_move.current_x = new_position[0]
      # rooks_to_move.transforms = @transforms
      total_board << rooks_to_move
      return total_board
    end
    puts 'Invalid move'
    false
  end

  def find_rooks(selected_position, total_board)
    total_board.flatten.find { |rooks| rooks.instance_variable_get(:@current_position) == selected_position }
  end
end

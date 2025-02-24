class KNIGHTS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :knight_transforms, :transforms, :has_moved

  def initialize(name = '', x_pos = 5, y_pos = 1)
    @knights_arr = []
    @has_moved = false
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @starting_pos = [x_pos, y_pos]
    @current_x = @x_pos
    @current_y = @y_pos
    @current_position = [@x_pos, @y_pos]
    @transforms = [
      [[@x_pos - 1, @y_pos + 2]],
      [[@x_pos + 1, @y_pos + 2]],
      [[@x_pos - 1, @y_pos - 2]],
      [[@x_pos + 1, @y_pos - 2]]
    ]
  end

  def make_knights
    @white_knight_left = KNIGHTS.new('white_knight', 2, 1)
    @white_knight_right = KNIGHTS.new('white_knight', 7, 1)
    @black_knight_left = KNIGHTS.new('black_knight', 2, 8)
    @black_knight_right = KNIGHTS.new('black_knight', 7, 8)
    @knights = @white_knight_left, @white_knight_right, @black_knight_left, @black_knight_right
  end

  def move_knight(selected_position, new_position, total_board)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]
    new_position.map do |num|
      if num > 8 || num < 1
        puts 'Please select a position that is within the board'
        return false
      end
    end
    knight_to_move = find_knight(selected_position, total_board)

    knight_to_move.transforms = [
      [[@x_pos - 1, @y_pos + 2]],
      [[@x_pos + 1, @y_pos + 2]],
      [[@x_pos - 1, @y_pos - 2]],
      [[@x_pos + 1, @y_pos - 2]]
    ]
    p knight_to_move
    total_board.delete(knight_to_move)
    knight_to_move.transforms.join.each_char.each_slice(2).to_a.each do |item|
      next unless item.map!(&:to_i) == new_position

      knight_to_move.current_position = new_position
      knight_to_move.has_moved = true
      knight_to_move.y_pos = new_position[1]
      knight_to_move.x_pos = new_position[0]
      @x_pos = new_position[0]
      @y_pos = new_position[1]
      knight_to_move.current_y = new_position[1]
      knight_to_move.current_x = new_position[0]
      # knight_to_move.transforms = @transforms
      total_board << knight_to_move
      return total_board
    end
    puts 'Invalid move'
    false
  end

  def find_knight(selected_position, total_board)
    total_board.flatten.find { |knight| knight.instance_variable_get(:@current_position) == selected_position }
  end
end

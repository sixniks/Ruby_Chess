class PAWNS
  # TO DO:
  # First turn move 2 spaces
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :pawn_transforms, :transforms, :has_moved, :range

  def initialize(name = '', x_pos = 1, y_pos = 2)
    @pawns_arr = []
    @has_moved = false
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @starting_pos = [x_pos, y_pos]
    @current_x = @x_pos
    @current_y = @y_pos
    @current_position = [@x_pos, @y_pos]
    @range = (1..1)
    @range = (1..2) unless @has_moved == true
    @transforms = [
      @range.map { |i| [@x_pos, @y_pos + i] }, # vertical up
      @range.map { |i| [@x_pos, @y_pos - i] }, # vertical down
      @range.map { |i| [@x_pos - i, @y_pos + i] }, # diagonaol up-left
      @range.map { |i| [@x_pos + i, @y_pos + i] } # diagonaol up-right
    ]
  end

  def make_pawns
    @pawns_arr << (1..8).map do |i|
      PAWNS.new('white_pawns', i, 2)
    end
    @pawns_arr << (1..8).map do |i|
      PAWNS.new('black_pawns', i, 7)
    end
  end

  def move_pawn(selected_position, new_position, total_board)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]

    pawn_to_move = find_pawn(selected_position, total_board)
    p pawn_to_move
    @range = (1..1)
    @range = (1..2) unless pawn_to_move.has_moved == true
    @transforms = [
      @range.map { |i| [@x_pos, @y_pos + i] }, # vertical up veritcal_up =
      @range.map { |i| [@x_pos, @y_pos - i] }, # vertical down
      @range.map { |i| [@x_pos - i, @y_pos + i] }, # diagonaol up-left
      @range.map { |i| [@x_pos + i, @y_pos + i] } # diagonaol up-right
    ]

    total_board.delete(pawn_to_move)
    pawn_to_move.transforms.join.each_char.each_slice(2).to_a.each do |item|
      next unless item.map!(&:to_i) == new_position

      pawn_to_move.current_position = new_position
      pawn_to_move.has_moved = true
      pawn_to_move.y_pos = new_position[1]
      pawn_to_move.x_pos = new_position[0]
      @x_pos = new_position[0]
      @y_pos = new_position[1]
      pawn_to_move.current_y = new_position[1]
      pawn_to_move.current_x = new_position[0]
      # pawn_to_move.transforms = @transforms
      total_board << pawn_to_move
      return total_board
    end
    puts 'Invalid move'
    false
  end

  def find_pawn(selected_position, total_board)
    total_board.flatten.find { |pawn| pawn.instance_variable_get(:@current_position) == selected_position }
  end
end

class ROOKS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :rook_transforms, :transforms, :has_moved, :range, :captured, :team

  def initialize(team = '', name = '', x_pos = 1, y_pos = 2)
    @count = 0
    @team = team
    @captured = false
    @rooks_arr = []
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
      @range.map { |i| [@x_pos, @y_pos + i] }, # vertical up
      @range.map { |i| [@x_pos, @y_pos - i] }, # vertical down
      @range.map { |i| [@x_pos - i, @y_pos + i] }, # diagonaol up-left
      @range.map { |i| [@x_pos + i, @y_pos + i] }, # diagonaol up-right
      @range.map { |i| [@x_pos - i, @y_pos - i] }, # diagonaol down-left
      @range.map { |i| [@x_pos + i, @y_pos - i] }, # diagonaol down-right
      @range.map { |i| [@x_pos, @y_pos] }
    ]
  end

  def make_rooks
    @black_rook_left = ROOKS.new('black', 'Black Rook', 1, 8)
    @black_rook_right = ROOKS.new('black', 'Black Rook', 8, 8)
    @white_rook_left = ROOKS.new('white', 'White Rook', 1, 1)
    @white_rook_right = ROOKS.new('white', 'White Rook', 8, 1)
    @rooks = @black_rook_left, @black_rook_right, @white_rook_left, @white_rook_right
  end

  def move_rook(selected_position, new_position, total_board, game, dont_move)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]
    # new_position.map do |num|
    #   if num > 8 || num < 1
    #     puts 'Please select a position that is within the board'
    #     return false
    #   end
    # end
    rook_to_move = find_rook(selected_position, total_board)

    rook_to_move.range = (1..7)

    rook_to_move.transforms = [
      rook_to_move.range.map { |i| [rook_to_move.x_pos, rook_to_move.y_pos + i, 'vertical up'] }, # vertical up
      rook_to_move.range.map { |i| [rook_to_move.x_pos, rook_to_move.y_pos - i, 'vertical down'] }, # vertical down
      rook_to_move.range.map do |i|
        [rook_to_move.x_pos + i, rook_to_move.y_pos, 'horizontal right']
      end,
      rook_to_move.range.map { |i| [rook_to_move.x_pos - i, rook_to_move.y_pos, 'horizontal left'] }, # horizontal left
      rook_to_move.range.map { |i| [rook_to_move.x_pos, rook_to_move.y_pos, 'No move'] } # No move
    ]
    rook_to_move.transforms.each do |item|
      item.each do |item2|
        transform_used = item2.pop unless item2.nil?
        next unless item2 == new_position

        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, rook_to_move, total_board)

        if moved_spaces.nil? || check_for_collision(transform_used, new_position, rook_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          return false
        else

          total_board.delete(rook_to_move) unless dont_move
          rook_to_move.current_position = new_position unless dont_move
          rook_to_move.has_moved = true unless dont_move
          rook_to_move.y_pos = new_position[1] unless dont_move
          rook_to_move.x_pos = new_position[0] unless dont_move
          @x_pos = new_position[0] unless dont_move
          @y_pos = new_position[1] unless dont_move
          rook_to_move.current_y = new_position[1] unless dont_move
          rook_to_move.current_x = new_position[0] unless dont_move
          total_board << rook_to_move

          return total_board
        end
      end
    end

    false
  end

  def get_possible_moves(total_board, game)
    dont_move = true
    rook_transforms_black = []
    rook_transforms_white = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Rook')

      piece.transforms.each do |transform|
        p "transform #{transform}"
      end

      selected_position = piece.current_position
      new_position = piece.transforms.each
      new_position.each do |pos|
        pos.map do |pos2|
          @count += 1
          puts "count is #{@count}"
          next unless move_rook(selected_position, pos2, total_board, game, dont_move) != false

          piece.transforms.clear

          if piece.team == 'white'
            if !pos2.nil? && !(pos2[0] > 8 || pos2[0] < 1 || pos2[1] > 8 || pos2[1] < 1)
              rook_transforms_white << pos2
              piece.transforms << pos2
            end
          elsif piece.team == 'black'
            if !pos2.nil? && !(pos2[0] > 8 || pos2[0] < 1 || pos2[1] > 8 || pos2[1] < 1)
              rook_transforms_black << pos2
              piece.transforms << pos2
            end
          end
        end
      end
    end
    [rook_transforms_black, rook_transforms_white]
  end

  def find_rook(selected_position, total_board)
    total_board.flatten.find { |rook| rook.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, rook_to_move, total_board)
    case transform_used
    when 'vertical up' then vertical_up(transform_used, new_position, rook_to_move, total_board)
    when 'vertical down' then vertical_down(transform_used, new_position, rook_to_move, total_board)
    when 'horizontal right' then horizontal_right(transform_used, new_position, rook_to_move, total_board)
    when 'horizontal left' then horizontal_left(transform_used, new_position, rook_to_move, total_board)
    end
  end

  def check_for_collision(transform_used, new_position, rook_to_move, moved_spaces, total_board, dont_move) # \GuardClause
    # rubocop:disable Style\GuardClause
    # moved_spaces = rook_to_move.current_position if moved_spaces.nil?

    return false if moved_spaces.nil?

    moved_spaces.each do |space|
      next unless total_board.flatten.any? { |item|
        item.current_position == space
      }

      puts 'total_board.flatten.any? rooks'
      to_be_captured_piece = check_for_opposing_piece(transform_used, new_position, rook_to_move,
                                                      total_board, dont_move)
      if to_be_captured_piece == false || dont_move == true
        puts 'rooks false'
        return false
      else
        puts 'rooks true CAPTURED'
        to_be_captured_piece.current_position = [-10, -10]
        to_be_captured_piece.captured = true
        return true
      end
    end
  end

  def check_for_opposing_piece(transform_used, new_position, rook_to_move, total_board, dont_move)
    total_board.flatten.any? do |to_be_captured_piece|
      if to_be_captured_piece.current_position == new_position && rook_to_move.team != (to_be_captured_piece.team) && !dont_move
        to_be_captured_piece.captured = true
        return to_be_captured_piece
      end
    end
    false
  end

  def vertical_up(_transform_used, new_position, rook_to_move, total_board)
    moved_spaces = []
    y = new_position[1]
    range = ((1)..(y - rook_to_move.current_y))
    transform = range.map { |i| [rook_to_move.current_x, rook_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def vertical_down(_transform_used, new_position, rook_to_move, total_board)
    moved_spaces = []
    y = new_position[1]
    range = ((1)..(rook_to_move.current_y - y))
    transform = range.map { |i| [rook_to_move.current_x, rook_to_move.current_y - i] }

    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def horizontal_left(transform_used, new_position, rook_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((rook_to_move.current_x - x)..(rook_to_move.current_y - y))
    transform = range.map { |i| [rook_to_move.current_x - i, rook_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def horizontal_right(transform_used, new_position, rook_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - rook_to_move.current_x)..(rook_to_move.current_y - y))
    transform = range.map { |i| [rook_to_move.current_x + i, rook_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end
end

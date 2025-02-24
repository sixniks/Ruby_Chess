class PAWNS
  # TO DO:
  # First turn move 2 spaces
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :pawn_transforms, :transforms, :has_moved, :range, :captured

  def initialize(name = '', x_pos = 1, y_pos = 2)
    @captured = false
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
      @range.map { |i| [@x_pos + i, @y_pos + i] }, # diagonaol up-right
      @range.map { |i| [@x_pos - i, @y_pos - i] }, # diagonaol down-left
      @range.map { |i| [@x_pos + i, @y_pos - i] } # diagonaol down-right
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

  def move_pawn(selected_position, new_position, total_board, game)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]
    new_position.map do |num|
      if num > 8 || num < 1
        puts 'Please select a position that is within the board'
        return false
      end
    end
    pawn_to_move = find_pawn(selected_position, total_board)

    pawn_to_move.range = (1..1)
    pawn_to_move.range = (1..2) unless pawn_to_move.has_moved == true

    pawn_to_move.transforms = [
      # rubocop:enable all
      pawn_to_move.range.map do |i|
        [pawn_to_move.x_pos, pawn_to_move.y_pos + i, 'vertical up'] unless pawn_to_move.name == 'black_pawns'
      end,
      pawn_to_move.range.map do |i|
        [pawn_to_move.x_pos, pawn_to_move.y_pos - i, 'vertical down'] unless pawn_to_move.name == 'white_pawns'
      end,
      pawn_to_move.range.map do |i|
        [pawn_to_move.x_pos - i, pawn_to_move.y_pos + i, 'diagonaol up left'] unless pawn_to_move.name == 'black_pawns'
      end,
      pawn_to_move.range.map do |i|
        [pawn_to_move.x_pos + i, pawn_to_move.y_pos + i, 'diagonaol up right'] unless pawn_to_move.name == 'black_pawns'
      end,
      pawn_to_move.range.map do |i|
        unless pawn_to_move.name == 'white_pawns'
          [pawn_to_move.x_pos - i, pawn_to_move.y_pos - i,
           'diagonaol down left']
        end
      end,
      pawn_to_move.range.map do |i|
        unless pawn_to_move.name == 'white_pawns'
          [pawn_to_move.x_pos + i, pawn_to_move.y_pos - i,
           'diagonaol down right']
        end
      end
    ]
    pawn_to_move.transforms.each do |item|
      item.each do |item2|
        transform_used = item2.pop unless item2.nil?
        next unless item2 == new_position

        p transform_used
        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, pawn_to_move, total_board)
        p moved_spaces

        next if moved_spaces && check_for_collision(transform_used, new_position, pawn_to_move, moved_spaces,
                                                    total_board) == (false)

        total_board.delete(pawn_to_move)
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
    end
    redo_move(total_board, pawn_to_move, game, collission = false)
  end

  def find_pawn(selected_position, total_board)
    total_board.flatten.find { |pawn| pawn.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, pawn_to_move, total_board)
    case transform_used
    when 'vertical up' then vertical_up(transform_used, new_position, pawn_to_move, total_board)
    when 'vertical down' then vertical_down(transform_used, new_position, pawn_to_move, total_board)
    when 'diagonaol up left' then diagonaol_up_left(transform_used, new_position, pawn_to_move, total_board)
    when 'diagonaol up right' then diagonaol_up_right(transform_used, new_position, pawn_to_move, total_board)
    when 'diagonaol down right' then diagonaol_down_right(transform_used, new_position, pawn_to_move, total_board)
    when 'diagonaol down left' then diagonaol_down_left(transform_used, new_position, pawn_to_move, total_board)
    end
  end

  def redo_move(total_board, pawn_to_move, game, collission = false)
    puts 'There is a piece in the way, did you mean to capture a piece?' if collission
    puts 'That piece can not move that way' unless collission
    total_board << pawn_to_move
    puts 'Please reselect a piece.'
    game.render
    selected_position = gets.chomp.split(',').map(&:to_i)
    puts "\e[H\e[2J"
    puts 'Please select where you want the piece to move'
    game.render
    new_position = gets.chomp.split(',').map(&:to_i)
    move_pawn(selected_position, new_position, total_board, game)
    total_board
  end

  def check_for_collision(transform_used, new_position, pawn_to_move, moved_spaces, total_board)
    moved_spaces.each do |space|
      next unless total_board.flatten.any? { |item| item.current_position == space }

      puts 'total_board.flatten.any?'
      to_be_captured_piece = check_for_opposing_piece(transform_used, new_position, pawn_to_move,
                                                      total_board)
      if to_be_captured_piece == false
        puts 'check_for_collision: false'
        return false
      else
        puts 'check_for_collision: true'
        to_be_captured_piece.current_position = [-10, -10]
        to_be_captured_piece.captured = true
        return true
      end
    end
  end

  def check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board)
    total_board.flatten.any? do |to_be_captured_piece|
      if to_be_captured_piece.current_position == new_position && pawn_to_move.name != (to_be_captured_piece.name) && transform_used.include?('diagonaol')
        to_be_captured_piece.captured = true
        puts 'check_for_opposing_piece true'
        return to_be_captured_piece
      end
    end
    puts 'reached false'
    false
  end

  def vertical_up(_transform_used, new_position, pawn_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - pawn_to_move.current_x + 1)..(y - pawn_to_move.current_y))
    p range
    transform = range.map { |i| [pawn_to_move.current_x, pawn_to_move.current_y + i] }
    puts "transform is #{transform}"
    moved_spaces << transform
    puts "moved_spaces is #{moved_spaces}"
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    puts "fixed_moved_spaces is #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def vertical_down(_transform_used, new_position, pawn_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((pawn_to_move.current_x - x + 1)..(pawn_to_move.current_y - y))
    transform = range.map { |i| [pawn_to_move.current_x, pawn_to_move.current_y - i] }

    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_up_left(transform_used, new_position, pawn_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - pawn_to_move.current_x)..(y - pawn_to_move.current_y))
    transform = range.map { |i| [pawn_to_move.current_x - i, pawn_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # return false if check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board) == false

    fixed_moved_spaces
  end

  def diagonaol_up_right(transform_used, new_position, pawn_to_move, total_board)
    moved_spaces = []
    range = (1..1)
    transform = range.map { |i| [pawn_to_move.current_x + i, pawn_to_move.current_y + i] }

    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # return false if check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board) == false

    fixed_moved_spaces
  end

  def diagonaol_down_left(transform_used, new_position, pawn_to_move, total_board)
    moved_spaces = []
    transform = pawn_to_move.current_x - 1, pawn_to_move.current_y - 1
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # return false if check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board) == false

    fixed_moved_spaces
  end

  def diagonaol_down_right(transform_used, new_position, pawn_to_move, total_board)
    moved_spaces = []
    transform = pawn_to_move.current_x + 1, pawn_to_move.current_y - 1
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # return false if check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board) == false
    fixed_moved_spaces
  end
end

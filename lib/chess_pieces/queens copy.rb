class QUEENS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :queen_transforms, :transforms, :has_moved, :range, :captured, :team

  def initialize(team = '', name = '', x_pos = 1, y_pos = 2)
    @count_queen = 0
    @team = team
    @captured = false
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
      @range.map { |i| [@x_pos, @y_pos + i] }, # vertical up
      @range.map { |i| [@x_pos, @y_pos - i] }, # vertical down
      @range.map { |i| [@x_pos - i, @y_pos + i] }, # diagonaol up-left
      @range.map { |i| [@x_pos + i, @y_pos + i] }, # diagonaol up-right
      @range.map { |i| [@x_pos - i, @y_pos - i] }, # diagonaol down-left
      @range.map { |i| [@x_pos + i, @y_pos - i] }, # diagonaol down-right
      @range.map { |i| [@x_pos, @y_pos] }
    ]
  end

  def make_queens
    @black_queen = QUEENS.new('black', 'Black Queen', 4, 8)
    @white_queen = QUEENS.new('white', 'White Queen', 4, 1)
    @queens = @black_queen, @white_queen
  end

  def move_queen(selected_position, new_position, total_board, game, dont_move)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]
    queen_to_move = find_queen(selected_position, total_board)

    queen_to_move.range = (1..7)

    queen_to_move.transforms = [
      queen_to_move.range.map { |i| [queen_to_move.x_pos, queen_to_move.y_pos + i, 'vertical up'] }, # vertical up
      queen_to_move.range.map { |i| [queen_to_move.x_pos, queen_to_move.y_pos - i, 'vertical down'] }, # vertical down
      queen_to_move.range.map do |i|
        [queen_to_move.x_pos + i, queen_to_move.y_pos, 'horizontal right']
      end,
      queen_to_move.range.map do |i|
        [queen_to_move.x_pos - i, queen_to_move.y_pos, 'horizontal left']
      end,
      queen_to_move.range.map do |i|
        [queen_to_move.x_pos - i, queen_to_move.y_pos + i, 'diagonaol up-left']
      end,
      queen_to_move.range.map do |i|
        [queen_to_move.x_pos + i, queen_to_move.y_pos + i, 'diagonaol up-right']
      end,
      queen_to_move.range.map do |i|
        [queen_to_move.x_pos - i, queen_to_move.y_pos - i, 'diagonaol down-left']
      end,
      queen_to_move.range.map do |i|
        [queen_to_move.x_pos + i, queen_to_move.y_pos - i, 'diagonaol down-right']
      end,
      queen_to_move.range.map { |i| [queen_to_move.x_pos, queen_to_move.y_pos, 'No move'] } # No move
    ]
    queen_to_move.transforms.each do |item|
      item.each do |item2|
        transform_used = item2.pop unless item2.nil?
        next unless item2 == new_position

        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, queen_to_move, total_board)
        puts "moved spaces is #{moved_spaces}"
        if moved_spaces.nil? || check_for_collision(transform_used, new_position, queen_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          return false
        else

          puts 'True?'
          # total_board.delete(queen_to_move) unless dont_move
          queen_to_move.current_position = new_position unless dont_move
          queen_to_move.has_moved = true unless dont_move
          queen_to_move.y_pos = new_position[1] unless dont_move
          queen_to_move.x_pos = new_position[0] unless dont_move
          @x_pos = new_position[0] unless dont_move
          @y_pos = new_position[1] unless dont_move
          queen_to_move.current_y = new_position[1] unless dont_move
          queen_to_move.current_x = new_position[0] unless dont_move
          total_board << queen_to_move unless dont_move

          return total_board
        end
      end
    end
    return false
    puts 'REACHED false'
  end

  def get_possible_moves(total_board, game)
    dont_move = true
    queen_transforms_black = []
    queen_transforms_white = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Queen')

      selected_position = piece.current_position
      new_position = piece.transforms.each
      new_position.each do |pos|
        pos.map do |pos2|
          next unless move_queen(selected_position, pos2, total_board, game, dont_move) != false

          piece.transforms.clear

          if piece.team == 'white'
            if !pos2.nil? && !(pos2[0] > 8 || pos2[0] < 1 || pos2[1] > 8 || pos2[1] < 1)
              queen_transforms_white << pos2
              piece.transforms << pos2
            end
          elsif piece.team == 'black'
            if !pos2.nil? && !(pos2[0] > 8 || pos2[0] < 1 || pos2[1] > 8 || pos2[1] < 1)
              queen_transforms_black << pos2
              piece.transforms << pos2
            end
          end
        end
      end
    end
    [queen_transforms_black, queen_transforms_white]
  end

  def find_queen(selected_position, total_board)
    total_board.flatten.find { |queen| queen.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, queen_to_move, total_board)
    puts "#{transform_used}transformed used"
    case transform_used
    when 'vertical up' then vertical_up(transform_used, new_position, queen_to_move, total_board)
    when 'vertical down' then vertical_down(transform_used, new_position, queen_to_move, total_board)
    when 'diagonaol up left' then diagonaol_up_left(transform_used, new_position, queen_to_move, total_board)
    when 'diagonaol up right' then diagonaol_up_right(transform_used, new_position, queen_to_move, total_board)
    when 'diagonaol down right' then diagonaol_down_right(transform_used, new_position, queen_to_move, total_board)
    when 'diagonaol down left' then diagonaol_down_left(transform_used, new_position, queen_to_move, total_board)
    when 'horizontal right' then horizontal_right(transform_used, new_position, queen_to_move, total_board)
    when 'horizontal left' then horizontal_left(transform_used, new_position, queen_to_move, total_board)
    end
  end

  def check_for_collision(transform_used, new_position, queen_to_move, moved_spaces, total_board, dont_move)
    # rubocop:disable Style\GuardClause
    return false if moved_spaces.nil?

    # @count_queen += 1
    # puts "count queen is #{@count_queen}"
    moved_spaces.each do |space|
      next unless total_board.flatten.any? { |item|
        item.current_position == space
      }

      puts 'total_board.flatten.any? queen'
      to_be_captured_piece = check_for_opposing_piece(transform_used, new_position, queen_to_move,
                                                      total_board, dont_move)
      if to_be_captured_piece == false || dont_move == true
        puts "false QUEEN"
        return false
      else
        puts "true CAPTURED"
        to_be_captured_piece.current_position = [-10, -10]
        to_be_captured_piece.captured = true
        return true
      end
    end
    puts "end FALSE"
  end

  def check_for_opposing_piece(transform_used, new_position, queen_to_move, total_board, dont_move)
    total_board.flatten.any? do |to_be_captured_piece|
      if to_be_captured_piece.current_position == new_position && queen_to_move.team != (to_be_captured_piece.team) && !dont_move
        to_be_captured_piece.captured = true
        return to_be_captured_piece
      end
    end
    puts "false check_for_opposing_piece "
    false
  end

  def vertical_up(_transform_used, new_position, queen_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((1)..(y - queen_to_move.current_y))
    transform = range.map { |i| [queen_to_move.current_x, queen_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def vertical_down(_transform_used, new_position, queen_to_move, total_board)
    moved_spaces = []
    y = new_position[1]
    range = ((1)..(queen_to_move.current_y - y))
    transform = range.map { |i| [queen_to_move.current_x, queen_to_move.current_y - i] }

    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_up_left(transform_used, new_position, queen_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - queen_to_move.current_x)..(y - queen_to_move.current_y))
    transform = range.map { |i| [queen_to_move.current_x - i, queen_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_up_right(transform_used, new_position, queen_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - queen_to_move.current_x)..(y - queen_to_move.current_y))
    transform = range.map { |i| [queen_to_move.current_x + i, queen_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_down_left(transform_used, new_position, queen_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((queen_to_move.current_x - x)..(queen_to_move.current_y - y))
    transform = range.map { |i| [queen_to_move.current_x - i, queen_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_down_right(transform_used, new_position, queen_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((queen_to_move.current_x - x)..(queen_to_move.current_y - y))
    transform = range.map { |i| [queen_to_move.current_x + i, queen_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def horizontal_left(transform_used, new_position, queen_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((queen_to_move.current_x - x)..(queen_to_move.current_y - y))
    transform = range.map { |i| [queen_to_move.current_x - i, queen_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def horizontal_right(transform_used, new_position, queen_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - queen_to_move.current_x)..(queen_to_move.current_y - y))
    transform = range.map { |i| [queen_to_move.current_x + i, queen_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end
end

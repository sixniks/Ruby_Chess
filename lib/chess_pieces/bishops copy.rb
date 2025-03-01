class BISHOPS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :bishop_transforms, :transforms, :has_moved, :range, :captured, :team

  def initialize(team = '', name = '', x_pos = 1, y_pos = 2)
    @count_bishop = 0
    @team = team
    @captured = false
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
      @range.map { |i| [@x_pos, @y_pos + i] }, # vertical up
      @range.map { |i| [@x_pos, @y_pos - i] }, # vertical down
      @range.map { |i| [@x_pos - i, @y_pos + i] }, # diagonaol up-left
      @range.map { |i| [@x_pos + i, @y_pos + i] }, # diagonaol up-right
      @range.map { |i| [@x_pos - i, @y_pos - i] }, # diagonaol down-left
      @range.map { |i| [@x_pos + i, @y_pos - i] }, # diagonaol down-right
      @range.map { |i| [@x_pos, @y_pos] }
    ]
  end

  def make_bishops
    @bishop_black_left = BISHOPS.new('black', 'Black Bishop', 3, 8)
    @bishop_black_right = BISHOPS.new('black', 'Black Bishop', 6, 8)
    @bishop_white_left = BISHOPS.new('white', 'White Bishop', 3, 1)
    @bishop_white_right = BISHOPS.new('white', 'White Bishop', 6, 1)
    @bishops = @bishop_black_left, @bishop_black_right, @bishop_white_left, @bishop_white_right
  end

  def move_bishop(selected_position, new_position, total_board, game, dont_move)
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]
    # new_position.map do |num|
    #   if num > 8 || num < 1
    #     puts 'Please select a position that is within the board'
    #     return false
    #   end
    # end
    bishop_to_move = find_bishop(selected_position, total_board)

    bishop_to_move.range = (1..7)

    bishop_to_move.transforms = [
      bishop_to_move.range.map do |i|
        [bishop_to_move.x_pos - i, bishop_to_move.y_pos + i, 'diagonaol up-left']
      end,
      bishop_to_move.range.map do |i|
        [bishop_to_move.x_pos + i, bishop_to_move.y_pos + i, 'diagonaol up-right']
      end,
      bishop_to_move.range.map do |i|
        [bishop_to_move.x_pos - i, bishop_to_move.y_pos - i, 'diagonaol down-left']
      end,
      bishop_to_move.range.map do |i|
        [bishop_to_move.x_pos + i, bishop_to_move.y_pos - i, 'diagonaol down-right']
      end,
      bishop_to_move.range.map { |i| [bishop_to_move.x_pos, bishop_to_move.y_pos, 'No move'] } # No move
    ]
    bishop_to_move.transforms.each do |item|
      item.each do |item2|
        transform_used = item2.pop unless item2.nil?
        next unless item2 == new_position

        # p transform_used
        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, bishop_to_move, total_board)
        # p moved_spaces

        if moved_spaces.nil? || check_for_collision(transform_used, new_position, bishop_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          return false
        else

          total_board.delete(bishop_to_move) unless dont_move
          bishop_to_move.current_position = new_position unless dont_move
          bishop_to_move.has_moved = true unless dont_move
          bishop_to_move.y_pos = new_position[1] unless dont_move
          bishop_to_move.x_pos = new_position[0] unless dont_move
          @x_pos = new_position[0] unless dont_move
          @y_pos = new_position[1] unless dont_move
          bishop_to_move.current_y = new_position[1] unless dont_move
          bishop_to_move.current_x = new_position[0] unless dont_move
          total_board << bishop_to_move unless dont_move

          return total_board
        end
      end
    end
    false
  end

  def get_possible_moves(total_board, game)
    dont_move = true
    bishop_transforms_black = []
    bishop_transforms_white = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Bishop')

      selected_position = piece.current_position
      new_position = piece.transforms.each
      new_position.each do |pos|
        pos.map do |pos2|
          next unless move_bishop(selected_position, pos2, total_board, game, dont_move) != false

          piece.transforms.clear

          if piece.team == 'white'
            if !pos2.nil? && !(pos2[0] > 8 || pos2[0] < 1 || pos2[1] > 8 || pos2[1] < 1)
              bishop_transforms_white << pos2
              piece.transforms << pos2
            end
          elsif piece.team == 'black'
            if !pos2.nil? && !(pos2[0] > 8 || pos2[0] < 1 || pos2[1] > 8 || pos2[1] < 1)
              bishop_transforms_black << pos2
              piece.transforms << pos2
            end
          end
        end
      end
    end
    [bishop_transforms_black, bishop_transforms_white]
  end

  def find_bishop(selected_position, total_board)
    total_board.flatten.find { |bishop| bishop.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, bishop_to_move, total_board)
    case transform_used
    when 'vertical up' then vertical_up(transform_used, new_position, bishop_to_move, total_board)
    when 'vertical down' then vertical_down(transform_used, new_position, bishop_to_move, total_board)
    when 'diagonaol up left' then diagonaol_up_left(transform_used, new_position, bishop_to_move, total_board)
    when 'diagonaol up right' then diagonaol_up_right(transform_used, new_position, bishop_to_move, total_board)
    when 'diagonaol down right' then diagonaol_down_right(transform_used, new_position, bishop_to_move, total_board)
    when 'diagonaol down left' then diagonaol_down_left(transform_used, new_position, bishop_to_move, total_board)
    when 'horizontal right' then horizontal_right(transform_used, new_position, bishop_to_move, total_board)
    when 'horizontal left' then horizontal_left(transform_used, new_position, bishop_to_move, total_board)
    end
  end

  def check_for_collision(transform_used, new_position, bishop_to_move, moved_spaces, total_board, dont_move)
    # rubocop:disable Style\GuardClause
    return false if moved_spaces.nil?

    @count_bishop += 1
    puts "count bishop is #{@count_bishop}"
    moved_spaces.each do |space|
      next unless total_board.flatten.any? { |item|
        item.current_position == space
      }

      puts 'total_board.flatten.any? bishops'
      to_be_captured_piece = check_for_opposing_piece(transform_used, new_position, bishop_to_move,
                                                      total_board, dont_move)
      if to_be_captured_piece == false || dont_move == true
        return false
      else
        to_be_captured_piece.current_position = [-10, -10]
        to_be_captured_piece.captured = true
        return true
      end
    end
  end

  def check_for_opposing_piece(transform_used, new_position, bishop_to_move, total_board, dont_move)
    total_board.flatten.any? do |to_be_captured_piece|
      if to_be_captured_piece.current_position == new_position && bishop_to_move.team != (to_be_captured_piece.team) && !dont_move
        to_be_captured_piece.captured = true
        puts 'check_for_opposing_piece true'
        return to_be_captured_piece
      end
    end
    false
  end

  def vertical_up(_transform_used, new_position, bishop_to_move, total_board)
    moved_spaces = []
    y = new_position[1]
    range = ((1)..(y - bishop_to_move.current_y))
    transform = range.map { |i| [bishop_to_move.current_x, bishop_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def vertical_down(_transform_used, new_position, bishop_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((1)..(bishop_to_move.current_y - y))
    transform = range.map { |i| [bishop_to_move.current_x, bishop_to_move.current_y - i] }

    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_up_left(transform_used, new_position, bishop_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - bishop_to_move.current_x)..(y - bishop_to_move.current_y))
    transform = range.map { |i| [bishop_to_move.current_x - i, bishop_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_up_right(transform_used, new_position, bishop_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - bishop_to_move.current_x)..(y - bishop_to_move.current_y))
    transform = range.map { |i| [bishop_to_move.current_x + i, bishop_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_down_left(transform_used, new_position, bishop_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((bishop_to_move.current_x - x)..(bishop_to_move.current_y - y))
    transform = range.map { |i| [bishop_to_move.current_x - i, bishop_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_down_right(transform_used, new_position, bishop_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((bishop_to_move.current_x - x)..(bishop_to_move.current_y - y))
    transform = range.map { |i| [bishop_to_move.current_x + i, bishop_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def horizontal_left(transform_used, new_position, bishop_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((bishop_to_move.current_x - x)..(bishop_to_move.current_y - y))
    transform = range.map { |i| [bishop_to_move.current_x - i, bishop_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def horizontal_right(transform_used, new_position, bishop_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - bishop_to_move.current_x)..(bishop_to_move.current_y - y))
    transform = range.map { |i| [bishop_to_move.current_x + i, bishop_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end
end

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
    @range = (1..7)
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
    # @x_pos = selected_position[0]
    # @y_pos = selected_position[1]

    queen_to_move = find_queen(selected_position, total_board)
    # puts "queen_to_move.transforms #{queen_to_move.transforms}"
    queen_to_move.transforms.each do |item|
      # puts "item is #{item}"
      item.each do |item2|
        # puts "item2 is #{item2}"
        # puts "item2 inx 0 is #{item2[2]}"
        # next unless item2.nil? || item2 == Integer
        next if item2.nil?

        transform_used = item2[2]
        index_0 = item2[0]
        index_1 = item2[1]
        find_pos = [index_0, index_1]
        # p find_pos
        # p "new pos UP #{new_position}"
        # puts "transform_used is #{transform_used}"
        next unless find_pos == new_position

        # puts 'FOUND'
        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, queen_to_move, total_board)
        # puts "moved spaces is #{moved_spaces}"
        if moved_spaces.nil? || check_for_collision(transform_used, new_position, queen_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          return false
        else

          # puts 'True?'
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

  def update_transforms(total_board)
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Queen')

      piece.transforms = [
        piece.range.map { |i| [piece.x_pos, piece.y_pos + i, 'vertical up'] }, # vertical up
        piece.range.map { |i| [piece.x_pos, piece.y_pos - i, 'vertical down'] }, # vertical down
        piece.range.map do |i|
          [piece.x_pos + i, piece.y_pos, 'horizontal right']
        end,
        piece.range.map do |i|
          [piece.x_pos - i, piece.y_pos, 'horizontal left']
        end,
        piece.range.map do |i|
          [piece.x_pos - i, piece.y_pos + i, 'diagonaol up left']
        end,
        piece.range.map do |i|
          [piece.x_pos + i, piece.y_pos + i, 'diagonaol up right']
        end,
        piece.range.map do |i|
          [piece.x_pos - i, piece.y_pos - i, 'diagonaol down left']
        end,
        piece.range.map do |i|
          [piece.x_pos + i, piece.y_pos - i, 'diagonaol down right']
        end
        # piece.range.map { |i| [piece.x_pos, piece.y_pos, 'No move'] } # No move
      ]
    end
  end

  def get_possible_moves(total_board, game)
    update_transforms(total_board)
    dont_move = true
    queen_transforms_black = []
    queen_transforms_white = []
    queen_transforms = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Queen')

      piece.transforms.each do |transform_pair|
        transform_pair.each do |transform|
          next if transform.nil?

          queen_transforms << [transform[0], transform[1], piece.team,
                               piece.current_position]
          puts "transforms #{[transform[0], transform[1]]}"
        end
      end
    end
    # p queen_transforms
    # selected_position = []
    queen_transforms.each do |transform|
      # puts "transform #{transform}"
      # next if selected_position == transform[3]

      selected_position = transform[3]

      new_position = [transform[0], transform[1]]
      # puts "new position is #{new_position}"
      next unless move_queen(selected_position, new_position, total_board, game, dont_move = true) != false

      if transform.include?('white')
        queen_transforms_white << [transform[0], transform[1]]
      elsif transform.include?('black')
        queen_transforms_black << [transform[0], transform[1]]
      end
    end

    [queen_transforms_black, queen_transforms_white]
  end

  def find_queen(selected_position, total_board)
    total_board.flatten.find { |queen| queen.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, queen_to_move, total_board)
    # puts "#{transform_used}transformed used"
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

  def check_for_collision(transform_used, new_position, queen_to_move, moved_spaces, total_board, dont_move) # \GuardClause
    # rubocop:disable Style\GuardClause
    p "moved spaces is col UP #{moved_spaces}"
    return false if moved_spaces.nil? || moved_spaces == false

    # @count += 1
    # puts "count is #{@count}"
    p "moved spaces is #{moved_spaces}"
    moved_spaces.each do |space|
      return true if total_board.flatten.any? { |item| item.current_position == space } == false

      puts 'total_board.flatten.any? queens'
      to_be_captured_piece = check_for_opposing_piece(transform_used, new_position, queen_to_move,
                                                      total_board)
      # puts "dont move #{dont_move}"
      # puts "to_be_captured_piece #{to_be_captured_piece}"
      puts "dont move is #{dont_move}"
      if dont_move == true

        return true
      elsif to_be_captured_piece != false
        puts "Captured piece"
        to_be_captured_piece.current_position = [-10, -10]
        to_be_captured_piece.captured = true
        return true
      elsif dont_move != true && to_be_captured_piece == false
        puts "true"
        return true
      end
    end
    false
  end

  def check_for_opposing_piece(transform_used, new_position, queen_to_move, total_board)
    total_board.flatten.any? do |to_be_captured_piece|
      next unless to_be_captured_piece.current_position == new_position

      # puts "to_be_captured_piece current_position #{to_be_captured_piece.current_position}"
      # puts "new position #{new_position}"

      if queen_to_move.team != (to_be_captured_piece.team)
        puts 'true'
        return to_be_captured_piece
      else
        puts 'false'
        return false
      end
    end
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
    range = ((queen_to_move.current_x - x)..(y - queen_to_move.current_y))
    p range
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

class PAWNS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :pawn_transforms_black, :pawn_transforms_white, :transforms, :has_moved, :range, :captured, :team

  def initialize(team = '', name = '', x_pos = 1, y_pos = 2)
    # @pawn_transforms_white = []
    # @pawn_transforms_black = []
    @count = 0
    @count_pawn = 0
    @team = team
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
      @range.map { |i| [@x_pos, @y_pos + i, 'vertical up'] unless self.name == 'Black Pawn' },
      @range.map { |i| [@x_pos, @y_pos - i, 'vertical down'] unless self.name == 'White Pawn' },
      (1..1).map { |i| [@x_pos - i, @y_pos + i, 'diagonaol up left'] unless self.name == 'Black Pawn' },
      (1..1).map { |i| [@x_pos + i, @y_pos + i, 'diagonaol up right'] unless self.name == 'Black Pawn' },
      (1..1).map { |i| [@x_pos - i, @y_pos - i, 'diagonaol down left'] unless self.name == 'White Pawn' },
      (1..1).map { |i| [@x_pos + i, @y_pos - i, 'diagonaol down right'] unless self.name == 'White Pawn' },
      (1..1).map { |i| [@x_pos, @y_pos, 'no move'] }
    ]
  end

  def make_pawns
    @pawns_arr << (1..8).map do |i|
      PAWNS.new('white', 'White Pawn', i, 2)
    end
    @pawns_arr << (1..8).map do |i|
      PAWNS.new('black', 'Black Pawn', i, 7)
    end
  end

  def move_pawn(selected_position, new_position, total_board, game, dont_move)
    # @x_pos = selected_position[0]
    # @y_pos = selected_position[1]

    total_board.flatten.each do |piece|
      next unless piece.name.include?('Pawn')

      piece.range = (1..1)
      piece.range = (1..2) unless piece.has_moved == true
      piece.transforms =
        [

          # rubocop:enable all
          piece.range.map do |i|
            [piece.x_pos, piece.y_pos + i, 'vertical up'] unless piece.name == 'Black Pawn'
          end,
          piece.range.map do |i|
            [piece.x_pos, piece.y_pos - i, 'vertical down'] unless piece.name == 'White Pawn'
          end,
          (1..1).map do |i|
            unless piece.name == 'Black Pawn'
              [piece.x_pos - i, piece.y_pos + i,
               'diagonaol up left']
            end
          end,
          (1..1).map do |i|
            unless piece.name == 'Black Pawn'
              [piece.x_pos + i, piece.y_pos + i,
               'diagonaol up right']
            end
          end,
          (1..1).map do |i|
            unless piece.name == 'White Pawn'
              [piece.x_pos - i, piece.y_pos - i,
               'diagonaol down left']
            end
          end,
          (1..1).map do |i|
            unless piece.name == 'White Pawn'
              [piece.x_pos + i, piece.y_pos - i,
               'diagonaol down right']
            end
          end
        ]
    end
    pawn_to_move = find_pawn(selected_position, total_board)
    # puts "pawn to move transforms #{pawn_to_move.transforms}"
    pawn_to_move.transforms.each do |item|
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
        puts "transform_used is #{transform_used}"
        next unless find_pos == new_position

        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, pawn_to_move, total_board)
        puts "moved spaces UP #{moved_spaces}"
        if moved_spaces.nil? || check_for_collision(transform_used, new_position, pawn_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          puts 'FALSE'
          return false
        else
          puts 'NOT FALSE'
          # total_board.delete(pawn_to_move) unless dont_move
          pawn_to_move.current_position = new_position unless dont_move
          pawn_to_move.has_moved = true unless dont_move
          pawn_to_move.y_pos = new_position[1] unless dont_move
          pawn_to_move.x_pos = new_position[0] unless dont_move
          @x_pos = new_position[0] unless dont_move
          @y_pos = new_position[1] unless dont_move
          pawn_to_move.current_y = new_position[1] unless dont_move
          pawn_to_move.current_x = new_position[0] unless dont_move
          total_board << pawn_to_move unless dont_move
          # puts "new pos after move #{pawn_to_move.current_position}"
          return total_board
        end
      end
    end
    # puts 'REACHED FALSE'
    false
  end

  def get_possible_moves(total_board, game)
    dont_move = true
    pawn_transforms_black = []
    pawn_transforms_white = []
    pawn_transforms = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Pawn')

      piece.transforms.each do |transform_pair|
        transform_pair.each do |transform|
          next if transform.nil?

          pawn_transforms << [transform[0], transform[1], piece.team, piece.current_position]
        end
      end
    end
    # p pawn_transforms
    # selected_position = []
    pawn_transforms.each do |transform|
      # puts "transform #{transform}"
      # next if selected_position == transform[3]

      selected_position = transform[3]

      new_position = [transform[0], transform[1]]
      next unless move_pawn(selected_position, new_position, total_board, game, dont_move = true) != false

      if transform.include?('white')
        pawn_transforms_white << [transform[0], transform[1]]
      elsif transform.include?('black')
        pawn_transforms_black << [transform[0], transform[1]]
      end
    end

    [pawn_transforms_black, pawn_transforms_white]
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

  def check_for_collision(transform_used, new_position, pawn_to_move, moved_spaces, total_board, dont_move)
    # rubocop:disable Style\GuardClause
    p "moved spaces is col UP #{moved_spaces}"
    return false if moved_spaces.nil? || moved_spaces == false

    # @count += 1
    # puts "count is #{@count}"
    p "moved spaces is #{moved_spaces}"
    moved_spaces.each do |space|
      return true if total_board.flatten.any? { |item| item.current_position == space } == false

      puts 'total_board.flatten.any? pawns'
      to_be_captured_piece = check_for_opposing_piece(transform_used, new_position, pawn_to_move,
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

  def check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board)
    total_board.flatten.each do |to_be_captured_piece|
      # puts "transform #{transform_used}"
      # puts "to be cap pos #{to_be_captured_piece.current_position}"
      # puts "new pos #{new_position}"
      next unless to_be_captured_piece.current_position == new_position

      puts "to_be_captured_piece current_position #{to_be_captured_piece.current_position}"
      puts "new position #{new_position}"

      if pawn_to_move.team != (to_be_captured_piece.team) && transform_used.include?('diagonaol')
        puts "true"
        return to_be_captured_piece
      else
        puts "false"
        return false
      end
    end
  end

  def vertical_up(_transform_used, new_position, pawn_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((x - pawn_to_move.current_x + 1)..(y - pawn_to_move.current_y))
    transform = range.map { |i| [pawn_to_move.current_x, pawn_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    puts "fixed moved spaces #{fixed_moved_spaces}"
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
    range = ((pawn_to_move.current_x - x)..(y - pawn_to_move.current_y))
    transform = range.map { |i| [pawn_to_move.current_x - i, pawn_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    return false if check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board,) == false

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
    if check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board,) == false
      return false
    end

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
    return false if check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board,) == false

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
    return false if check_for_opposing_piece(transform_used, new_position, pawn_to_move, total_board,) == false

    fixed_moved_spaces
  end
end

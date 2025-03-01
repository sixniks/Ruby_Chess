class KINGS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :king_transforms, :transforms, :has_moved, :range, :captured, :team

  def initialize(team = '', name = '', x_pos = 1, y_pos = 2)
    @team = team
    @captured = false
    @kings_arr = []
    @has_moved = false
    @name = name
    @x_pos = x_pos
    @y_pos = y_pos
    @starting_pos = [x_pos, y_pos]
    @current_x = @x_pos
    @current_y = @y_pos
    @current_position = [@x_pos, @y_pos]
    @range = (1..1)
    @transforms = [
      @range.map { |i| [@x_pos, @y_pos + i] }, # vertical up
      @range.map { |i| [@x_pos, @y_pos - i] }, # vertical down
      @range.map { |i| [@x_pos - i, @y_pos + i] }, # diagonaol up-left
      @range.map { |i| [@x_pos + i, @y_pos + i] }, # diagonaol up-right
      @range.map { |i| [@x_pos - i, @y_pos - i] }, # diagonaol down-left
      @range.map { |i| [@x_pos + i, @y_pos - i] } # diagonaol down-right
      # @range.map { |i| [@x_pos, @y_pos] }
    ]
  end

  def make_kings
    @black_king = KINGS.new('black', 'Black King', 4, 4)
    @white_king = KINGS.new('white', 'White King', 5, 1)
    @kings = @black_king, @white_king
  end

  def move_king(selected_position, new_position, total_board, game, dont_move)
    # @x_pos = selected_position[0]
    # @y_pos = selected_position[1]
    total_board.flatten.each do |piece|
      next unless piece.name.include?('King')

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
    king_to_move = find_king(selected_position, total_board)
    # puts "king_to_move.transforms #{king_to_move.transforms}"
    king_to_move.transforms.each do |item|
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
        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, king_to_move, total_board)
        # puts "moved spaces is #{moved_spaces}"
        if moved_spaces.nil? || check_for_collision(transform_used, new_position, king_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          return false
        else

          # puts 'True?'
          # total_board.delete(king_to_move) unless dont_move
          king_to_move.current_position = new_position unless dont_move
          king_to_move.has_moved = true unless dont_move
          king_to_move.y_pos = new_position[1] unless dont_move
          king_to_move.x_pos = new_position[0] unless dont_move
          @x_pos = new_position[0] unless dont_move
          @y_pos = new_position[1] unless dont_move
          king_to_move.current_y = new_position[1] unless dont_move
          king_to_move.current_x = new_position[0] unless dont_move
          total_board << king_to_move unless dont_move

          return total_board
        end
      end
    end
    return false
    puts 'REACHED false'
  end

  def get_possible_moves(total_board, game)
    # update_transforms(total_board)
    dont_move = true
    king_transforms_black = []
    king_transforms_white = []
    king_transforms = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('King')

      piece.transforms.each do |transform_pair|
        transform_pair.each do |transform|
          next if transform.nil?

          king_transforms << [transform[0], transform[1], piece.team,
                              piece.current_position]
          # puts "transforms #{[transform[0], transform[1]]}"
        end
      end
    end
    # p king_transforms
    # selected_position = []
    king_transforms.each do |transform|
      # puts "transform #{transform}"
      # next if selected_position == transform[3]

      selected_position = transform[3]
      new_position = [transform[0], transform[1]] if transform[0].between?(1, 8) && transform [1].between?(1, 8)
      # puts "new position is #{new_position}"
      next unless move_king(selected_position, new_position, total_board, game, dont_move = true) != false

      if transform.include?('white')
        king_transforms_white << [transform[0], transform[1]]
      elsif transform.include?('black')
        king_transforms_black << [transform[0], transform[1]]
      end
    end
    [king_transforms_black.uniq, king_transforms_white.uniq]
  end

  def find_king(selected_position, total_board)
    total_board.flatten.find { |king| king.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, king_to_move, total_board)
    # puts "#{transform_used}transformed used"
    case transform_used
    when 'vertical up' then vertical_up(transform_used, new_position, king_to_move, total_board)
    when 'vertical down' then vertical_down(transform_used, new_position, king_to_move, total_board)
    when 'diagonaol up left' then diagonaol_up_left(transform_used, new_position, king_to_move, total_board)
    when 'diagonaol up right' then diagonaol_up_right(transform_used, new_position, king_to_move, total_board)
    when 'diagonaol down right' then diagonaol_down_right(transform_used, new_position, king_to_move, total_board)
    when 'diagonaol down left' then diagonaol_down_left(transform_used, new_position, king_to_move, total_board)
    when 'horizontal right' then horizontal_right(transform_used, new_position, king_to_move, total_board)
    when 'horizontal left' then horizontal_left(transform_used, new_position, king_to_move, total_board)
    end
  end

  def check_for_collision(transform_used, new_position, king_to_move, moved_spaces, total_board, dont_move) # \GuardClause
    # p "moved spaces is col UP #{moved_spaces}"
    # @count_king += 1
    # puts "count is #{@count_king}"
    # rubocop: enable all
    # IF there exists piece(s) in the moved spaces path and its not the last one(new position)
    # We know we are either capturing or colliding with own piece
    # [4,1]
    # [5,2]
    # [6,3]
    # [7,4]
    # [8,5]
    #
    return false if moved_spaces.nil? || moved_spaces == false

    # moved_spaces.shift if moved_spaces.length > 1
    moved_spaces.each do |space|
      next if space == king_to_move.current_position

      total_board.flatten.any? do |piece|
        # puts "piece current pos #{piece.current_position}"
        # puts "space #{space}"
        # puts "piece team #{piece.team}"
        # puts "king team #{king_to_move.team}"
        if piece.current_position == space && king_to_move.team == piece.team

          # puts 'Collision detected did you mean to capture a piece'
          return false
        elsif piece.current_position == space && king_to_move.team != piece.team && dont_move == false
          piece.current_position = [-10, -10]
          puts 'capture'
          return true
        elsif piece.current_position == space && king_to_move.team != piece.team && piece.current_position != new_position
          return false
        end
      end
    end
  end

  #   puts "reached"
  #   puts "moved spaces #{moved_spaces}"
  #   moved_spaces.each do |space|
  #   piece_in_the_way << total_board.flatten.find { |piece| piece.current_position == space }
  #       # puts "piece_in_the_way.current#{piece_in_the_way.team}" unless piece_in_the_way.nil?
  #       if piece_in_the_way.nil?
  #         puts "nil true"
  #         return true
  #       elsif  piece_in_the_way.each.instance_variable_get(:@team) != king_to_move.team && dont_move == false ## Check for opposing piece
  #         piece_in_the_way.current_position = [-10, -10]
  #           puts 'Captured true'
  #           return true
  #       elsif piece_in_the_way.each.current_position == king_to_move.current_position && piece_in_the_way.nil?
  #         return true
  #       else
  #         false
  #       end

  #     end
  #     puts "end false"
  #   false
  # end

  #     # puts 'total_board.flatten.any? kings'
  #     to_be_captured_piece = check_for_opposing_piece(transform_used, new_position, king_to_move,
  #                                                     total_board)
  #     # puts "dont move #{dont_move}"
  #     # puts "to_be_captured_piece #{to_be_captured_piece}"
  #     # puts "dont move is #{dont_move}"
  #     if dont_move == true && to_be_captured_piece != false
  #       puts '1st true'
  #       return true
  #     elsif to_be_captured_piece != false
  #       puts 'Captured piece'
  #       to_be_captured_piece.current_position = [-10, -10]
  #       to_be_captured_piece.captured = true
  #       return true
  #     elsif dont_move != true && to_be_captured_piece != false
  #       puts 'true'
  #       return true
  #     end
  #   end
  # end

  # def check_for_opposing_piece(transform_used, new_position, king_to_move, total_board)
  #   total_board.flatten.any? do |to_be_captured_piece|
  #     next unless to_be_captured_piece.current_position == new_position

  #     puts "to_be_captured_piece  #{to_be_captured_piece.current_position}"
  #     # puts "new position #{new_position}"

  #     if king_to_move.team != (to_be_captured_piece.team)
  #       puts 'true'
  #       puts "to be captured team #{to_be_captured_piece.team}"
  #       puts "king to move team #{king_to_move.team}"
  #       return to_be_captured_piece

  #       return false
  #     else
  #       puts 'false'
  #       return false
  #     end
  #   end
  # end

  def vertical_up(_transform_used, new_position, king_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((1)..(y - king_to_move.current_y))
    transform = range.map { |i| [king_to_move.current_x, king_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def vertical_down(_transform_used, new_position, king_to_move, total_board)
    moved_spaces = []
    y = new_position[1]
    range = ((1)..(king_to_move.current_y - y))
    transform = range.map { |i| [king_to_move.current_x, king_to_move.current_y - i] }

    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def diagonaol_up_left(transform_used, new_position, king_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((0)..(y - king_to_move.current_y))
    transform = range.map { |i| [king_to_move.current_x - i, king_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def diagonaol_up_right(transform_used, new_position, king_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((0)..(y - king_to_move.current_y))
    transform = range.map { |i| [king_to_move.current_x + i, king_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def diagonaol_down_left(transform_used, new_position, king_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((0)..(king_to_move.current_y - y))
    transform = range.map { |i| [king_to_move.current_x - i, king_to_move.current_y - i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def diagonaol_down_right(transform_used, new_position, king_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((0)..(king_to_move.current_y - y))
    transform = range.map { |i| [king_to_move.current_x + i, king_to_move.current_y - i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def horizontal_left(transform_used, new_position, king_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((0)..(king_to_move.current_x - x))
    transform = range.map { |i| [king_to_move.current_x - i, king_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def horizontal_right(transform_used, new_position, king_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((0)..(x - king_to_move.current_x))
    transform = range.map { |i| [king_to_move.current_x + i, king_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end
end

class KNIGHTS
  attr_accessor :starting_pos, :x_pos, :y_pos, :current_position, :name, :current_x,
                :current_y, :knight_transforms, :transforms, :has_moved, :range, :captured, :team

  def initialize(team = '', name = '', x_pos = 1, y_pos = 2)
    @team = team
    @captured = false
    @knights_arr = []
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
      @range.map { [@x_pos - 1, @y_pos + 2, 'Up Left L'] }, # Up-Left L
      @range.map { [@x_pos + 1, @y_pos + 2, 'Up Right L'] }, # Up-Right L
      @range.map { [@x_pos - 1, @y_pos - 2, 'Down Left L'] }, # Down-Left L
      @range.map { [@x_pos + 1, @y_pos - 2, 'Down Right L'] } # Down-Right L
      # [@x_pos, @y_pos]
    ]
  end

  def make_knights
    @white_knight_left = KNIGHTS.new('white', 'White Knight', 2, 1)
    @white_knight_right = KNIGHTS.new('white', 'White Knight', 7, 1)
    @black_knight_left = KNIGHTS.new('black', 'Black Knight', 2, 8)
    @black_knight_right = KNIGHTS.new('black', 'Black Knight', 7, 8)
    @knights = @white_knight_left, @white_knight_right, @black_knight_left, @black_knight_right
  end

  def move_knight(selected_position, new_position, total_board, game, dont_move)
    # @x_pos = selected_position[0]
    # @y_pos = selected_position[1]
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Knight')

      piece.range = (1..1)
      piece.transforms = [
        piece.range.map { [piece.x_pos - 1, piece.y_pos + 2, 'Up Left L'] }, # Up-Left L
        piece.range.map { [piece.x_pos + 1, piece.y_pos + 2, 'Up Right L'] }, # Up-Right L
        piece.range.map { [piece.x_pos - 1, piece.y_pos - 2, 'Down Left L'] }, # Down-Left L
        piece.range.map { [piece.x_pos + 1, piece.y_pos - 2, 'Down Right L'] } # Down-Right L
      ]
    end
    knight_to_move = find_knight(selected_position, total_board)
    # puts "knight_to_move.transforms #{knight_to_move.transforms}"
    knight_to_move.transforms.each do |item|
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
        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, knight_to_move, total_board)
        # puts "moved spaces is #{moved_spaces}"
        if moved_spaces.nil? || check_for_collision(transform_used, new_position, knight_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          return false
        else

          # puts 'True?'
          # total_board.delete(knight_to_move) unless dont_move
          knight_to_move.current_position = new_position unless dont_move
          knight_to_move.has_moved = true unless dont_move
          knight_to_move.y_pos = new_position[1] unless dont_move
          knight_to_move.x_pos = new_position[0] unless dont_move
          @x_pos = new_position[0] unless dont_move
          @y_pos = new_position[1] unless dont_move
          knight_to_move.current_y = new_position[1] unless dont_move
          knight_to_move.current_x = new_position[0] unless dont_move
          total_board << knight_to_move unless dont_move

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
    knight_transforms_black = []
    knight_transforms_white = []
    knight_transforms = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Knight')

      piece.transforms.each do |transform_pair|
        transform_pair.each do |transform|
          next if transform.nil?

          knight_transforms << [transform[0], transform[1], piece.team,
                                piece.current_position]
          # puts "transforms #{[transform[0], transform[1]]}"
        end
      end
    end
    # end
    # p knight_transforms
    # selected_position = []
    knight_transforms.each do |transform|
      # puts "transform #{transform}"
      # next if selected_position == transform[3]

      selected_position = transform[3]
      new_position = [transform[0], transform[1]] if transform[0].between?(1, 8) && transform [1].between?(1, 8)
      # puts "new position is #{new_position}"
      next unless move_knight(selected_position, new_position, total_board, game, dont_move = true) != false

      if transform.include?('white')
        knight_transforms_white << [transform[0], transform[1]]
      elsif transform.include?('black')
        knight_transforms_black << [transform[0], transform[1]]
      end
    end
    [knight_transforms_black.uniq, knight_transforms_white.uniq]
  end

  def find_knight(selected_position, total_board)
    total_board.flatten.find { |knight| knight.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, knight_to_move, total_board)
    # puts "#{transform_used}transformed used"
    case transform_used
    when 'Up Left L' then up_left_l(transform_used, new_position, knight_to_move, total_board)
    when 'Up Right L' then up_right_l(transform_used, new_position, knight_to_move, total_board)
    when 'Down Left L' then down_left_l(transform_used, new_position, knight_to_move, total_board)
    when 'Down Right L' then down_right_l(transform_used, new_position, knight_to_move, total_board)
    end
  end

  def check_for_collision(transform_used, new_position, knight_to_move, moved_spaces, total_board, dont_move) # \GuardClause
    # p "moved spaces is col UP #{moved_spaces}"
    # @count_knight += 1
    # puts "count is #{@count_knight}"
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
      next if space == knight_to_move.current_position

      total_board.flatten.any? do |piece|
        # puts "piece current pos #{piece.current_position}"
        # puts "space #{space}"
        # puts "piece team #{piece.team}"
        # puts "knight team #{knight_to_move.team}"
        if piece.current_position == space && knight_to_move.team != piece.team && dont_move == false && piece.current_position == new_position
          piece.current_position = [-10, -10]
          puts 'Capture'
          return true
        elsif piece.current_position == space && knight_to_move.team != piece.team && piece.current_position != new_position
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
  #       elsif  piece_in_the_way.each.instance_variable_get(:@team) != knight_to_move.team && dont_move == false ## Check for opposing piece
  #         piece_in_the_way.current_position = [-10, -10]
  #           puts 'Captured true'
  #           return true
  #       elsif piece_in_the_way.each.current_position == knight_to_move.current_position && piece_in_the_way.nil?
  #         return true
  #       else
  #         false
  #       end

  #     end
  #     puts "end false"
  #   false
  # end

  #     # puts 'total_board.flatten.any? knights'
  #     to_be_captured_piece = check_for_opposing_piece(transform_used, new_position, knight_to_move,
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

  # def check_for_opposing_piece(transform_used, new_position, knight_to_move, total_board)
  #   total_board.flatten.any? do |to_be_captured_piece|
  #     next unless to_be_captured_piece.current_position == new_position

  #     puts "to_be_captured_piece  #{to_be_captured_piece.current_position}"
  #     # puts "new position #{new_position}"

  #     if knight_to_move.team != (to_be_captured_piece.team)
  #       puts 'true'
  #       puts "to be captured team #{to_be_captured_piece.team}"
  #       puts "knight to move team #{knight_to_move.team}"
  #       return to_be_captured_piece

  #       return false
  #     else
  #       puts 'false'
  #       return false
  #     end
  #   end
  # end

  def up_left_l(transform_used, new_position, knight_to_move, total_board)
    moved_spaces = []
    transform = [knight_to_move.current_x - 1, knight_to_move.current_y + 2]
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def up_right_l(transform_used, new_position, knight_to_move, total_board)
    moved_spaces = []
    transform = [knight_to_move.current_x + 1, knight_to_move.current_y + 2]
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def down_right_l(transform_used, new_position, knight_to_move, total_board)
    moved_spaces = []
    transform = [knight_to_move.current_x + 1, knight_to_move.current_y - 2]
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def down_left_l(transform_used, new_position, knight_to_move, total_board)
    moved_spaces = []
    transform = [knight_to_move.current_x - 1, knight_to_move.current_y - 2]
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end
end

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
    @range = (1..7)
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

  def make_rooks
    @black_rook_left = ROOKS.new('black', 'Black Rook', 1, 8)
    @black_rook_right = ROOKS.new('black', 'Black Rook', 8, 8)
    @white_rook_left = ROOKS.new('white', 'White Rook', 8, 6)
    @white_rook_right = ROOKS.new('white', 'White Rook', 8, 5)
    @rooks = @black_rook_left, @black_rook_right, @white_rook_left, @white_rook_right
  end

  def update_transforms(total_board, no_collision = false)
    #rubocop:disable all
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Rook')

      piece.transforms = [
        piece.range.map do |i|
          if  (piece.y_pos + i).between?(1,8) && no_collision == true|| check_for_collision('vertical up', (piece.y_pos + i), piece, find_to_be_moved_spaces('vertical up', (piece.y_pos + i), piece, total_board), total_board, dont_move = true) != false
            [piece.x_pos, piece.y_pos + i, 'vertical up']
          end
        end,
        piece.range.map do |i|
          if (piece.y_pos - i).between?(1,8) && no_collision == true||  check_for_collision('vertical down', (piece.y_pos - i), piece, find_to_be_moved_spaces('vertical down', (piece.y_pos - i), piece, total_board), total_board, dont_move = true) != false
            [piece.x_pos, piece.y_pos - i, 'vertical down']
          end
        end,
        piece.range.map do |i|
          if (piece.x_pos + i).between?(1,8) && no_collision == true||  check_for_collision('horizontal right', (piece.x_pos + i), piece, find_to_be_moved_spaces('horizontal right', (piece.x_pos + i), piece, total_board), total_board, dont_move = true) != false
            [piece.x_pos + i, piece.y_pos, 'horizontal right']
          end
        end,
        piece.range.map do |i|
          if  (piece.x_pos - i).between?(1,8) && no_collision == true||  check_for_collision('horizontal left', (piece.x_pos - i), piece, find_to_be_moved_spaces('horizontal left', (piece.x_pos - i), piece, total_board), total_board, dont_move = true) != false
            [piece.x_pos - i, piece.y_pos, 'horizontal left']
          end
        end
        # piece.range.map { |i| [piece.x_pos, piece.y_pos, 'No move'] } # No move
      ]
    end
  end

  def move_self(selected_position, new_position, total_board, game, dont_move, no_collision = false)
    # @x_pos = selected_position[0]
    # @y_pos = selected_position[1]

    rook_to_move = find_rook(selected_position, total_board)
    # puts "rook_to_move.transforms #{rook_to_move.transforms}"
    rook_to_move.transforms.each do |item|
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
        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, rook_to_move, total_board)
        # puts "moved spaces is #{moved_spaces}"
        if moved_spaces.nil? || check_for_collision(transform_used, new_position, rook_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          return false unless no_collision
          return true
        else

          # puts 'True?'
          # total_board.delete(rook_to_move) unless dont_move
          rook_to_move.current_position = new_position unless dont_move
          rook_to_move.has_moved = true unless dont_move
          rook_to_move.y_pos = new_position[1] unless dont_move
          rook_to_move.x_pos = new_position[0] unless dont_move
          @x_pos = new_position[0] unless dont_move
          @y_pos = new_position[1] unless dont_move
          rook_to_move.current_y = new_position[1] unless dont_move
          rook_to_move.current_x = new_position[0] unless dont_move
          total_board << rook_to_move unless dont_move

          return total_board unless dont_move
          return moved_spaces
        end
      end
    end
    return false
    puts 'REACHED false'
  end

  def get_possible_moves(total_board, game)
    # update_transforms(total_board)
    dont_move = true
    rook_transforms_black = []
    rook_transforms_white = []
    rook_transforms = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Rook')
      piece.update_transforms(total_board, game)
      piece.transforms.each do |transform_pair|
        transform_pair.each do |transform|
          next if transform.nil?

          rook_transforms << [transform[0], transform[1], piece.team,
                              piece.current_position,transform[2]]
          #  puts "transforms #{[transform[0], transform[1]]}"
        end
      end
    end
    # p rook_transforms
    # selected_position = []
    rook_transforms.each do |transform|
      # puts "transform #{transform}"
      # next if selected_position == transform[3]

      selected_position = transform[3]
      new_position = [transform[0], transform[1]] if transform[0].between?(1, 8) && transform [1].between?(1, 8)
      # puts "new position is #{new_position}"
      next unless move_self(selected_position, new_position, total_board, game, dont_move = true) != false

      if transform.include?('white')
        rook_transforms_white << [[transform[0], transform[1]],transform[3],transform[4]]
      elsif transform.include?('black')
        rook_transforms_black << [[transform[0], transform[1]],transform[3],transform[4]]
      end
    end
    [rook_transforms_black.uniq, rook_transforms_white.uniq]
  end
  def get_possible_moves_no_collision(total_board, game)
    # update_transforms(total_board)
    dont_move = true
    rook_transforms_black_no_collision = []
    rook_transforms_white_no_collision = []
    rook_transforms = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Rook')

      piece.transforms.each do |transform_pair|
        transform_pair.each do |transform|
          next if transform.nil?

          rook_transforms << [transform[0], transform[1], piece.team,
                              piece.current_position,transform[2]]
           
        end
      end
    end
    # p rook_transforms
    # selected_position = []
    rook_transforms.each do |transform|
      # puts "transform #{transform}"
      # next if selected_position == transform[3]

      selected_position = transform[3]
      new_position = [transform[0], transform[1]] if transform[0].between?(1, 8) && transform [1].between?(1, 8)
      # puts "new position is #{new_position}"
      next unless move_self(selected_position, new_position, total_board, game, dont_move = true,no_collision = true) != false
# puts "transforms #{[transform[0], transform[1]]}"
      if transform.include?('white')
        rook_transforms_white_no_collision << [[transform[0], transform[1]],transform[3],transform[4]]
      elsif transform.include?('black')
        rook_transforms_black_no_collision << [[transform[0], transform[1]],transform[3],transform[4]]
      end
    end
    [rook_transforms_black_no_collision.uniq, rook_transforms_white_no_collision.uniq]
  end


  def find_rook(selected_position, total_board)
    total_board.flatten.find { |rook| rook.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, rook_to_move, total_board)
    # puts "#{transform_used}transformed used"
    case transform_used
    when 'vertical up' then vertical_up(transform_used, new_position, rook_to_move, total_board)
    when 'vertical down' then vertical_down(transform_used, new_position, rook_to_move, total_board)
    when 'horizontal right' then horizontal_right(transform_used, new_position, rook_to_move, total_board)
    when 'horizontal left' then horizontal_left(transform_used, new_position, rook_to_move, total_board)
    end
  end

  def check_for_collision(transform_used, new_position, rook_to_move, moved_spaces, total_board, dont_move) # \GuardClause
    # p "moved spaces is col UP #{moved_spaces}"
    # @count_rook += 1
    # puts "count is #{@count_rook}"
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
      next if space == rook_to_move.current_position

      total_board.flatten.any? do |piece|
        # puts "piece current pos #{piece.current_position}"
        # puts "space #{space}"
        # puts "piece team #{piece.team}"
        # puts "rook team #{rook_to_move.team}"
        if piece.current_position == space && rook_to_move.team == piece.team

          # puts 'Collision detected did you mean to capture a piece'
          return false
        elsif piece.current_position == space && rook_to_move.team != piece.team && dont_move == false && piece.current_position == new_position
          piece.current_position = [-10, -10]
          # total_board.delete(piece)
          puts 'Capture'
          return true
        elsif piece.current_position == space && rook_to_move.team != piece.team
          return true
        elsif piece.current_position == space && rook_to_move.team != piece.team && piece.current_position != new_position
          return false

        end
      end
    end
  end

  def vertical_up(_transform_used, new_position, rook_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((1)..(y - rook_to_move.current_y))
    transform = range.map { |i| [rook_to_move.current_x, rook_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
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
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def horizontal_left(transform_used, new_position, rook_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((0)..(rook_to_move.current_x - x))
    transform = range.map { |i| [rook_to_move.current_x - i, rook_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def horizontal_right(transform_used, new_position, rook_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((0)..(x - rook_to_move.current_x))
    transform = range.map { |i| [rook_to_move.current_x + i, rook_to_move.current_y] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end
end

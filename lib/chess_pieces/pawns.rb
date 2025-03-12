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
      @range.map { |i| [@x_pos, @y_pos + i, 'vertical up pawn'] unless self.name == 'Black Pawn' },
      @range.map { |i| [@x_pos, @y_pos - i, 'vertical down pawn'] unless self.name == 'White Pawn' },
      (1..1).map { |i| [@x_pos - i, @y_pos + i, 'diagonaol up left'] unless self.name == 'Black Pawn' },
      (1..1).map { |i| [@x_pos + i, @y_pos + i, 'diagonaol up right'] unless self.name == 'Black Pawn' },
      (1..1).map { |i| [@x_pos - i, @y_pos - i, 'diagonaol down left'] unless self.name == 'White Pawn' },
      (1..1).map { |i| [@x_pos + i, @y_pos - i, 'diagonaol down right'] unless self.name == 'White Pawn' }
      # (1..1).map { |i| [@x_pos, @y_pos, 'no move'] }
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

  def update_transforms(total_board, no_collision = false)
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Pawn')

      piece.range = (1..1)
      piece.range = (1..2) unless piece.has_moved == true
      piece.transforms =
        [

          # rubocop:disable all
          piece.range.map do |i|
            [piece.x_pos, piece.y_pos + i, 'vertical up pawn'] unless piece.name == 'Black Pawn' #|| check_for_vertical_piece([piece.x_pos, piece.y_pos + i+1],total_board,piece) == false
          end,
          piece.range.map do |i|
            [piece.x_pos, piece.y_pos - i, 'vertical down pawn'] unless piece.name == 'White Pawn' #|| check_for_vertical_piece([piece.x_pos, piece.y_pos + i+1],total_board,piece) == false
          end,
          (1..1).map do |i|
            if no_collision == true|| check_for_opposing_piece('diagonaol up left', [piece.x_pos - i, piece.y_pos + i], piece, total_board)
              [piece.x_pos - i, piece.y_pos + i,
               'diagonaol up left'] #unless piece.name == 'Black Pawn'
            end
          end,
          (1..1).map do |i|
            if no_collision == true || check_for_opposing_piece('diagonaol up right', [piece.x_pos + i, piece.y_pos + i], piece, total_board) 
              [piece.x_pos + i, piece.y_pos + i,
               'diagonaol up right'] #unless piece.name == 'Black Pawn'
            end
          end,
          (1..1).map do |i|
            if no_collision == true|| check_for_opposing_piece('diagonaol down left', [piece.x_pos - i, piece.y_pos - i], piece, total_board)
              [piece.x_pos - i, piece.y_pos - i,
               'diagonaol down left']  #unless piece.name == 'White Pawn'
            end
          end,
          (1..1).map do |i|
            if  no_collision == true|| check_for_opposing_piece('diagonaol down right', [piece.x_pos + i, piece.y_pos - i], piece, total_board) 
              [piece.x_pos + i, piece.y_pos - i,
               'diagonaol down right'] #unless piece.name == 'White Pawn'
            end
          end
        ]
        # return piece.transforms
    end
      
  end

  def move_self(selected_position, new_position, total_board, game, dont_move,no_collision=false)
    # @x_pos = selected_position[0]
    # @y_pos = selected_position[1]
    piece_to_move = find_piece(selected_position, total_board)
    # puts "pawn to move #{piece_to_move}"
    # puts "pawn to move transforms #{piece_to_move.transforms}"
    piece_to_move.transforms.each do |item|
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
        #  p find_pos
        #  puts "transform_used is #{transform_used}"
        #  puts "new pos is #{new_position}"
        next unless find_pos == new_position
        # puts "FOUND"
        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, piece_to_move, total_board)
        # puts "moved spaces UP #{moved_spaces}"
        if moved_spaces.nil? || check_for_collision(transform_used, new_position, piece_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          # puts 'FALSE'
            return false #unless no_collision == true
          #  return true
        else
          # puts 'NOT FALSE'
          # total_board.delete(piece_to_move) unless dont_move
          piece_to_move.current_position = new_position unless dont_move
          piece_to_move.has_moved = true unless dont_move
          piece_to_move.y_pos = new_position[1] unless dont_move
          piece_to_move.x_pos = new_position[0] unless dont_move
          @x_pos = new_position[0] unless dont_move
          @y_pos = new_position[1] unless dont_move
          piece_to_move.current_y = new_position[1] unless dont_move
          piece_to_move.current_x = new_position[0] unless dont_move
          total_board << piece_to_move unless dont_move
          # puts "new pos after move #{piece_to_move.current_position}"
          return total_board
        end
      end
    end
    # puts 'REACHED FALSE'
    false
  end

  def get_possible_moves(total_board, game)
    # update_transforms(total_board)
    dont_move = true
    pawn_transforms_black = []
    pawn_transforms_white = []
    pawn_transforms = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Pawn')

      piece.transforms.each do |transform_pair|
        transform_pair.each do |transform|
          next if transform.nil?

          pawn_transforms << [transform[0], transform[1], piece.team,
                              piece.current_position,transform[2]]
          #  puts "transforms #{transform}"
        end
      end
    end
    # p pawn_transforms
    # selected_position = []
    pawn_transforms.each do |transform|
      # puts "transform #{transform}"
      # next if selected_position == transform[3]

      selected_position = transform[3]
      new_position = [transform[0], transform[1]] if transform[0].between?(1, 8) && transform [1].between?(1, 8)
      # puts "new position is #{new_position}"
      next unless move_self(selected_position, new_position, total_board, game, dont_move = true) != false

      if transform.include?('white')
        pawn_transforms_white << [[transform[0], transform[1]],transform[3],transform[4]]
      elsif transform.include?('black')
        pawn_transforms_black << [[transform[0], transform[1]],transform[3],transform[4]]
      end
    end
    # puts "pawn_transforms_black POS#{pawn_transforms_black}"
    # puts "pawn_transforms_white POS #{pawn_transforms_white}"
    [pawn_transforms_black.uniq, pawn_transforms_white.uniq]
  end
  def get_possible_moves_no_collision(total_board, game)
    # update_transforms(total_board)
    dont_move = true
    pawn_transforms_black_no_collision = []
    pawn_transforms_white_no_collision = []
    pawn_transforms = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Pawn')

      piece.transforms.each do |transform_pair|
        transform_pair.each do |transform|
          next if transform.nil? 
          if transform.include?('vertical up pawn') || transform.include?('vertical down pawn')
            # puts "NEXT"
            next
          end

          pawn_transforms << [transform[0], transform[1], piece.team,
                              piece.current_position,transform[2]]
          #  puts "transforms #{transform}"
        end
      end
    end
    # p pawn_transforms
    # selected_position = []
    pawn_transforms.each do |transform|
      # puts "transform #{transform}"
      # next if selected_position == transform[3]

      selected_position = transform[3]
      new_position = [transform[0], transform[1]] if transform[0].between?(1, 8) && transform [1].between?(1, 8)
      # puts "new position is #{new_position}"
      next unless move_self(selected_position, new_position, total_board, game, dont_move = true,no_collision = true) != false

      if transform.include?('white')
        pawn_transforms_white_no_collision << [[transform[0], transform[1]],transform[3],transform[4]]
      elsif transform.include?('black')
        pawn_transforms_black_no_collision << [[transform[0], transform[1]],transform[3],transform[4]]
      end
    end
    # puts "pawn_transforms_black POS#{pawn_transforms_black}"
    # puts "pawn_transforms_white POS #{pawn_transforms_white}"
    [pawn_transforms_black_no_collision.uniq, pawn_transforms_white_no_collision.uniq]
  end

  def find_piece(selected_position, total_board)
    total_board.flatten.find { |pawn| pawn.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, piece_to_move, total_board)
    case transform_used
    when 'vertical up pawn' then vertical_up(transform_used, new_position, piece_to_move, total_board)
    when 'vertical down pawn' then vertical_down(transform_used, new_position, piece_to_move, total_board)
    when 'diagonaol up left' then diagonaol_up_left(transform_used, new_position, piece_to_move, total_board)
    when 'diagonaol up right' then diagonaol_up_right(transform_used, new_position, piece_to_move, total_board)
    when 'diagonaol down right' then diagonaol_down_right(transform_used, new_position, piece_to_move, total_board)
    when 'diagonaol down left' then diagonaol_down_left(transform_used, new_position, piece_to_move, total_board)
    end
  end

  def check_for_collision(transform_used, new_position, pawn_to_move, moved_spaces, total_board, dont_move) # \GuardClause
    # p "moved spaces is col UP #{moved_spaces}"
    # @count_pawn += 1
    # puts "count is #{@count_pawn}"
    # IF there exists piece(s) in the moved spaces path and its not the last one(new position)
    # We know we are either capturing or colliding with own piece
    # [4,1]
    # [5,2]
    # [6,3]
    # [7,4]
    # [8,5]
    #
    return false if moved_spaces.nil? || moved_spaces == false
  
    # puts "transform used #{transform_used}"
    # moved_spaces.shift if moved_spaces.length > 1
    moved_spaces.each do |space|
      next if space == pawn_to_move.current_position
  
      total_board.flatten.any? do |piece|
          # puts "piece current pos #{piece.current_position}"
        # puts "space #{space}"
        # puts "piece team #{piece.team}"
        # puts "pawn team #{pawn_to_move.team}"
        if piece.current_position == space && pawn_to_move.team == piece.team
  
          # puts 'Collision detected did you mean to capture a piece'
          return false
        elsif piece.current_position == space && pawn_to_move.team != piece.team && dont_move == false && transform_used.include?('diagonaol')
          piece.current_position = [-10, -10]
          puts 'Capture'
          return true
        elsif piece.current_position == space && transform_used.include?('diagonaol')
          # puts "piece team #{piece.team}"
          # puts "pawn_to_move.team #{pawn_to_move.team}"
          return false unless pawn_to_move.team != piece.team
  
          return true
        elsif piece.current_position == space && pawn_to_move.team != piece.team && !transform_used.include?('diagonaol')
          # puts "EARLY"
          return false
        
        end
      end
    end
  end
  def check_for_vertical_piece(transform,total_board,pawn)
    total_board.flatten.each do |piece|
      # puts "transform #{transform}"
      # puts "piece.currentpos #{piece.current_position}"
      if transform == piece.current_position
        return false
      end
    end
  end

  def check_for_opposing_piece(transform_used, new_position, piece_to_move, total_board)
    total_board.flatten.each do |to_be_captured_piece|
      # puts "transform #{transform_used}"
      # puts "to be cap pos #{to_be_captured_piece.current_position}"
      # puts "new pos #{new_position}"
      next unless to_be_captured_piece.current_position == new_position

      #  puts "to_be_captured_piece current_position #{to_be_captured_piece.current_position}"
      #  puts "new position #{new_position}"

      if piece_to_move.team != (to_be_captured_piece.team) && transform_used.include?('diagonaol')
        #  puts 'true'
        return true
      else
        #  puts 'false'
        return false
      end
    end
  end

  def vertical_up(_transform_used, new_position, piece_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((1)..(y - piece_to_move.current_y))
    transform = range.map { |i| [piece_to_move.current_x, piece_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # puts "fixed moved spaces #{fixed_moved_spaces}"
    fixed_moved_spaces
  end

  def vertical_down(_transform_used, new_position, piece_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((1)..(piece_to_move.current_y - y))
    transform = range.map { |i| [piece_to_move.current_x, piece_to_move.current_y - i] }

    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    fixed_moved_spaces
  end

  def diagonaol_up_left(transform_used, new_position, piece_to_move, total_board)
    moved_spaces = []
    x = new_position[0]
    y = new_position[1]
    range = ((0)..(y - piece_to_move.current_y))
    transform = range.map { |i| [piece_to_move.current_x - i, piece_to_move.current_y + i] }
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # return false if check_for_opposing_piece(transform_used, new_position, piece_to_move, total_board) == false

    fixed_moved_spaces
  end

  def diagonaol_up_right(transform_used, new_position, piece_to_move, total_board)
    moved_spaces = []
    range = (1..1)
    transform = range.map { |i| [piece_to_move.current_x + i, piece_to_move.current_y + i] }

    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # return false if check_for_opposing_piece(transform_used, new_position, piece_to_move, total_board) == false

    fixed_moved_spaces
  end

  def diagonaol_down_left(transform_used, new_position, piece_to_move, total_board)
    moved_spaces = []
    transform = piece_to_move.current_x - 1, piece_to_move.current_y - 1
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # return false if check_for_opposing_piece(transform_used, new_position, piece_to_move, total_board) == false

    fixed_moved_spaces
  end

  def diagonaol_down_right(transform_used, new_position, piece_to_move, total_board)
    moved_spaces = []
    transform = piece_to_move.current_x + 1, piece_to_move.current_y - 1
    moved_spaces << transform
    fixed_moved_spaces = moved_spaces.join('').each_char.each_slice(2).to_a
    fixed_moved_spaces.map! do |piece|
      piece.map(&:to_i)
    end
    # return false if check_for_opposing_piece(transform_used, new_position, piece_to_move, total_board) == false

    fixed_moved_spaces
  end
end

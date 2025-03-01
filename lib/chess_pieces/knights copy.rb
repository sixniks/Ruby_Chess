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
    @transforms = [
      [@x_pos - 1, @y_pos + 2, 'Up Left L'], # Up-Left L
      [@x_pos + 1, @y_pos + 2, 'Up Right L'], # Up-Right L
      [@x_pos - 1, @y_pos - 2, 'Down Left L'], # Down-Left L
      [@x_pos + 1, @y_pos - 2, 'Down Right L'], # Down-Right L
      [@x_pos, @y_pos]
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
    @x_pos = selected_position[0]
    @y_pos = selected_position[1]

    knight_to_move = find_knight(selected_position, total_board)

    knight_to_move.range = (1..1)

    knight_to_move.transforms = [
      knight_to_move.range.map { [knight_to_move.x_pos - 1, knight_to_move.y_pos + 2, 'Up Left L'] }, # Up-Left L
      knight_to_move.range.map { [knight_to_move.x_pos + 1, knight_to_move.y_pos + 2, 'Up Right L'] }, # Up-Right L
      knight_to_move.range.map { [knight_to_move.x_pos - 1, knight_to_move.y_pos - 2, 'Down Left L'] }, # Down-Left L
      knight_to_move.range.map { [knight_to_move.x_pos + 1, knight_to_move.y_pos - 2, 'Down Right L'] } # Down-Right L
    ]
    knight_to_move.transforms.each do |item|
      item.each do |item2|
        transform_used = item2.pop unless item2.nil?
        next unless item2 == new_position

        # p transform_used
        moved_spaces = find_to_be_moved_spaces(transform_used, new_position, knight_to_move, total_board)
        # p moved_spaces

        if moved_spaces.nil? || check_for_collision(transform_used, new_position, knight_to_move, moved_spaces,
                                                    total_board, dont_move) == (false)
          return false
        else

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
    false
  end

  def get_possible_moves(total_board, game)
    dont_move = true
    knight_transforms_black = []
    knight_transforms_white = []
    total_board.flatten.each do |piece|
      next unless piece.name.include?('Knight')

      selected_position = piece.current_position
      new_position = piece.transforms.each
      new_position.each do |pos|
        pos.map do |pos2|
          next unless move_knight(selected_position, pos2, total_board, game, dont_move) != false

          piece.transforms.clear

          if piece.team == 'white'
            if !pos2.nil? && !(pos2[0] > 8 || pos2[0] < 1 || pos2[1] > 8 || pos2[1] < 1)
              knight_transforms_white << pos2
              piece.transforms << pos2
            end
          elsif piece.team == 'black'
            if !pos2.nil? && !(pos2[0] > 8 || pos2[0] < 1 || pos2[1] > 8 || pos2[1] < 1)
              knight_transforms_black << pos2
              piece.transforms << pos2
            end
          end
        end
      end
    end
    [knight_transforms_black, knight_transforms_white]
  end

  def find_knight(selected_position, total_board)
    total_board.flatten.find { |knight| knight.instance_variable_get(:@current_position) == selected_position }
  end

  def find_to_be_moved_spaces(transform_used, new_position, knight_to_move, total_board)
    case transform_used
    when 'Up Left L' then up_left_l(transform_used, new_position, knight_to_move, total_board)
    when 'Up Right L' then up_right_l(transform_used, new_position, knight_to_move, total_board)
    when 'Down Left L' then down_left_l(transform_used, new_position, knight_to_move, total_board)
    when 'Down Right L' then down_right_l(transform_used, new_position, knight_to_move, total_board)
    end
  end

  def check_for_collision(transform_used, new_position, knight_to_move, moved_spaces, total_board, dont_move)
    # rubocop:disable Style\GuardClause
    # moved_spaces.each do |space|
    #   next unless total_board.flatten.any? { |item| item.current_position == space }

    to_be_captured_piece = check_for_opposing_piece(transform_used, new_position, knight_to_move,
                                                    total_board, dont_move)
    if to_be_captured_piece == false || dont_move == true
      return true
    else
      to_be_captured_piece.current_position = [-10, -10]
      to_be_captured_piece.captured = true
      return true

    end
  end

  def check_for_opposing_piece(transform_used, new_position, knight_to_move, total_board, dont_move)
    total_board.flatten.any? do |to_be_captured_piece|
      if to_be_captured_piece.current_position == new_position && !dont_move # && knight_to_move.team != (to_be_captured_piece.team)
        to_be_captured_piece.captured = true
        return to_be_captured_piece
      end
    end
    false
  end

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

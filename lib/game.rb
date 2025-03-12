require_relative 'board'
# BUGS:

# Softlock if you select a piece that cannot move
#   Gets stuck on select a new position if you input  out of bounds

# TO DO:
# Pawn into Queen
# Castling
# Clean up
# Can not move yourself into check... Done?
require 'yaml'
class Game < Board
  attr_accessor :board, :white_turn, :black_mate, :white_mate, :transforms_black, :transforms_white, :black_check,
                :white_check, :transforms_black_no_collison, :transforms_white_no_collison, :user_team_black

  def initialize
    super
    @white_check = false
    @black_check = false
    @board = Board.new
    @white_turn = true
    @black_mate = false
    @white_mate = false
    @transforms_black = []
    @transforms_white = []
    @transforms_black_no_collison = []
    @transforms_white_no_collison = []
    @user_team_black = false
  end

  def startup_message(game)
    puts 'Please choose your color, Black or White'
    puts "\nOr type l to load the last save game, or u for the last auto-save"
    input = gets.chomp

    if %w[Black black blk blck].include?(input)
      @user_team_black = true
    elsif input == 'u'
      game.load_game_undo(game)
    elsif input == 'l'
      game.load_game(game)
    end
  end

  def game_loop(game)
    startup_message(game)
    until @black_mate || @white_mate == true
      # puts 'TOP'

      # puts "\e[H\e[2J"
      total_board.flatten.each do |piece|
        piece.update_transforms(@total_board)
      end

      puts "White Turn \n" if @white_turn
      puts 'Black Turn' unless @white_turn
      @black_check = false
      @white_check = false
      checkmate?(game)
      puts 'Black is in check' if @black_check
      puts 'White is in check' if @white_check
      game.render

      # possible_moves(game)

      # puts "piece to move transforms #{piece_to_move.transforms}"
      # Human Move
      # make_cpu_move(game) if @user_team_black == true
      # puts 'MID'
      @white_turn = !@white_turn if @user_team_black == true
      game.render if @user_team_black == true
      puts "White Turn \n" if @white_turn
      puts 'Black Turn' unless @white_turn
      piece_to_move = valid_input_select?(game)
      game.undo_move_save
      piece_to_move.update_transforms(@total_board)
      selected_position = piece_to_move.current_position
      move_piece(piece_to_move, selected_position, game)

      @white_turn = !@white_turn
      game.render
      # CPU MOVE
      puts "White Turn \n" if @white_turn
      puts 'Black Turn' unless @white_turn
      # @black_check = false
      # @white_check = false
      total_board.flatten.each do |piece|
        piece.update_transforms(@total_board)
      end
      checkmate?(game)
      # make_cpu_move(game) unless @user_team_black
      game.render
      puts "White Turn \n" if @white_turn
      puts 'Black Turn' unless @white_turn
      @white_turn = !@white_turn unless @user_team_black == true
      # puts 'sadsa'

      # possible_moves(game)

      # game.render

      # checkmate?(game)
      # puts 'Black is in check' if @black_check
      # puts 'White is in check' if @white_check
      # puts "\e[H\e[2J"

    end
  end

  # A player can get out of check by:

  # Moving a piece in front of the path of check
  #   Can get to be moved spaces from piece.find_to_be_moved_spaces
  # That is the path to the king
  #

  # Capturing the piece that is checking
  #   Check total transforms against piece(s) current pos

  # Or moving the king to a spot not convered by transforms
  #   Check king transforms against total transforms

  # IF the player can do one of these things they must do so
  def move_out_of_check?(piece_for_check_pos, transform_used, king_pos, king_transforms, game)
    # puts "piece_for_check_pos 0 #{piece_for_check_pos}"
    # puts 'move_out_of_check?'
    # [0][0][0..1]

    fixed_king_transform = []
    fixed_white_transforms = []
    fixed_black_transforms = []
    fixed_white_transforms_no_collision = []
    actually_fixed_king_black_transforms = []
    # puts "transforms white #{@transforms_white[0]}"

    king_transforms.map do |transform_w_string|
      transform_w_string.each do |transform|
        fixed_king_transform << [transform[0], transform[1]] unless transform.nil?
      end
    end
    @king_transforms_black.map do |transform|
      # puts "transform #{transform[0]}"
      actually_fixed_king_black_transforms << transform[0]
    end
    # puts "king transforms #{fixed_king_transform[0...]}"
    @transforms_white.map do |transforms|
      transforms.each do |transform_pair|
        if ['vertical up pawn', 'vertical down pawn'].include?(transform_pair[2])
          # puts 'PAWN NEXT IF '
          next
        end

        # puts "transform #{transform_pair[0]}"
        # puts "transform #{transform_pair[1]}"
        fixed_white_transforms << transform_pair[0]
        fixed_white_transforms << transform_pair[1]
        # fixed_white_transforms << transform_pair
      end
    end
    # arr = []
    # @total_board.flatten.each do |piece|
    #   if piece.name == 'White Pawn'
    #     piece.update_transforms(@total_board, no_collision = true)
    #     arr << piece.transforms
    #   end
    # end
    # arr.each do |transform_w_string|
    #   transform_w_string.each do |transform1|
    #     transform1.each do |transform|
    #       next if transform.nil?

    #       puts "#{transform[0..1]} transfor m"
    #       fixed_white_transforms_no_collision << transform[0..1]
    #     end
    #   end
    # end
    @transforms_white_no_collison.map do |transforms|
      # puts "transform #{transforms}"
      transforms.each do |transform_pair|
        fixed_white_transforms_no_collision << transform_pair[0]
        fixed_white_transforms_no_collision << transform_pair[1]
        fixed_white_transforms_no_collision << transform_pair[2]
      end
    end
    # puts "fixed_white_transforms_no_collision #{fixed_white_transforms_no_collision}"
    @transforms_black.map do |transforms|
      # puts "transform #{transforms}"
      transforms.each do |transform_pair|
        # puts "king pos #{king_pos}"
        next unless transform_pair[0] || transform_pair[1] != king_pos

        fixed_black_transforms << transform_pair[0]
        fixed_black_transforms << transform_pair[1]
      end
    end
    # puts "fixed king #{fixed_king_transform}"
    # puts "fixed_white_transforms #{fixed_white_transforms.uniq}"
    # puts "fixed_black_transforms #{fixed_white_transforms.uniq}"
    total_board.flatten.each do |piece|
      next unless piece.current_position == piece_for_check_pos # find the piece causing check

      piece.update_transforms(@total_board)
      moved_spaces = piece.find_to_be_moved_spaces(transform_used, king_pos, piece, @total_board)

      # fixed_moved_spaces = []
      unless moved_spaces.nil?
        moved_spaces.each do |space|
          moved_spaces.delete(space) if space == king_pos
        end
      end
      # puts "moved spaces #{moved_spaces}"
      if @white_check == true
        fixed_white_transforms -= fixed_king_transform
        fixed_black_transforms_no_collision -= piece.current_position
        fixed_black_transforms_no_collision -= king_pos
        fixed_white_transforms.each do |transform|
          # puts "transform #{transform}"
          if !moved_spaces.nil? && moved_spaces.include?(transform) # Check if black can move in the path to stop check
            puts 'moved spaces true'
            return transform # Send transform off, get piece with that transform, and move it to the transform
          elsif fixed_white_transforms.include?(piece_for_check_pos) # We can capture the piece in check
            puts 'capture true'
            return piece.current_position # Send piece_to_cap position, find the piece with the transform that can move there and move it
          elsif fixed_king_transform - fixed_black_transforms_no_collision != []
            puts "#{fixed_king_transform - fixed_black_transforms_no_collision}"
            puts 'can move to safe spot true'

            return [fixed_king_transform - fixed_black_transforms_no_collision, 'true'] # Send available moves off and move to one of them as the king
          end
        end
        # puts 'Black mate'
        # @black_mate = true
      end
      # rubocop: disable Style\Next
      if @black_check == true
        fixed_black_transforms -= @king_transforms_black
        fixed_black_transforms -= piece.current_position
        @king_transforms_black.delete(king_pos)
        # puts "fixed_king_transform #{fixed_king_transform}"
        # puts "@king_transforms_black #{@king_transforms_black}"
        fixed_white_transforms_no_collision -= piece.current_position
        fixed_white_transforms_no_collision.delete(king_pos)
        # piece.update_transforms(game, no_collision = true)

        # puts "fixed_white_transforms_no_collision#{fixed_white_transforms_no_collision}"
        # puts "king pos #{king_pos}"
        # puts "fixed_black_transforms #{fixed_black_transforms}"
        @can_move_out_of_check = false
        result_arr = []
        if !moved_spaces.nil?
          old_length = moved_spaces.length
          moved_spaces_result = moved_spaces.intersection(fixed_black_transforms)
          # puts "#{moved_spaces_result} moved_spaces_result"
        end
        # moved_spaces_result = []
        # moved_spaces_result << moved_spaces + fixed_black_transforms
        # puts "fixed_black_transforms #{fixed_black_transforms}"

        if !moved_spaces.nil? && old_length >= moved_spaces_result.length && moved_spaces_result.length != 0 # && !fixed_white_transforms_no_collision.include?(piece.current_position) # Check if black can move in the path to stop check
          # puts "HITTT"
          # puts 'moved spaces true'
          @black_check = true
          @can_move_out_of_check = true
          result_arr << [moved_spaces_result, 'king_no_move'] # Send transform off, get piece with that transform, and move it to the transform
        end
        if fixed_black_transforms.include?(piece_for_check_pos) && !fixed_white_transforms_no_collision.include?(piece.current_position) # We can capture the piece in check
          # puts 'capture true'
          @black_check = true
          @can_move_out_of_check = true
          result_arr << [[piece.current_position], ['capture']] # Send piece_to_cap position, find the piece with the transform that can move there and move it
        end
        if actually_fixed_king_black_transforms - fixed_white_transforms != []
          # puts "#{actually_fixed_king_black_transforms - fixed_white_transforms}"
          # puts 'can move to safe spot true'
          @black_check = true
          @can_move_out_of_check = true
          result_arr << [actually_fixed_king_black_transforms - fixed_white_transforms, 'true'] # Send available moves off and move to one of them as the king
          # Look at king transforms
          # Compare to transforms that can move to king transforms
          # IF the piece is a pawn and it has the same y pos as king
          # Ignore it

        end
        if @can_move_out_of_check == true
          return result_arr
        else
          puts 'Black mate'
          @black_mate = true
          exit 1
        end
      end
    end
    puts "reached false"
    false
  end

  def valid_input_select?(game)
    puts "\nPlease select your piece using the x and y cordinates. Example: 1,1 Or type s to save, l to load or u to go back a turn"
    input = gets.chomp
    game.save_game(@white_turn, @user_team_black) if input == 's'

    if input == 'l'
      turn_tuple = game.load_game(game)
      @white_turn = turn_tuple[0]
      @user_team_black = turn_tuple[1]
    end

    game.load_game_undo(game) if input == 'u'
    # game.render
    selected_position = input.split(',').map(&:to_i)
    @total_board.flatten.each do |piece|
      next unless piece.current_position == selected_position

      puts "You selected #{piece.name}"
      if piece.team.include?('white') && @white_turn
        return piece

      elsif piece.team.include?('black') && !@white_turn
        return piece

      elsif piece.team.include?('white') && !@white_turn
        puts ' Black cannot move White pieces'

      elsif piece.team.include?('black') && @white_turn
        puts 'White cannot move Black pieces'

      elsif selected_position[0] != (1..8) || selected_position[1] != (1..8)
        puts 'Invalid input! Please input 2 numbers seperated by comma 1-8. e.g: 1,1'

      end
    end
    # puts 'Please select a valid space'
    valid_input_select?(game)
  end

  def move_piece(piece_to_move, selected_position, game, new_position = get_new_position(piece_to_move, game),
                 to_redo = true)
    dont_move = false
    puts 'Please select where you want the piece to move'

    # new_position = get_new_position(piece_to_move, game)
    # rubocop:disable Style\GuardClause
    string = "That piece can not move that way please try again"
    if checkmate?(game) != true
      result = checkmate?(game) unless result == false
      result = result.sample if result != false && result.length > 2
    end
    if (@white_turn && @white_check) || (!@white_turn && @black_check && @user_team_black == true) && result != false
      total_board.flatten.shuffle.each do |piece|
        # puts "piece transforms #{piece.transforms}"
        piece.transforms.each do |all_transform|
          all_transform.each do |transform|
            next if transform.nil?

            # puts "transform #{transform[0..1]}"
            # puts "result #{result[0]}"
            if transform[0..1] == (result[0])
              # puts "you must move the #{piece.name} at #{piece.current_position} to #{result[0]} to get out of check"
              if new_position != result[0]
                string = "You must move to #{result[0]} to get out of check"
                redo_move(game, string)
              end
              # move_piece(piece_to_move, piece_to_move.current_position, game, result, to_redo = false)
              break
            end
          end
        end
      end
    end
    if piece_to_move.name.include?('Pawn')
      if pawns.move_self(selected_position, new_position, @total_board, game, dont_move = false) == false
        redo_move(game, string) unless to_redo == false

        return false

      end
    end
    if piece_to_move.name.include?('Queen')
      if queens.move_self(selected_position, new_position, @total_board, game, dont_move = false) == false

        redo_move(game, string) unless to_redo == false
        return false
      end

    end
    if piece_to_move.name.include?('King')
      old_pos = piece_to_move.current_position
      if kings.move_self(selected_position, new_position, @total_board, game, dont_move) == false

        redo_move(game, string) unless to_redo == false
        return false

      elsif  @user_team_black == true
        checkmate?(game)
        puts "asDFSADFDSFDSSDFSDFSFD"
        if @black_check == true
          string = 'You can not move yourself into check'
          puts ">>>>>>"
          piece_to_move.current_position = old_pos
          redo_move(game, string)
          return false
        end
      elsif  @user_team_black != true
        string = 'You can not move yourself into check'
        puts ">>>>>>"
        piece_to_move.current_position = old_pos
        redo_move(game, string)
        return false
      end
      puts "black check #{@black_check}"
      puts "user team black #{@user_team_black}"
    end
    if piece_to_move.name.include?('Bishop')
      if bishops.move_self(selected_position, new_position, @total_board, game, dont_move) == false

        redo_move(game, string) unless to_redo == false
        return false
      end

    end
    if piece_to_move.name.include?('Rook')
      if rooks.move_self(selected_position, new_position, @total_board, game, dont_move) == false

        redo_move(game, string) unless to_redo == false
        return false
      end

    end
    if piece_to_move.name.include?('Knight')
      if knights.move_self(selected_position, new_position, @total_board, game, dont_move) == false

        redo_move(game, string) unless to_redo == false
        return false
      end

    end
  end

  def get_new_position(piece_to_move, game)
    new_position = gets.chomp.split(',').map(&:to_i)
    loop do
      if new_position[0].between?(1, 8) == false || new_position[1].between?(1, 8) == false

        puts "Please enter a valid new position for #{piece_to_move.name} at #{piece_to_move.current_position}."
        game.render
        new_position = gets.chomp.split(',').map(&:to_i)
      else
        break
      end
    end
    return new_position
  end

  def redo_move(game, string)
    # puts "\e[H\e[2J"

    puts 'White turn' if @white_turn
    puts 'Black turn' if !@white_turn
    puts "\n#{string}\n"
    game.render
    piece_to_move = valid_input_select?(game)
    selected_position = piece_to_move.current_position
    move_piece(piece_to_move, selected_position, game,)
    @total_board
  end

  # If black transforms can move to white king current pos
  # Then white is in check
  # If white king's transforms are covered by black transforms
  # Then checkmate
  def checkmate?(game)
    # puts "Checkmate call"
    possible_moves(game)
    # puts "white transforms are #{@transforms_white.uniq}"
    # puts "black transforms are #{@transforms_black.uniq}"
    @total_board.flatten.each do |piece|
      next unless piece.name == 'White King' || piece.name == 'Black King'

      if piece.name == 'White King'
        # piece.update_transforms(@total_board)
        # puts "black king transforms are #{piece.transforms}"
        @transforms_white.each do |transform_arr|
          # puts "transform_arr #{transform_arr}"
          # puts "piece current position #{piece.current_position}"
          transform_arr.each do |transform|
            # puts "transform #{transform[0]}"
            # puts "transform 1 #{transform[1]}"
            # puts "transform 2 #{transform[2]}"
            if transform[0] == piece.current_position
              puts "White in Check"
              @white_check = true
              piece.update_transforms(@total_board)
              # puts "piece transforms checkmate #{piece.transforms}"
              result = move_out_of_check?(transform[1], transform[2], piece.current_position, piece.transforms, game)
              return result
            else
              @white_check = false
            end
          end
        end
      elsif piece.name == 'Black King'
        # piece.update_transforms(@total_board)
        # puts "black king transforms are #{piece.transforms}"
        # puts "@transforms_white #{@transforms_white}"
        total_board.flatten.each do |piece|
          piece.update_transforms(@total_board)
        end
        @transforms_white.each do |transform_arr|
          # puts "transform_arr #{transform_arr}"
          # puts "piece current position #{piece.current_position}"
          transform_arr.each do |transform|
            next if transform[2] == "vertical up pawn" || transform[2] == "vertical down pawn"

            # puts "HERE"
            # puts "transform #{transform[0]}"
            # puts "piece.current_position #{piece.current_position}"
            # puts "transform 1 #{transform[1]}"
            # puts "transform 2 #{transform[2]}"
            if transform[0] == piece.current_position
              # puts "Black in Check HERE "
              @black_check = true
              piece.update_transforms(@total_board)
              # puts "piece transforms checkmate #{piece.transforms}"
              result = move_out_of_check?(transform[1], transform[2], piece.current_position, piece.transforms, game)
              # p "RESULT UP #{result[-1][-1]}"

              if result[-1][-1].include?("true")
                # puts "RESULT TRUE"
              end
              return result
            end
          end
        end
      end
    end
  end

  def possible_moves(game)
    all_transforms = []
    pawn_transforms = pawns.get_possible_moves(@total_board, game)

    pawn_transforms_black = pawn_transforms[0]
    pawn_transforms_white = pawn_transforms[1]
    @transforms_black << pawn_transforms_black
    @transforms_white << pawn_transforms_white
    pawn_transforms_no_collison = pawns.get_possible_moves_no_collision(@total_board, game)
    @transforms_black_no_collison << pawn_transforms_no_collison[0]
    @transforms_white_no_collison << pawn_transforms_no_collison[1]

    king_transforms = kings.get_possible_moves(@total_board, game)
    @king_transforms_white = king_transforms[1]

    @king_transforms_black = king_transforms[0]
    # puts "king_transforms_black#{@king_transforms_black}"
    @transforms_black << @king_transforms_black
    @transforms_white << @king_transforms_white
    king_transforms_no_collison = kings.get_possible_moves_no_collision(@total_board, game)
    @transforms_black_no_collison << king_transforms_no_collison[0]
    @transforms_white_no_collison << king_transforms_no_collison[1]

    queen_transforms = queens.get_possible_moves(@total_board, game)
    queen_transforms_white = queen_transforms[1]
    # puts "queen_transforms_white#{queen_transforms_white}"
    queen_transforms_black = queen_transforms[0]
    @transforms_black << queen_transforms_black
    @transforms_white << queen_transforms_white
    queen_transforms_no_collison = queens.get_possible_moves_no_collision(@total_board, game)
    @transforms_black_no_collison << queen_transforms_no_collison[0]
    @transforms_white_no_collison << queen_transforms_no_collison[1]

    # return all_transforms
    bishops_transforms = bishops.get_possible_moves(@total_board, game)
    bishops_transforms_white = bishops_transforms[1]
    # puts "bishop_transforms_white#{bishops_transforms_white}"
    bishops_transforms_black = bishops_transforms[0]
    @transforms_black << bishops_transforms_black
    @transforms_white << bishops_transforms_white
    bishop_transforms_no_collison = bishops.get_possible_moves_no_collision(@total_board, game)
    @transforms_black_no_collison << bishop_transforms_no_collison[0]
    @transforms_white_no_collison << bishop_transforms_no_collison[1]

    knights_transforms = knights.get_possible_moves(@total_board, game)
    knight_transforms_white = knights_transforms[1]
    # puts "knight_transforms_white#{knight_transforms_white}"
    # puts "knight_transforms_white#{knight_transforms_white}"
    knight_transforms_black = knights_transforms[0]
    @transforms_black << knight_transforms_black
    @transforms_white << knight_transforms_white
    knight_transforms_no_collison = knights.get_possible_moves_no_collision(@total_board, game)
    @transforms_black_no_collison << knight_transforms_no_collison[0]
    @transforms_white_no_collison << knight_transforms_no_collison[1]

    rooks_transforms = rooks.get_possible_moves(@total_board, game)
    rook_transforms_white = rooks_transforms[1]

    rook_transforms_black = rooks_transforms[0]
    @transforms_black << rook_transforms_black
    @transforms_white << rook_transforms_white
    rook_transforms_no_collison = rooks.get_possible_moves_no_collision(@total_board, game)
    @transforms_black_no_collison << rook_transforms_no_collison[0]
    # puts "rook_transforms_white#{rook_transforms_white}"
    @transforms_white_no_collison << rook_transforms_no_collison[1]
  end

  # Select piece until piece.transforms is not empty
  # Select piece based on team and turn
  def make_cpu_move(game)
    checkmate?(game)
    cpu_move_made = false
    if @white_turn
      if @white_check == true
        result = checkmate?(game)

        result = result[0..1].sample if result.length > 2
        # puts "result#{result}"
        until @white_check == false do
          piece_to_move = total_board.flatten.shuffle.each do |piece|
            if result.include?(['true'])
              next unless piece.name == 'White King'

              puts "piece #{piece}"
              puts "piece #{piece.current_position}"

              piece.transforms.each do |transform_w_string|
                # puts "piece transforms #{transform_w_string}"
                transform_w_string.each do |transform|
                  puts "piece transforms #{transform[0..1]}"
                  if transform[0..1] == (result[0][0])
                    puts 'found'
                    piece_to_move = piece
                    puts "piece #{piece_to_move.current_position}"
                    puts "piece #{piece_to_move}"
                    puts "result #{result}"
                    # game.undo_move_save
                    if piece.move_self(piece_to_move.current_position, result[0][0], @total_board, game,
                                       dont_move = false) != false
                      game.render
                      checkmate?(game)
                      puts "CAN MOVE"
                    end
                  end
                end
              end
            end
            # puts "piece transforms #{piece.transforms}"
            piece.transforms.each do |all_transform|
              # puts "piece  all transform #{all_transform}"
              # puts "here 3"
              all_transform.each do |transform|
                # puts "here 4"

                next if transform.nil? || piece.current_position == result[0]

                # puts "piece transform #{transform[0..1]}"
                # puts "result #{result[0][0]}"
                # puts "transform #{transform[0..1]}"
                if transform[0..1] == (result[0][0])
                  puts 'found'
                  piece_to_move = piece
                  puts "piece #{piece_to_move.current_position}"
                  puts "piece #{piece_to_move}"
                  puts "result #{result[0][0]}"
                  # game.undo_move_save
                  if piece.move_self(piece_to_move.current_position, result[0][0], @total_board, game,
                                     dont_move = false) != false
                    game.render
                    checkmate?(game)
                    puts "CAN MOVE"
                  end
                end
              end
            end
          end
        end
      end
      loop do
        piece_to_move = total_board.flatten.sample
        next if piece_to_move.current_position == [-10, -10]

        if piece_to_move.team == 'white' && piece_to_move.transforms.any? { |transform| transform != nil }
          piece_to_move.update_transforms(@total_board)
          puts "piece to move transforms #{piece_to_move.transforms}"
          while true

            new_position = piece_to_move.transforms.sample
            puts "new pos is #{new_position}"
            break if new_position.find { |transform| transform != nil }
          end
          # new_position - new_position[2]
          new_position.map do |transform|
            if transform == nil
              new_position.delete(transform)
            end
          end

          new_position = new_position.sample
          new_position = [new_position[0], new_position[1]]
          puts "new pos is #{[new_position[0], new_position[1]]}"
          puts "piece to move is #{piece_to_move}#{piece_to_move.current_position}"
          selected_position = piece_to_move.current_position
          # possible_moves(game)
          if move_piece(piece_to_move, selected_position, game, new_position, to_redo = false) != false
            cpu_move_made = true
            break
          end
        end
      end
    else

      if @black_check == true
        array_index = 0
        until @black_check == false do
          array_index += 1
          result = checkmate?(game)
          puts "BLACK CHECK TRUE"
          # result = result[0..1].sample if result != true && result != false && result.length > 2

          # puts "result#{result[array_index]}"
          piece_to_move = total_board.flatten.shuffle.each do |piece|
            next if piece.team != "black"

            if result.include?([piece.current_position])
              puts "DELETE"
              result.delete(piece.current_position)
            end
            puts "result before if #{result[-1][-1]}"

            if result[0][1] != nil && result[0][1] == "king_no_move"
              next unless piece.name != 'Black King'

              puts "piece  KING NO MOVE"
              puts "piece #{piece.current_position}"

              piece.transforms.each do |transform_w_string|
                next if transform_w_string.nil?

                transform_w_string.each do |transform|
                  next if transform.nil?

                  puts "piece transforms #{[transform[0..1]]}"
                  puts "result #{result[0][0]}"
                  if [transform[0..1]] == (result[0][0])
                    puts 'found'
                    piece_to_move = piece
                    # puts "piece #{piece_to_move.current_position}"
                    puts "piece #{piece_to_move}"
                    # puts "result #{result}"
                    # game.undo_move_save
                    if piece.move_self(piece_to_move.current_position, result[0][0].flatten, @total_board, game,
                                       dont_move = false) != false
                      # game.render
                      checkmate?(game)
                      puts "CAN MOVE"
                      return
                    end
                  end
                end
              end
            end

            puts "result for include #{result}"
            if result[-1][-1].include?("true")
              puts "TRUE"
              result.delete("true")
              result = result.sample
              total_board.flatten.shuffle.each do |piece|
                next if piece.team != "black"
                next unless piece.name == 'Black King'

                puts "KING FOUND"
                # puts "piece #{piece.current_position}"

                piece.transforms.each do |transform_w_string|
                  next if transform_w_string.nil?

                  transform_w_string.each do |transform|
                    next if transform.nil?

                    puts "piece transforms #{transform[0..1]}"
                    puts "result #{result}"
                    if transform[0..1] == (result[0][0])
                      puts 'found'
                      piece_to_move = piece
                      # puts "piece #{piece_to_move.current_position}"
                      # puts "piece #{piece_to_move}"
                      # puts "result #{result}"
                      # game.undo_move_save
                      if piece.move_self(piece_to_move.current_position, result[0][0].flatten, @total_board, game,
                                         dont_move = false) != false
                        # game.render
                        checkmate?(game)
                        puts "CAN MOVE"
                        return
                      end
                    end
                  end
                end
              end
            end

            # puts "piece transforms #{piece.transforms}"
            puts "HERE"
            piece.transforms.each do |all_transform|
              # puts "piece  all transform #{all_transform}"
              # puts "here 3"
              all_transform.each do |transform|
                # puts "here 4"

                next if transform.nil? || piece.current_position == result[0]

                # puts "piece transform #{transform[0..1]}"
                # puts "result #{result[0]}"
                # puts "transform #{transform[0..1]}"
                if transform[0..1] == (result[0][0])
                  # puts 'found'
                  piece_to_move = piece
                  # puts "piece #{piece_to_move.current_position}"
                  # puts "piece #{piece_to_move}"
                  # puts "result #{result[0][0]}"
                  # game.undo_move_save
                  if piece.move_self(piece_to_move.current_position, result[0][0].flatten, @total_board, game,
                                     dont_move = false) != false
                    game.render
                    checkmate?(game)
                    # puts "CAN MOVE"
                    # puts "Black Check #{@black_check}"
                    return
                  end

                  # checkmate?(game)
                  # puts "black check #{@black_check}"
                  # if @black_check == true
                  #   puts "UNDO"
                  #   game.load_game_undo(game)
                  # else
                  #   # move_piece(piece_to_move, piece_to_move.current_position, game, result[0],
                  #   #            to_redo = false)
                  #   return
                end
              end
            end
          end
          return
        end
      end
    end
    # puts "piece_to_move#{piece_to_move}"

    loop do
      if @black_check == false
        piece_to_move = total_board.flatten.sample
        next if piece_to_move.current_position == [-10, -10]

        if piece_to_move.team == 'black' && piece_to_move.transforms.any? { |transform| transform != nil }
          piece_to_move.update_transforms(@total_board)
          # puts "piece to move transforms #{piece_to_move.transforms}"
          while true

            new_position = piece_to_move.transforms.sample
            # puts "new pos is #{new_position}"
            break if new_position.find { |transform| transform != nil }
          end
          # new_position - new_position[2]
          new_position.map do |transform|
            if transform == nil
              new_position.delete(transform)
            end
          end

          new_position = new_position.sample
          new_position = [new_position[0], new_position[1]]
          puts "new pos is #{[new_position[0], new_position[1]]}"
          puts "piece to move is #{piece_to_move}#{piece_to_move.current_position}"
          selected_position = piece_to_move.current_position
          game.undo_move_save
          if move_piece(piece_to_move, selected_position, game, new_position, to_redo = false) != false
            checkmate?(game)

            game.load_game_undo(game) if @black_check == true
            break
          end
        end
      end
    end
  end

  def cpu_move_king_moves
  end

  def cpu_move_king_does_not_move
  end

  def cpu_move_capture
  end
end

game = Game.new
game.game_loop(game)

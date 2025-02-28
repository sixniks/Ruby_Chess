require_relative 'board'
# BUGS:
# Spaces ([ ]) are colored incorrectly
# Knight emoji is black for both players

# TO DO:
# Have to move piece to take yourself out of check
# Check and Checkmate
# Pawn into Queen
# Castling
# Display grid numbers
# Serialize
# CPU moves
class Game < Board
  attr_accessor :board, :white_turn, :black_mate, :white_mate, :transforms_black, :transforms_white

  def initialize
    super
    @board = Board.new
    @white_turn = true
    @black_mate = false
    @white_mate = false
    @transforms_black = []
    @transforms_white = []
  end

  def game_loop(game)
    loop do
      until @black_mate || @white_mate == true
        # puts "\e[H\e[2J"
        checkmate?(game)
        puts "White Turn \n" if @white_turn
        puts 'Black Turn' unless @white_turn
        game.render

        piece_to_move = valid_input_select?

        selected_position = piece_to_move.current_position
        # possible_moves(game)
        move_piece(piece_to_move, selected_position, game)

        # possible_moves(game)

        # game.render
        @white_turn = !@white_turn

      end
    end
  end
  #  end

  def valid_input_select?
    puts "\nPlease select your piece using the x and y cordinates. Example: 1,1"
    selected_position = gets.chomp.split(',').map(&:to_i)
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
    puts 'Please select a valid space'
    valid_input_select?
  end

  def move_piece(piece_to_move, selected_position, game)
    dont_move = false
    puts 'Please select where you want the piece to move'
    new_position = get_new_position(piece_to_move, game)
    # rubocop:disable Style\GuardClause

    if piece_to_move.name.include?('Pawn')

      if pawns.move_pawn(selected_position, new_position, @total_board, game, dont_move = false) == false

        redo_move(game)
        return
        # else
        #   puts "true"
        #   return true
      end
    end
    if piece_to_move.name.include?('Queen')
      if queens.move_queen(selected_position, new_position, @total_board, game, dont_move) == false

        redo_move(game)
        return
      end
    end
    if piece_to_move.name.include?('King')
      if kings.move_king(selected_position, new_position, @total_board, game, dont_move) == false

        redo_move(game)
        return
      end
    end
    if piece_to_move.name.include?('Bishop')
      if bishops.move_bishop(selected_position, new_position, @total_board, game, dont_move) == false

        redo_move(game)
        return
      end
    end
    if piece_to_move.name.include?('Rook')
      if rooks.move_rook(selected_position, new_position, @total_board, game, dont_move) == false

        redo_move(game)
        return
      end
    end
    if piece_to_move.name.include?('Knight')
      if knights.move_knight(selected_position, new_position, @total_board, game, dont_move) == false

        redo_move(game)
        return
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

  def redo_move(game)
    # puts "\e[H\e[2J"
    puts 'That piece can not move that way'
    puts 'White turn' if @white_turn
    puts 'Black turn' if !@white_turn
    game.render
    piece_to_move = valid_input_select?
    selected_position = piece_to_move.current_position
    move_piece(piece_to_move, selected_position, game,)
    @total_board
  end

  # If black transforms can move to white king current pos
  # Then white is in check
  # If white king's transforms are covered by black transforms
  # Then checkmate
  def checkmate?(game)
    possible_moves(game)
    @total_board.flatten.each do |piece|
      next unless piece.name == 'White King' || piece.name == 'Black King'

      if piece.name == 'White King'
        # puts "black transforms are #{@transforms_black}"
        @transforms_black.each do |transform|
          # puts "HERE"
          if transform == piece.current_position
            puts "White in Check"
            result = piece.transforms - @transforms_black
            if result.flatten == piece.current_position
              puts "Checkmate, Black Wins"
            end
          end
        end
      elsif piece.name == 'Black King'
        # puts "kings transforms are #{piece.transforms}"
        # puts "white transforms are #{@transforms_white}"
        @transforms_white.each do |transform_arr|
          # puts "transform_arr #{transform_arr}"
          # puts "piece current position #{piece.current_position}"
          transform_arr.each do |transform|
            # puts "transform #{transform}"
            if transform == piece.current_position
              puts "Black in Check"
            end

            result = piece.transforms - @transforms_white
            if result.flatten == piece.current_position
              puts "Checkmate, white Wins"
            end
          end
        end
      end
    end
  end

  # Get all pawns
  # Take the transform as new pos
  # And the current pos as selected position
  # If we return not false we know we can move
  def possible_moves(game)
    all_transforms = []
    pawn_transforms = pawns.get_possible_moves(@total_board, game)
    pawn_transforms_black = pawn_transforms[0]
    pawn_transforms_white = pawn_transforms[1]
    puts "pawn_transforms_white#{pawn_transforms_white.uniq}"
    puts "pawn_transforms_black#{pawn_transforms_black.uniq}"
    @transforms_black << pawn_transforms_black.uniq
    @transforms_white << pawn_transforms_white.uniq

    # king_transforms = kings.get_possible_moves(@total_board, game)
    # king_transforms_white = king_transforms[1]
    # puts "king_transforms_white#{king_transforms_white}"
    # king_transforms_black = king_transforms[0]
    # transforms_black << king_transforms_black
    # transforms_white << king_transforms_white

    queen_transforms = queens.get_possible_moves(@total_board, game)
    queen_transforms_white = queen_transforms[1]
    puts "queen_transforms_white#{queen_transforms_white}"
    queen_transforms_black = queen_transforms[0]
    @transforms_black << queen_transforms_black
    @transforms_white << queen_transforms_white
    return all_transforms
    # bishops_transforms = bishops.get_possible_moves(@total_board, game)
    # bishops_transforms_white = bishops_transforms[1]
    # puts "bishop_transforms_white#{bishops_transforms_white}"
    # bishops_transforms_black = bishops_transforms[0]
    # transforms_black << bishops_transforms_black
    # transforms_white << bishops_transforms_white

    # knights_transforms = knights.get_possible_moves(@total_board, game)
    # knight_transforms_white = knights_transforms[1]
    # # puts "knight_transforms_white#{knight_transforms_white}"
    # puts "knight_transforms_white#{knight_transforms_white}"
    # knight_transforms_black = knights_transforms[0]
    # transforms_black << knight_transforms_black
    # transforms_white << knight_transforms_white

    # rooks_transforms = rooks.get_possible_moves(@total_board, game)
    # rook_transforms_white = rooks_transforms[1]
    # puts "rook_transforms_white#{rook_transforms_white}"
    # rook_transforms_black = rooks_transforms[0]
    # transforms_black << rook_transforms_black
    # transforms_white << rook_transforms_white
    # # fixed_transforms_white = []
    # # fixed_transforms_black = []
    # # transforms_white.map do |transform|
    # #   fixed_transforms_white << transform.uniq
    # # end
    # # transforms_black.map do |transform|
    # #   fixed_transforms_black << transform.uniq
    # # end
  end
end

game = Game.new
game.game_loop(game)

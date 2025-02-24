require_relative 'board'
# BUGS:
# WHEN
# A player tries to move the opposing players piece, the next input is
# always treated as invalid
# Pawns can move diagnoally even if there is no opposing piece'
# Spaces ([ ]) are colored incorrectly

# TO DO:
# Check and Checkmate
# Pawn into Queen
# Castling
# Display grid numbers
# Serialize
# CPU moves
class Game < Board
  attr_accessor :board, :white_turn, :black_mate, :white_mate

  def initialize
    super
    @board = Board.new
    @white_turn = true
    @black_mate = false
    @white_mate = false
  end

  def game_loop(game)
    while @black_mate || @white_mate == false
      puts "White Turn \n" if @white_turn
      puts 'Black Turn' unless @white_turn
      game.render
      piece_to_move = valid_input_select?
      puts "you selected #{piece_to_move.name}"
      selected_position = piece_to_move.current_position

      move_piece(piece_to_move, selected_position, game)
      game.render
      @white_turn = !@white_turn
    end
  end

  def valid_input_select?
    puts "\nPlease select your piece using the x and y cordinates. Example: 1,1"
    selected_position = gets.chomp.split(',').map(&:to_i)
    @total_board.flatten.each do |piece|
      # p piece
      next unless piece.current_position == selected_position

      if piece.name.include?('white') && @white_turn
        puts 'white move'
        return piece
      end
      if piece.name.include?('white') && !@white_turn
        puts ' black cannot move white pieces'
        valid_input_select?
      end
      if piece.name.include?('black') && @white_turn
        puts 'white cannot move black pieces'
        valid_input_select?
      end
      return piece if piece.name.include?('black') && !@white_turn
    end
    puts 'Invalid input! Please input 2 numbers seperated by comma 1-8. e.g: 1,1'
    valid_input_select?
  end

  def move_piece(piece_to_move, selected_position, game)
    puts 'Please select where you want the piece to move'
    # rubocop:disable Style\GuardClause
    # loop until new_position = gets.chomp.split(',').map(&:to_i).all? { |item| item.between(1, 8) }
    if piece_to_move.name.include?('pawn')
      loop until pawns.move_pawn(selected_position, new_position = gets.chomp.split(',').map(&:to_i),
                                 @total_board, game) != false
      new_position
    end
    if piece_to_move.name.include?('queen')
      loop until queens.move_queen(selected_position, new_position = gets.chomp.split(',').map(&:to_i),
                                   @total_board) != false
      new_position
    end
    if piece_to_move.name.include?('king')
      loop until kings.move_king(selected_position, new_position = gets.chomp.split(',').map(&:to_i),
                                 @total_board) != false
      new_position
    end
    if piece_to_move.name.include?('bishop')
      loop until bishops.move_bishop(selected_position, new_position = gets.chomp.split(',').map(&:to_i),
                                     @total_board) != false
      new_position
    end
    if piece_to_move.name.include?('rook')
      loop until rooks.move_rooks(selected_position, new_position = gets.chomp.split(',').map(&:to_i),
                                  @total_board) != false
      new_position
    end
    if piece_to_move.name.include?('knight')
      loop until knights.move_knight(selected_position, new_position = gets.chomp.split(',').map(&:to_i),
                                     @total_board) != false
      new_position
    end
  end
end

game = Game.new
game.game_loop(game)

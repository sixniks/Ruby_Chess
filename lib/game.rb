require_relative 'board'
# TO DO:
# Collision
# rename transforms in pieces
# Fix method calls in move_piece
# Check and Checkmate
# Redo for input
# Show board at start
# Pawn into Queen
# Castling
# Display grid numbers
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

      piece_to_move = valid_input_select?
      puts "you selected #{piece_to_move.name}"
      selected_position = piece_to_move.current_position

      move_piece(piece_to_move, selected_position)
      # move_piece(piece_to_move, selected_position, new_position)
      game.render
      @white_turn = !@white_turn
    end
  end

  def valid_input_select?
    puts "\nPlease select your piece using the x and y cordinates. Example: 1,1"
    selected_position = gets.chomp.split(',').map(&:to_i)
    @total_board.flatten.each do |piece|
      next unless piece.current_position == selected_position

      if piece.name.include?('white') && @white_turn
        puts 'white move'
        return piece
      end
      if piece.name.include?('white') && !@white_turn
        puts 'white moves black'
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

  def move_piece(piece_to_move, selected_position)
    puts 'Please select where you want the piece to move'
    return unless piece_to_move.name.include?('pawn')

    loop until pawns.move_pawn(selected_position, new_position = gets.chomp.split(',').map(&:to_i),
                               @total_board) != false

    new_position

    ### DO COLISSION checking here
    #    # @total_board.flatten.each do |piece|
    #   p piece.transforms
    # return new_position unless piece.current_position == new_position

    # valid_input_move?
  end
end

game = Game.new
game.game_loop(game)
# game.move_piece(1, 2, 1, 3)
# game.move_piece(1, 3, 1, 4)
# game.move_piece(1, 4, 1, 5)
# game.move_piece(8, 2, 8, 3)
# game.board.total_board
# game.render

# p @board.total_board
# @board.render

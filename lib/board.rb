require_relative 'chess_pieces/bishops'
require_relative 'chess_pieces/king'
require_relative 'chess_pieces/queens'
require_relative 'chess_pieces/rooks'
require_relative 'chess_pieces/knights'
require_relative 'chess_pieces/pawns'
require 'colorize'
class Board
  BLACKPAWN = ' [♟ ] '.colorize(:black)
  WHITEPAWN = ' [♟ ] '.colorize(:white)
  WHITEKNIGHT = ' [♘ ] '.colorize(:white)
  BLACKKNIGHT = ' [♘ ] '.colorize(:black)
  WHITEROOK = ' [♜ ] '.colorize(:white)
  BLACKROOK = ' [♜ ] '.colorize(:black)
  WHITEQUEEN = ' [♕ ] '.colorize(:white)
  BLACKQUEEN = ' [♕ ] '.colorize(:black)
  WHITEKING = ' [♚ ] '.colorize(:white)
  BLACKKING = ' [♚ ] '.colorize(:black)
  WHITEBISHOP = ' [♗ ] '.colorize(:white)
  BLACKBISHOP = ' [♗ ] '.colorize(:black)
  EMPTY = ' [  ] '

  attr_accessor :total_board, :pawns, :queens, :kings, :bishops, :rooks, :knights, :current_position

  def initialize
    @bishops = BISHOPS.new
    all_bishops = @bishops.make_bishops
    @kings = KINGS.new
    all_kings = @kings.make_kings
    @queens = QUEENS.new
    all_queens = @queens.make_queens
    @rooks = ROOKS.new
    all_rooks = @rooks.make_rooks
    @knights = KNIGHTS.new
    all_knights = @knights.make_knights
    @pawns = PAWNS.new
    all_pawns = @pawns.make_pawns
    @total_board = all_pawns, all_knights, all_queens, all_kings, all_rooks, all_bishops
  end

  # Row is x
  # Column is y
  # Look at row and column as ordered pair... (row = 1, column = 1) == (x = 1, y = 1)
  # SO
  #   Walk the total_board array and find matching cord
  #   Take name of matching cord and puts/print corresponding emoji
  def render
    # p @total_board.flatten
    8.downto(1) do |row|
      1.upto(8) do |column|
        @emoji = EMPTY
        @total_board.flatten.each do |item|
          # p item.name

          next unless item.current_position == [column, row]

          name = item.name
          @emoji = if name == 'Black Pawn'
                     BLACKPAWN
                   elsif name == 'White Pawn'
                     WHITEPAWN
                   elsif name == 'White Knight'
                     WHITEKNIGHT
                   elsif name == 'Black Knight'
                     BLACKKNIGHT
                   elsif name == 'Black Rook'
                     BLACKROOK
                   elsif name == 'White Rook'
                     WHITEROOK
                   elsif name == 'White Queen'
                     WHITEQUEEN
                   elsif name == 'Black Queen'
                     BLACKQUEEN
                   elsif name == 'Black King'
                     BLACKKING
                   elsif name == 'White King'
                     WHITEKING
                   elsif name == 'Black Bishop'
                     BLACKBISHOP
                   elsif name == 'White Bishop'
                     WHITEBISHOP
                   else
                     EMPTY
                   end
        end
        column != 8 ? print(@emoji) : puts(@emoji)
      end
    end
  end
end

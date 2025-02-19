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

  attr_accessor :total_board, :pawns

  def initialize
    bishops = BISHOPS.make_bishops
    kings = KINGS.make_kings
    queens = QUEENS.make_queens
    rooks = ROOKS.make_rooks
    knights = KNIGHTS.make_knights
    @pawns = PAWNS.new
    all_pawns = @pawns.make_pawns
    @total_board = all_pawns, knights, queens, kings, rooks, bishops
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
          @emoji = if name == 'black_pawns'
                     BLACKPAWN
                   elsif name == 'white_pawns'
                     WHITEPAWN
                   elsif name == 'white_knight'
                     WHITEKNIGHT
                   elsif name == 'black_knight'
                     BLACKKNIGHT
                   elsif name == 'black_rook'
                     BLACKROOK
                   elsif name == 'white_rook'
                     WHITEROOK
                   elsif name == 'white_queen'
                     WHITEQUEEN
                   elsif name == 'black_queen'
                     BLACKQUEEN
                   elsif name == 'black_king'
                     BLACKKING
                   elsif name == 'white_king'
                     WHITEKING
                   elsif name == 'bishop_black'
                     BLACKBISHOP
                   elsif name == 'bishop_white'
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

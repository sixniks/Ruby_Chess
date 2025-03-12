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
  WHITEKNIGHT = ' [♞ ] '
  BLACKKNIGHT = ' [♘ ] '.colorize(:black)
  WHITEROOK = ' [♜ ] '.colorize(:white)
  BLACKROOK = ' [♖ ] '.colorize(:black)
  WHITEQUEEN = ' [♕ ] '.colorize(:white)
  BLACKQUEEN = ' [♕ ] '.colorize(:black)
  WHITEKING = ' [♚ ] '.colorize(:white)
  BLACKKING = ' [♚ ] '.colorize(:black)
  WHITEBISHOP = ' [♗ ] '.colorize(:white)
  BLACKBISHOP = ' [♗ ] '.colorize(:black)
  EMPTYWHITE = ' [  ] '
  EMPTYBLACK = ' [  ] '.colorize(:black)

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

  def save_game(white_turn, user_team_black)
    @white_turn = white_turn
    @user_team_black = user_team_black
    f = File.open('total_board.yml', 'w')
    x = YAML.dump(@total_board, f)

    f2 = File.open('white_turn.yml', 'w')
    p = YAML.dump(@white_turn, f)

    f3 = File.open('user_team_black.yml', 'w')
    k = YAML.dump(@user_team_black, f)

    f.close
    f2.close
    f3.close
    puts 'SAVE'
  end

  def load_game(game)
    puts 'Load'
    @total_board = YAML.unsafe_load(File.open('total_board.yml'))
    @white_turn = YAML.unsafe_load(File.open('white_turn.yml'))
    @user_team_black = YAML.unsafe_load(File.open('user_team_black.yml'))
    puts "@user_team_black#{@user_team_black}"
    game.render
    # @total_board
    [@white_turn, @user_team_black]
  end

  def undo_move_save
    u = File.open('total_board_undo.yml', 'w')
    x = YAML.dump(@total_board, u)
    u.close
    puts 'SAVE'
  end

  def load_game_undo(game, check_move = false)
    puts 'Load'
    puts 'You can not move yourself into check' if check_move == true
    @total_board = YAML.unsafe_load(File.open('total_board_undo.yml'))
    # puts "total board #{@total_board}"
    game.render
    @total_board
  end

  # Row is x
  # Column is y
  # Look at row and column as ordered pair... (row = 1, column = 1) == (x = 1, y = 1)
  # SO
  #   Walk the total_board array and find matching cord
  #   Take name of matching cord and puts/print corresponding emoji
  def render
    # p @total_board.flatten
    num_queue_vert = [8, 7, 6, 5, 4, 3, 2, 1, 1, 2, 3, 4, 5, 6, 7, 8]
    # num_queue_hori = [1, 2, 3, 4, 5, 6, 7, 8]
    @counter = 2
    8.downto(0) do |row|
      0.upto(8) do |column|
        next if row == 0 && column == 0

        @emoji = if row > 4
                   EMPTYBLACK
                 else
                   EMPTYWHITE
                 end
        if row.between?(0, 8) && column == 0 || column.between?(0, 8) && row == 0

          num = num_queue_vert.pop
          @emoji = if row == 0 && column == 1
                     " #{num.to_s.rjust(8.5)}   "
                   else
                     num.to_s.rjust(3).ljust(6)
                   end
        end
        @total_board.flatten.each do |item|
          # p item.name

          next unless item.current_position == [column, row]

          # next if column == 9 && row == 1

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
                     EMPTYBLACK
                   end
        end
        column != 8 ? print(@emoji) : puts(@emoji)
      end
    end
    # print(1.to_s.rjust(3, ' '), '    2', '  3', '  4', '  5', '  6', '  7', "  8\n")
  end
end

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
      elsif piece.current_position == space && pawn_to_move.team != piece.team && !transform_used.include?('diagonaol')
        return false
      elsif piece.current_position == space && transform_used.include?('diagonaol')
        # puts "piece team #{piece.team}"
        # puts "pawn_to_move.team #{pawn_to_move.team}"
        return false unless pawn_to_move.team != piece.team

        return true
      end
    end
  end
end
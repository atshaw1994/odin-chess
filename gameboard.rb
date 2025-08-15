Dir[File.join(__dir__, 'pieces', '*.rb')].each { |file| require file }

# Gameboard represents an 8x8 chess board and manages piece placement and movement.
class Gameboard
  # Only expose read access to the board for display/testing
  attr_reader :board

  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
    setup_board
  end

  # Set up all pieces in their starting positions
  def setup_board
    place_all(:white)
    place_all(:black)
  end

  # Place a piece on the board using chess notation.
  # row: 1-8 (chess row, 8 is top), col: 'A'-'H' (chess column), piece: chess piece object
  # Returns true if successful, false if invalid position or occupied.
  def place_piece(row, col, piece)
    row_idx = 8 - row.to_i
    col_idx = col.upcase.ord - 'A'.ord
    unless (0..7).include?(row_idx) && (0..7).include?(col_idx)
      warn "Invalid position: #{col}#{row}"
      return false
    end
    unless valid_move?(row_idx, col_idx)
      warn "Cell #{col}#{row} is already occupied."
      return false
    end
    @board[row_idx][col_idx] = piece
    true
  end

  # Removes a piece from the board at the given chess notation (row: 1-8, col: 'A'-'H')
  # Returns the removed piece, or nil if the cell was empty or invalid.
  def remove_piece(row, col)
    row_idx = 8 - row.to_i
    col_idx = col.upcase.ord - 'A'.ord
    return nil unless (0..7).include?(row_idx) && (0..7).include?(col_idx)
    removed = @board[row_idx][col_idx]
    @board[row_idx][col_idx] = nil
    removed
  end

  # Move a piece using chess notation (e.g., 'E2' to 'E4') or board indices.
  # Accepts either (start_row, start_col, end_row, end_col) as indices (0-7),
  # or (start_row, start_col, end_row, end_col) as chess notation (1-8, 'A'-'H').
  # Returns true if move is successful, false otherwise.
  def move_piece(start_row, start_col, end_row, end_col)
    # Convert chess notation to indices if needed
    if start_row.is_a?(Integer) && start_col.is_a?(String)
      start_row = 8 - start_row.to_i
      start_col = start_col.upcase.ord - 'A'.ord
    end
    if end_row.is_a?(Integer) && end_col.is_a?(String)
      end_row = 8 - end_row.to_i
      end_col = end_col.upcase.ord - 'A'.ord
    end
    unless (0..7).include?(start_row) && (0..7).include?(start_col) && (0..7).include?(end_row) && (0..7).include?(end_col)
      return false
    end
    
    piece = @board[start_row][start_col]
    if piece.nil?
      return false
    end

    # Basic move validation for the piece
    if piece.respond_to?(:valid_move?)
      unless piece.valid_move?([start_row, start_col], [end_row, end_col], @board)
        return false
      end
    end

    # Check if the move would put the current player's king in check
    # Simulate the move
    original_piece_at_dest = @board[end_row][end_col]
    @board[end_row][end_col] = piece
    @board[start_row][start_col] = nil
    
    is_in_check = in_check?(piece.color, @board)
    
    # Undo the move
    @board[start_row][start_col] = piece
    @board[end_row][end_col] = original_piece_at_dest
    
    return false if is_in_check
    
    # If all checks pass, perform the actual move
    @board[end_row][end_col] = piece
    @board[start_row][start_col] = nil
    return true
  end

  # Returns true if the cell is on the board and empty
  def valid_move?(row, col)
    row.between?(0, 7) && col.between?(0, 7) && @board[row][col].nil?
  end

  # Print the board to the console with chess notation headers
  def display_board
    @board.each_with_index do |row, idx|
      # Print row number (8 to 1 for chess)
      print "#{8 - idx} "
      puts row.map { |cell| cell.nil? ? '-' : cell.to_s }.join(' ')
    end
    # Print column headers (A-H) below the board
    col_headers = ('A'..'H').to_a
    puts "  " + col_headers.join(' ')
  end

  # Returns [row, col] of the king for the given color
  def find_king(color)
    @board.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        return [r, c] if piece && piece.class.to_s.downcase == "king" && piece.color == color
      end
    end
    nil
  end

  # Returns true if the king of the given color is in check
  def in_check?(color, board = @board)
    king_pos = find_king(color)
    return false unless king_pos
    board.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        next unless piece && piece.color != color
        return true if piece.valid_move?([r, c], king_pos, board)
      end
    end
    false
  end

  # Returns true if the player of the given color is in checkmate
  def checkmate?(color)
    # A king must be in check to be in checkmate.
    return false unless in_check?(color, @board)

    # Iterate over all pieces of the color that is in check.
    @board.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        next unless piece && piece.color == color
        
        # For each piece, check every possible destination on the board.
        (0..7).each do |new_r|
          (0..7).each do |new_c|
            # A piece cannot move to its current location.
            next if [r, c] == [new_r, new_c]
            
            # Check if the move is valid for the specific piece.
            if piece.valid_move?([r, c], [new_r, new_c], @board)
              # Simulate the move.
              original_piece_at_dest = @board[new_r][new_c]
              @board[new_r][new_c] = piece
              @board[r][c] = nil
              
              # Check if the move gets the king out of check.
              can_escape = !in_check?(color, @board)

              # Undo the move regardless of the outcome.
              @board[r][c] = piece
              @board[new_r][new_c] = original_piece_at_dest
              
              # If we found a move that gets the king out of check, it's not checkmate.
              return false if can_escape
            end
          end
        end
      end
    end
    # If we have iterated through all possible moves and none of them get the king out of check, it is checkmate.
    true
  end

  private 

  def place_all(color)
    place_pawns(color)
    place_rooks(color)
    place_bishops(color)
    place_knights(color)
    place_queens(color)
    place_kings(color)
  end

  def place_pawns(color)
    row = color == :white ? 2 : 7
    ('A'..'H').each do |col|
      place_piece(row, col, Pawn.new(color))
    end
  end

  def place_rooks(color)
    row = color == :white ? 1 : 8
    ['A', 'H'].each do |col|
      place_piece(row, col, Rook.new(color))
    end
  end

  def place_bishops(color)
    row = color == :white ? 1 : 8
    ['C', 'F'].each do |col|
      place_piece(row, col, Bishop.new(color))
    end
  end

  def place_knights(color)
    row = color == :white ? 1 : 8
    ['B', 'G'].each do |col|
      place_piece(row, col, Knight.new(color))
    end 
  end

  def place_queens(color)
    row = color == :white ? 1 : 8
    place_piece(row, 'D', Queen.new(color))
  end

  def place_kings(color)
    row = color == :white ? 1 : 8
    place_piece(row, 'E', King.new(color))
  end
end
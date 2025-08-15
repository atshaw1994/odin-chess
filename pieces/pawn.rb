class Pawn
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def to_s
    @color == :white ? "♙" : "♟"
  end

  def valid_move?(start_pos, end_pos, board)
    # Basic pawn movement logic
    direction = @color == :white ? -1 : 1
    start_row, start_col = start_pos
    end_row, end_col = end_pos

    # Determine starting row for two-square move (array indices)
    starting_row = @color == :white ? 6 : 1

    # Move forward one square
    if end_row == start_row + direction && end_col == start_col && board[end_row][end_col].nil?
      return true
    end

    # Move forward two squares from starting position
    if start_row == starting_row && end_row == start_row + 2 * direction && end_col == start_col && board[end_row][end_col].nil? && board[start_row + direction][start_col].nil?
      return true
    end

    # Capture diagonally
    if end_row == start_row + direction && (end_col == start_col - 1 || end_col == start_col + 1) && !board[end_row][end_col].nil? && board[end_row][end_col].color != @color
      return true
    end

    false
  end
end
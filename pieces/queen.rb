class Queen
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def to_s
    @color == :white ? "♕" : "♛"
  end

  def valid_move?(start_pos, end_pos, board)
    # Basic queen movement logic
    start_row, start_col = start_pos
    end_row, end_col = end_pos

    row_diff = (end_row - start_row).abs
    col_diff = (end_col - start_col).abs

    # Queen moves in straight lines or diagonals
    if start_row == end_row || start_col == end_col
      # Straight line movement (like a rook)
      if start_row == end_row
        step = start_col < end_col ? 1 : -1
        (start_col + step).step(end_col - step, step) do |col|
          return false unless board[start_row][col].nil?
        end
      else
        step = start_row < end_row ? 1 : -1
        (start_row + step).step(end_row - step, step) do |row|
          return false unless board[row][start_col].nil?
        end
      end
      return true
    elsif row_diff == col_diff
      # Diagonal movement (like a bishop)
      row_step = start_row < end_row ? 1 : -1
      col_step = start_col < end_col ? 1 : -1
      current_row, current_col = start_row + row_step, start_col + col_step

      while current_row != end_row && current_col != end_col
        return false unless board[current_row][current_col].nil?
        current_row += row_step
        current_col += col_step
      end
      return true
    end

    false
  end
end
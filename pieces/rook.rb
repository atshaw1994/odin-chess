class Rook
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def to_s
    @color == :white ? "♖" : "♜"
  end

  def valid_move?(start_pos, end_pos, board)
    # Basic rook movement logic
    start_row, start_col = start_pos
    end_row, end_col = end_pos

    # Rook moves in straight lines: either same row or same column
    if start_row == end_row
      step = start_col < end_col ? 1 : -1
      (start_col + step).step(end_col - step, step) do |col|
        return false unless board[start_row][col].nil?
      end
      return true
    elsif start_col == end_col
      step = start_row < end_row ? 1 : -1
      (start_row + step).step(end_row - step, step) do |row|
        return false unless board[row][start_col].nil?
      end
      return true
    end

    false
  end
end
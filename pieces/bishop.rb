class Bishop
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def to_s
    @color == :white ? "♗" : "♝"
  end

  def valid_move?(start_pos, end_pos, board)
    start_row, start_col = start_pos
    end_row, end_col = end_pos

    row_diff = (end_row - start_row).abs
    col_diff = (end_col - start_col).abs

    return false unless row_diff == col_diff && row_diff != 0

    step_row = (end_row - start_row) / row_diff
    step_col = (end_col - start_col) / col_diff

    (1...row_diff).each do |i|
      intermediate_row = start_row + i * step_row
      intermediate_col = start_col + i * step_col
      return false unless board[intermediate_row][intermediate_col].nil?
    end

    target_piece = board[end_row][end_col]
    return target_piece.nil? || target_piece.color != @color
  end
end
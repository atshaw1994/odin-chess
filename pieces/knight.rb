class Knight
  attr_reader :color
  
  def initialize(color)
    @color = color
  end

  def to_s
    @color == :white ? "♘" : "♞"
  end

  def valid_move?(start_pos, end_pos, board) 
    # Basic knight movement logic
    start_row, start_col = start_pos
    end_row, end_col = end_pos

    row_diff = (end_row - start_row).abs
    col_diff = (end_col - start_col).abs

    # Knight moves in an "L" shape: 2 squares in one direction and 1 square perpendicular
    (row_diff == 2 && col_diff == 1) || (row_diff == 1 && col_diff == 2)
  end
end

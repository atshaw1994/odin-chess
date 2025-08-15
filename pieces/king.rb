# King.rb

class King
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def to_s
    @color == :white ? "♔" : "♚"
  end

  def valid_move?(start_pos, end_pos, board)
    row_diff = (start_pos[0] - end_pos[0]).abs
    col_diff = (start_pos[1] - end_pos[1]).abs

    # A King can move one square in any direction.
    return false unless row_diff <= 1 && col_diff <= 1

    # Check if the destination is occupied by the same color piece.
    destination_piece = board[end_pos[0]][end_pos[1]]
    return false if destination_piece && destination_piece.color == color

    true
  end
end
require_relative 'gameboard'

class Game
  attr_accessor :current_player, :gameboard

  def initialize
    @gameboard = Gameboard.new
    @current_player = :white
  end

  def start
    puts "Welcome to Chess!"
    @gameboard.display_board
    play_game
  end
  
  def switch_player
    @current_player = @current_player == :white ? :black : :white
  end

  private

  def play_game
    loop do
      print "#{@current_player.to_s.capitalize}: Enter your move (e.g., E2-E4): "
      input = gets.chomp.strip.upcase
      if input =~ /([A-H][1-8])-([A-H][1-8])/i
        start, dest = $1, $2
        start_col, start_row = start[0], start[1].to_i
        end_col, end_row = dest[0], dest[1].to_i
        piece = @gameboard.board[8 - start_row][start_col.ord - 'A'.ord]

        if piece.nil?
          puts "No piece at #{start}."
        elsif piece.color != @current_player
          puts "That is not your piece!"
        elsif @gameboard.move_piece(start_row, start_col, end_row, end_col)
          @gameboard.display_board
          # Logic for check/checkmate
          if @gameboard.in_check?(piece.color == :white ? :black : :white)
            if @gameboard.checkmate?(piece.color == :white ? :black : :white)
              puts "Checkmate! #{@current_player.to_s.capitalize} wins!"
              break
            else
              puts "Check!"
            end
          end
          switch_player
        else
          puts "Invalid move."
        end
      elsif input.casecmp('exit').zero?
        puts "Exiting the game."
        break
      else
        puts "Invalid input format. Please use e.g., E2-E4."
      end
    end
  end

end

# Start the game when this file is run directly.
if __FILE__ == $0
  Game.new.start
end
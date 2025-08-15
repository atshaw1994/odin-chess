require_relative '../game'
require_relative '../gameboard'

RSpec.describe Game do
  it "initializes game with a gameboard and a current player" do
    game = Game.new
    expect(game.gameboard).to be_a(Gameboard)
    expect(game.current_player).to eq(:white)
  end
  it "switches players properly" do
    game = Game.new
    game.switch_player
    expect(game.current_player).to eq(:black)
    game.switch_player
    expect(game.current_player).to eq(:white)
  end

  it "allows players to make valid moves" do
    game = Game.new
    expect(game.gameboard.move_piece(2, 'E', 3, 'E')).to be true  # Move to E3
    expect(game.gameboard.board[5][4]).to be_a(Pawn)
    expect(game.gameboard.board[6][4]).to be_nil
  end

  it "does not allow players to move pieces of the wrong color" do
    game = Game.new
    # Mock a black piece move, followed by an 'exit' command.
    allow(game).to receive(:gets).and_return("E7-E6\n", "exit\n")
    # Use `expect { ... }.to output(...)` to capture the `puts` statements.
    expect { game.send(:play_game) }.to output(/That is not your piece!/).to_stdout
  end

  it "detects check but no checkmate" do
    gameboard = Gameboard.new
    gameboard.remove_piece(8, 'E')  # Remove the original black king at E8
    gameboard.place_piece(4, 'A', Pawn.new(:white))  # Place a white pawn at A4
    gameboard.place_piece(5, 'B', King.new(:black))  # Place a black king at B5
    expect(gameboard.in_check?(:black)).to be true # Black king is in check from white pawn
    expect(gameboard.checkmate?(:black)).to be false # Black king is not in checkmate
  end

  it "detects checkmate" do
    gameboard = Gameboard.new
    # Remove all pieces
    (1..8).each do |row|
      ('A'..'H').each do |col|
        gameboard.remove_piece(row, col)
      end
    end

    # Set up a checkmate scenario
    gameboard.place_piece(5, 'F', King.new(:white))
    gameboard.place_piece(5, 'H', King.new(:black))
    gameboard.place_piece(1, 'H', Rook.new(:white))

    expect(gameboard.checkmate?(:black)).to be true
  end
end
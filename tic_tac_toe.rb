require './cell.rb'
require './player.rb'
require './array.rb'
require './board.rb'
require './game.rb'
class TicTacToe


  def self.init_human_player(player_sign = gets.chomp)

    return [] unless ['x', 'X', '0'].include?(player_sign)
    @human_player = Player.new(player_sign: player_sign, player_name: 'human')
    ai_sign = @human_player.player_sign == 'X' ? '0' : 'X'
    @ai_player = Player.new(player_sign: ai_sign, player_name: 'computer')
    return ai_sign == 'X' ? [@ai_player, @human_player] : [@human_player, @ai_player]
  end

  
  puts "Welcome to tic tac toe"

  players = []
  while players.empty?
    puts "Select Your Sign: X or 0"
    players = init_human_player
  end
  puts players.inspect
  Game.new(players).play
end

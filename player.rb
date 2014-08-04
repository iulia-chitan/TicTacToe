class Player

  attr_reader :player_sign, :player_name
  def initialize(input)
    @player_sign = input.fetch(:player_sign)
    @player_name = input.fetch(:player_name)
  end
end
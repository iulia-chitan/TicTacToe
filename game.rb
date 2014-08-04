class Game

  attr_reader :players, :board, :current_player, :other_player

  Node = Struct.new(:score, :move)

  def initialize(players, board = Board.new)
    @players = players
    @board = board
    @current_player, @other_player = @players
  end

  def switch_players
    @current_player, @other_player = @other_player, @current_player
  end

  def solicit_move
    "Enter your move:"
  end

  def computer_player
    players.select{|p| p.player_name == 'computer'}.first
  end

  def human_player
    players.select{|p| p.player_name == 'human'}.first
  end

  def is_computer_first_move?
    grid_values = board.grid.flatten.map{|cell| cell.value}
    return !grid_values.include?(computer_player.player_sign)
  end

  def computer_first_move
    middle_cell = board.get_cell(1,1)
    return middle_cell.value.to_s.empty? ? [1, 1] : [0, 1]
  end

  def computer_move
   puts "It computer's turn: "
   x,y =  is_computer_first_move? ? computer_first_move : board.get_cell_coordinates(get_best_possible_move(board, current_player, 0).move)
   board.set_cell(x, y, computer_player.player_sign)


  end

  def score(board,base_score, depth = 0 )

    score = case computer_player.player_sign
              when 'X' then (board.win?(computer_player.player_sign) ? (base_score-depth) : (board.win?(human_player.player_sign) ? (depth-base_score) : 0))
              when '0' then (board.win?(computer_player.player_sign) ? (depth-base_score) : (board.win?(human_player.player_sign) ? (base_score-depth) : 0))
            end

    return score
  end

  def get_best_possible_move(board, player, depth)
    available_cells = board.free_cells
    base_score = 10

    if board.game_over
      node = Node.new(score(board, base_score, depth))

      return node
    end
    next_player = player == computer_player ? human_player : computer_player
    move_nodes = []


    # Populate the scores array
    available_cells.each do |cell|
      x, y = board.get_cell_coordinates(cell)
      possible_board = get_new_state(board, player,x,y)
      cell_score = get_best_possible_move(possible_board,next_player, depth+1)
      node = Node.new cell_score.score, cell
      move_nodes << node

    end
    # Do the min or the max calculation
    if player.player_sign == 'X'
      return move_nodes.max_by { |node| node.score }
    else
      return move_nodes.min_by { |node| node.score }
    end






  end

  def get_new_state(board, player,x,y)
    possible_board = board.generate_new_board
    possible_board.set_cell(x,y, player.player_sign)
    return possible_board
  end



  def get_move(human_move = gets.chomp)
    human_move_to_coordinate(human_move)
  end

  def get_available_cells
    board.free_cells
  end

  def check_move x, y
    return false if board.get_cell(x, y).nil?
    return false if (!board.get_cell(x, y).nil? &&  !board.get_cell(x, y).value.to_s.empty?)
    return true
  end

  def game_over_message
    return "#{current_player.player_sign} won!" if board.game_over == :winner
    return "The game ended in a tie" if board.game_over == :draw
  end


  def play

    while true
      board.formatted_grid
      puts "CURRENT PLAYER: #{current_player.player_name}"
      if current_player.player_name == 'computer'
        computer_move
        is_valid_move = true
      else
        puts solicit_move
        x, y = get_move
        is_valid_move = check_move(x, y)
        puts "Illegal Move" unless is_valid_move
        board.set_cell(x, y, current_player.player_sign) if is_valid_move
      end

      if board.game_over
        puts game_over_message
        board.formatted_grid
        return
      else
        switch_players if is_valid_move
      end
    end
  end

  private

  def human_move_to_coordinate(human_move)
    mapping = {
        "A1" => [0, 0],
        "A2" => [1, 0],
        "A3" => [2, 0],
        "B1" => [0, 1],
        "B2" => [1, 1],
        "B3" => [2, 1],
        "C1" => [0, 2],
        "C2" => [1, 2],
        "C3" => [2, 2]
    }
    mapping[human_move]
  end


end
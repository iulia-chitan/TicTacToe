class Board

  attr_reader :grid
  def initialize(input = {})
    @grid = input.fetch(:grid, default_grid)
  end

  def get_cell(x, y)
    grid[x][y] rescue nil
  end

  def get_cell_coordinates(cell)
    coord = []
    for i in 0..2
      for j in 0..2
        if grid[i][j] == cell
          coord = [i, j]
        end
      end
    end
    return coord

  end

  def free_cells
    grid.flatten.select{ |cell|  cell.value.to_s.empty? }
  end


  def set_free_cell sign
    free_cell.value = sign
  end

  def set_cell(x, y, player_sign)
    get_cell(x, y).value = player_sign

  end

  def formatted_grid

    puts  "#{grid[0][0].value.to_s.empty? ? ' ' : grid[0][0].value}" + '  | '+ "#{grid[0][1].value.to_s.empty? ? ' ' : grid[0][1].value }" +' | ' +"#{grid[0][2].value.to_s.empty? ? ' ' : grid[0][2].value}"
    puts "---+---+---"
    puts  "#{grid[1][0].value.to_s.empty? ? ' ' : grid[1][0].value}" + '  | '+ "#{grid[1][1].value.to_s.empty? ? ' ' : grid[1][1].value }" +' | ' +"#{grid[1][2].value.to_s.empty? ? ' ' : grid[1][2].value}"
    puts "---+---+---"
    puts  "#{grid[2][0].value.to_s.empty? ? ' ' : grid[2][0].value}" + '  | '+ "#{grid[2][1].value.to_s.empty? ? ' ' : grid[2][1].value }" +' | ' +"#{grid[2][2].value.to_s.empty? ? ' ' : grid[2][2].value}"




  end

  def game_over
    return :winner if winner?
    return :draw if draw?
    false
  end


  def winning_positions
    grid +
    grid.transpose +
    diagonals
  end

  def diagonals
    [
        [get_cell(0, 0), get_cell(1, 1), get_cell(2, 2)],
        [get_cell(0, 2), get_cell(1, 1), get_cell(2, 0)]
    ]
  end

  def winner?
    winning_positions.each do |winning_position|

      next if winning_position_values(winning_position).any?{|e| (e.to_s.empty? || e.to_s.nil?)}
      next if winning_position_values(winning_position).all_empty?
      return true if winning_position_values(winning_position).all_same?
    end
    false
  end

  def draw?
    grid.flatten.map { |cell| (cell.value)}.none_empty?
  end

  def win?(player_sign)
    winning_positions.each do |winning_position|

      if winning_position_values(winning_position).all_same?
        return  winning_position_values(winning_position).first == player_sign
      end
    end
  end


  def winning_position_values(winning_position)
    winning_position.map { |cell| cell.value }
  end

  def generate_new_board
    new_board = Board.new
    new_grid = new_board.grid

    for i in 0..2
      for j in 0..2
        val = Cell.new(grid[i][j].value)
        new_grid[i][j] = val
      end
    end

    return new_board
  end

  private

  def default_grid
    Array.new(3) { Array.new(3) { Cell.new } }
  end

end
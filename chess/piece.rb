require_relative 'game.rb'



class Piece
  attr_accessor :position
  attr_reader :board

  def initialize(position, board)
    @position = position
    @board = board
  end

  #Returns an array of possible locations it can go to
  def moves
    #should return an array of places a Piece can move to
  end

  def present?
    true
  end

  def to_s
    " x "
  end

end


############################
#      SLIDING PIECES      #
############################

class SlidingPiece < Piece

  #should return an array of places a Piece can move to
  def moves
    up_down_moves = get_down_moves + get_up_moves
    left_right_moves = get_left_moves + get_right_moves

    #collective lists of moves
    vert_hori_moves = up_down_moves + left_right_moves
    diagonal_moves = get_diagonal_moves

    total_possible_moves = (vert_hori_moves + diagonal_moves).uniq
    total_possible_moves.select { |move| move_dirs(move) }

  end

  private
  def get_down_moves
    current_row, current_column = self.position
    moves = []
    ((current_row + 1)..7).each do |row_num|
      if board.grid[row_num][current_column].is_a?(NullPiece)
        moves << [row_num, current_column]
      else
        break
      end
    end
    moves
  end

  def get_up_moves
    current_row, current_column = self.position
    moves = []
    (current_row - 1).downto(0) do |row_num|
      if board.grid[row_num][current_column].is_a?(NullPiece)
        moves << [row_num, current_column]
      else
        break
      end
    end

    moves
  end

  def get_left_moves
    current_row, current_column = self.position
    moves = []
    (current_column - 1).downto(0) do |col_num|
      if board.grid[current_row][col_num].is_a?(NullPiece)
        moves << [current_row, col_num]
      else
        break
      end
    end

    moves
  end

  def get_right_moves
    current_row, current_column = self.position
    moves = []
    ((current_column + 1)..7).each do |col_num|
      if board.grid[current_row][col_num].is_a?(NullPiece)
        moves << [current_row, col_num]
      else
        break
      end
    end

    moves
  end

  def get_diagonal_moves
    current_row, current_column = self.position
    diag_moves = [ [-1, 1], [-1, -1], [1, -1], [1, 1] ]
    possible_moves = []

    diag_moves.each do |diag_move|
      row_num, col_num = current_row, current_column
      while row_num < 8 && col_num < 8
        row_num += diag_move.first
        col_num += diag_move.last
        if board.grid[row_num][col_num].is_a?(NullPiece)
          possible_moves << [row_num, col_num] if row_num >= 0 && col_num >= 0
        else
          break
        end
      end
    end
    possible_moves
  end

end

class Bishop < SlidingPiece

  #filters for ONLY diagonal slides
  def move_dirs(move)
    current_row, current_col = self.position
    #NOT a diagnol move if the row or column is the same as current row/column
    return false if move.first == current_row || move.last == current_col
    true
  end

end

class Rook < SlidingPiece

  def move_dirs(move)
    #filters for only horitizon and vertical slides
    current_row, current_col = self.position

    #NOT a vertical/horizontal move if the row or column is NOT the same as current row/column
    return false unless (move.first == current_row || move.last == current_col)
    true
  end

  def in_the_way?(move)
    return false unless move.nil?

  end

end

class Queen < SlidingPiece

  #slides in ALL directions
  def move_dirs(move)
    true
  end

end


#############################
#      STEPPING PIECES      #
#############################

class SteppingPiece < Piece
  def moves

  end
end

class Knight < SteppingPiece
  #moves in "L" shape
  def moves
    paths = []
    knight_moves = [
                    [2, -1],
                    [2, 1],
                    [-2, 1],
                    [-2, -1],
                    [1, 2],
                    [1, -2],
                    [-1, 2],
                    [-1, -2]
                  ]
    current_row, current_column = self.position

    knight_moves.each do |move|
      path = []
      row_ops = move.first
      col_ops = move.last
      row_factor = (row_ops <=> 0)
      col_factor = (col_ops <=> 0)
      row_num = current_row
      col_num = current_column

      (row_ops.abs).times do
        row_num += row_factor
        next if row_num < 0
        path << [row_num, col_num] if row_num.between?(0, 7) && col_num.between?(0, 7)
      end

      (col_ops.abs).times do
        col_num += col_factor
        next if col_num < 0
        path << [row_num, col_num] if col_num.between?(0, 7) && row_num.between?(0, 7)
      end

      # paths << path

      paths << path.last if path.length == 3 && path.all? do |position|
        board.grid[position[0]][position[1]].is_a?(NullPiece)
      end

    end
    paths
  end

end

class King < SteppingPiece
  #moves one step in any direction
  def moves
    current_row, current_column = self.position
    possible_moves = []

    king_moves = [
                  [1,1],
                  [1,-1],
                  [1, 0],
                  [0, 1],
                  [0, -1],
                  [-1, 0],
                  [-1, -1],
                  [-1, 1]
                ]

    king_moves.each do |move|
      next_row = current_row + move.first
      next_col = current_column + move.last
      if next_row.between?(0, 7) && next_col.between?(0, 7)
        if board.grid[next_row][next_col].is_a?(NullPiece)
          possible_moves << [next_row, next_col]
        end
      end
    end
    possible_moves
  end
end








class NullPiece
  def present?
    false
  end

  def to_s
    "   "
  end
end

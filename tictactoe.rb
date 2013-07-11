class Game
attr_accessor :slots, :player, :mac, :strategic_slots, :turn, :round, :game_over
attr_reader   :possible_wins

  def initialize # setting up the things needed to play
    @slots = {
      'a1' => " ", 'a2' => " ", 'a3' => " ",
      'b1' => " ", 'b2' => " ", 'b3' => " ",
      'c1' => " ", 'c2' => " ", 'c3' => " "
    }

    @strategic_slots = %w(a1 a3 b2 c1 c3)

    @possible_wins = [
      %w(a1 a2 a3),
      %w(b1 b2 b3),
      %w(c1 c2 c3),
      %w(a1 b1 c1),
      %w(a2 b2 c2),
      %w(a3 b3 c3),
      %w(a1 b2 c3),
      %w(c1 b2 a3)
    ]
    @round = 1
    @game_over = false
    @turn = ""
    # Were I to continue to refactor, I might make the players their own classes
    @player = Hash.new
    @mac = Hash.new
    @mac[:name] = 'Mac'
  end

  def play
    clear_screen
    puts "What's your name?"
    @player[:name] = gets.chomp
    clear_screen
    @player[:position] = get_positions # ask if the player wants to play X or O
    @player[:position] == 'X' ? @mac[:position] = 'O' : @mac[:position] = 'X'
    @player[:position] == 'X' ? @turn = 'player' : @turn = 'mac'
    clear_screen
    @message = "X goes first"
    while game_over == false && round < 10 # will keep playing until either game is over or no more slots
      if @turn == 'player'
        player_turn
      else
        mac_turn
      end
    end
    clear_screen
    @message = "Draw!" if @round == 10
    draw_board
  end

  def get_positions
    puts "#{@player[:name]}, would you like to play 'X' or 'O'?"
    while true
      response = gets.chomp.upcase
      if response == 'X' || response == 'O'
        return response
        break
      else
        clear_screen
        puts "Please enter either 'X' or 'O'"
      end
    end
  end

  def draw_board # draw the board
    puts @message if @message #space for errors and other messages
    puts ""
    puts "     1   2   3 "
    puts ""
    puts " A   #{@slots['a1']} | #{@slots['a2']} | #{@slots['a3']} "
    puts "    -----------"
    puts " B   #{@slots['b1']} | #{@slots['b2']} | #{@slots['b3']} "
    puts "    -----------"
    puts " C   #{@slots['c1']} | #{@slots['c2']} | #{@slots['c3']} "
    puts ""
  end

  def player_turn
    clear_screen
    draw_board
    puts "Enter the coordinates of the slot you wish to play"
    response = gets.chomp.downcase
    unless slots.keys.include? response # make sure it's a valid space
      bad_move
    end
    filled = slots.map{ |slot,val| val != ' ' ? slot : nil }.compact
    if filled.include? response # make sure the space isn't already occupied
      occupied
    end
    slots[response] = player[:position]
    update_strategic response # update the list of strategic squares
    @turn = 'mac'
    @round += 1
    @message = nil if @message
  end

  def mac_turn
    @turn = 'player'
    clear_screen
    puts "Round #{@round}"
    check_win? @player if round > 4
    player_block = check_two? @player[:position], @possible_wins
    mac_win = check_two? @mac[:position], @possible_wins
    #--------------------
    # this section contains the key AI for the computer
      if round < 3 && slots['b2'] == " "
        mac_move 'b2'
      elsif @player[:position] == 'O' && mac_win # Can the computer win?
        mac_move mac_win
      elsif @mac[:position] == 'X' && player_block # Can the player win?
        mac_move player_block
      elsif @player[:position] == 'X' && mac_win # Can the computer win?
        mac_move mac_win
      elsif @mac[:position] == 'O' && player_block # Can the player win?
        mac_move player_block
        # check for the corner maneuver if the player is X
      elsif @round == 4 &&
        ((@slots['a1'] == @player[:position] && @slots['c3'] == @player[:position]) ||
         (@slots['a3'] == @player[:position] && @slots['c1'] == @player[:position]))
        mac_move %w(a2 b1 b3 c2).shuffle.first
      elsif strategic_slots.size > 0 # take a corner square if nothing else
        mac_move strategic_slots.shuffle.first
      else # otherwise pick any empty square
        empty = slots.map{ |slot,val| val == ' ' ? slot : nil }.compact
        mac_move empty.shuffle.first
      end
    # ---------------------
    check_win? @mac if round > 4
    @round += 1
  end

  def mac_move(move)
    slots[move] = @mac[:position]
    update_strategic move
  end

  def  bad_move
    @message = "That is not a valid slot. Please try again."
    player_turn
  end

  def  occupied
    @message = "That slot is occupied. Please try again."
    player_turn
  end

def check_two?(player_marker, possible_wins)
  possible_wins.each do |choice|
    remaining = choice.reject { |slot| @slots[slot] == player_marker }
    if remaining.length == 1 && @slots[remaining.first] == ' '
      return remaining.first
    end
  end
  return false
end

  def check_win?(player)
    if anyone_win?(player[:position])
      @game_over = true
      @message = "#{player[:name]} wins!"
    end
  end

  def anyone_win?(marker)
    filled = slots.map{ |slot,val| val == marker ? slot : nil }.compact
    @possible_wins.each do |choice|
      counter = 0
      choice.each do |w|
        if filled.include? w
          counter += 1
       end
      end
      if counter == 3
        @game_over = true
        return true
        break
      end
    end
    return false
  end

  def update_strategic(move)
    strategic_slots.delete move if strategic_slots.include? move
  end
end

def clear_screen
  puts "\e[H\e[2J"
end

ttt = Game.new
ttt.play


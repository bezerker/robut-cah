# encoding: UTF-8
require 'robut'
require 'yaml'

# A plugin to play Cards Against Humanity
class Robut::Plugin::Cah
  include Robut::Plugin

  def random
    new_game = ::Cah::Game.new
    black_card = new_game.black_deck.draw(1).first
    blank_count = black_card.scan("(blank)").count
    if blank_count > 0
      white_cards = new_game.white_deck.draw(blank_count)
      response = black_card.gsub("(blank)", "%s") % white_cards
    else
      white_card = new_game.white_deck.draw(1).first
      response = "#{black_card} #{white_card}"
    end

    reply(response)
  end

  def handle(time, sender_nick, message)
    words = words(message)

    if words.first == 'cah'
      phrase = words.drop(1).join(' ')

      # players: list current players
      if phrase =~ /^players/i
        if game.players.count == 0
          reply("Nobody is currently playing.")
        else
          reply("Current players: #{game.players.collect(&:username).join(', ')}")
        end
      
      # scores: list the current scores
      elsif phrase =~ /^scores/i
        #score_strings = game.scores.map {|k,v| "#{k}: #{v}"}
        #reply("Scores:\n#{score_strings.join("\n")}")

      # join: join the current game
      elsif phrase =~ /^join/i
        game.join(sender_nick)
        reply("#{sender_nick} has joined the game.")

      # leave: Leave the current game
      elsif phrase =~ /^leave/i
        if playing?(sender_nick)
          game.leave(sender_nick)
          reply("#{sender_nick} has left the game.")
        end
      # reset: Fully reset the game state
      elsif phrase =~ /^reset/i
        if playing?(sender_nick)
          reset_game
        end

      # cards: list your current hand
      elsif phrase =~ /^cards/i
        if playing?(sender_nick)
          player = game.find_player_by_username(sender_nick)
          card_list = []
          player.hand.each_with_index do |card, index|
            card_list << "#{index}: #{card}"
          end
          reply("Your cards:\n#{card_list.join("\n")}")
        end

      # next round: Start the next round
      elsif phrase =~ /^start/i || phrase =~ /^next round/i
        if playing?(sender_nick)
          start_game
        end

      # play 0-n: play a card
      elsif phrase =~ /^play ([0-9]+)/i
        selection = $1
        play_card(sender_nick, selection.to_i)

      # reveal: czar may reveal the played cards to select a winner
      elsif phrase =~ /reveal/i
        if started? && playing?(sender_nick)
          player = game.find_player_by_username(sender_nick)
          if player.czar?
            reply("Played cards:\n#{game.played_cards.join("\n")}")
          else
            reply("Only the card czar (#{game.czar}) may reveal the played cards.")
          end
        end

      # choose 0-n: choose a winning card (if you are the czar)
      elsif phrase =~ /^choose ([0-9]+)/i
        if started?
          chosen = $1
          choose_winning_card(sender_nick, chosen.to_i)
        end
      end
    end
  rescue ::Cah::GameplayException => e
    reply(e.message)
  end

  def play_card(sender_nick, selection)
    if selection >= 0 && selection <= 9
      if playing?(sender_nick)
        player = game.find_player_by_username(sender_nick)
        player.play_card(player.hand[selection])
        reply("#{sender_nick} played a card.", :room) # TODO: This should go to the room.
      end
    else
      reply("Invalid card selection. Choose 0-9.")
    end
  end

  def choose_winning_card(sender_nick, selection)
    if selection >= 0 && selection <= 9
      player = game.find_player_by_username(sender_nick)
      chosen_card = game.played_cards[selection]
      winner = player.choose_winner(chosen_card)

      # TODO: Add handling for game over state
      
      response = ["#{winner.username} won the round!"]
      response << "#{game.czar} is now the card czar."
      response << "The black card is: #{game.black_card}"

      reply(response.join("\n"))
    else
      reply("Invalid card selection. Choose 0-9.")
    end
  end

  def start_game
    game.start
    response = []
    response << "#{game.czar} is now the card czar."
    response << "The black card is: #{game.black_card}"
    reply(response.join("\n"))
  end

  def next_round
    game.next_round
    response = []
    response << "#{game.czar} is now the card czar."
    response << "The black card is: #{game.black_card}"
    reply(response.join("\n"))
  end

  def playing?(sender_nick)
    return true if game.find_player_by_username(sender_nick)
    reply("#{sender_nick} You aren't currently playing.")
    false
  end

  def started?
    return true if game.started?
    reply("The game has not started yet. Be patient!")
    false
  end

  def game
    store["cah_game"] ||= ::Cah::Game.new
  end

  def reset_game
    store["cah_game"] = ::Cah::Game.new
    reply("CAH game has been fully reset.")
    reply("Nobody is currently playing.")
  end
end
# encoding: UTF-8
require 'robut'
require 'yaml'

# A plugin to play Cards Against Humanity
class Robut::Plugin::Cah
  include Robut::Plugin

  def handle(time, sender_nick, message)
    words = words(message)

    if words.first == 'cah'
      phrase = words.drop(1).join(' ')

      # players: list current players
      if phrase =~ /^players/i
        if game.players.keys.count == 0
          reply("Nobody is currently playing.")
        else
          reply("Current players: #{game.players.keys.join(', ')}")
        end
      
      # scores: list the current scores
      elsif phrase =~ /^scores/i
        score_strings = game.scores.map {|k,v| "#{k}: #{v}"}
        reply("Scores:\n#{score_strings.join("\n")}")

      # join: join the current game
      elsif phrase =~ /^join/i
        if game.players[sender_nick]
          reply("#{sender_nick} You are already playing the game.")
        else
          game.join(sender_nick)
          reply("#{sender_nick} has joined the game.")
        end

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
          player = game.players[sender_nick]
          reply("Your cards:\n#{player.cards.join("\n")}")
        end

      # next round: Start the next round
      elsif phrase =~ /^start/i || phrase =~ /^next round/i
        if playing?(sender_nick)
          next_round
        end

      # play 0-n: play a card
      elsif phrase =~ /^play ([0-9]+)/i
        selection = $1
        play_card(sender_nick, selection.to_i)

      # reveal: czar may reveal the played cards to select a winner
      elsif phrase =~ /reveal/i
        if game.czar?(sender_nick)
          reply("Played cards:\n#{game.played_cards.values.join("\n")}")
        else
          reply("Only the card czar (#{game.czar}) may reveal the played cards.")
        end

      # choose 0-n: choose a winning card (if you are the czar)
      elsif phrase =~ /^choose ([0-9]+)/i
        chosen = $1
        choose_winning_card(sender_nick, chosen.to_i)
      end
    end
  end

  def play_card(sender_nick, selection)
    if playing?(sender_nick)
      if selection >= 0 && selection <= 9
        player = game.players[sender_nick]
        game.play_card(sender_nick, player.cards[selection])
        reply("#{sender_nick} played a card.")
      else
        reply("Invalid card selection. Choose 0-9.")
      end
    end
  end

  def choose_winning_card(sender_nick, selection)
    if game.czar?(sender_nick)
      if selection >= 0 && selection <= 9
        chosen_card = game.played_cards.values[selection]
        winner = game.choose_winner(chosen_card)

        # TODO: Add handling for game over state
        
        response = ["#{winner.username} won the round!"]
        response << "#{game.czar} is now the card czar."
        response << "The black card is: #{game.black_card}"

        reply(response.join("\n"))
      else
        reply("Invalid card selection. Choose 0-9.")
      end
    else
      reply("Only the card czar (#{game.czar}) may choose the winning card.")
    end
  end

  def next_round
    game.next_round
    response = []
    response << "#{game.czar} is now the card czar."
    response << "The black card is: #{game.black_card}"
    reply(response.join("\n"))
  end

  def playing?(sender_nick)
    return true if game.players[sender_nick]
    reply("#{sender_nick} You aren't currently playing.")
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
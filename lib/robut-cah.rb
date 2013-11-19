# encoding: UTF-8
require 'robut'
require 'yaml'

# A plugin to play Cards Against Humanity
class Robut::Plugin::Cah
  include Robut::Plugin

  def handle(time, sender_nick, message)
    words = words(message)

    if sent_to_me?(message) && words.first == 'cah'
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
        reply("Scores:\n#{score_strings.join('\n')}")

      # join: join the current game
      elsif phrase =~ /^join/i
        game.join(sender_nick)
        reply("#{sender_nick} has joined the game.")

      # leave: Leave the current game
      elsif phrase =~ /^leave/i
        if game.leave(sender_nick)
          reply("#{sender_nick} has left the game.")
        else
          reply("#{sender_nick} You aren't currently playing.")
        end

      # reset: Fully reset the game state
      elsif phrase =~ /^reset/i
        reset_game

      # cards: list your current hand
      elsif phrase =~ /^cards/i
        if player = game.players[sender_nick]
          reply("Your cards:\n#{player.cards.join('\n')}")
        else
          reply("#{sender_nick} You aren't currently playing.")
        end
      
      # next round: Start the next round
      elsif phrase =~ /^next round/i
        game.next_round
        reply("#{game.czar} says: #{game.black_card.first}")

      # play 0-n: play a card
      elsif phrase =~ /^play ([0-9]+)/i
        selection = $1
        if game.players[sender_nick]
          # TODO: Play the card
        else
          reply("#{sender_nick} You aren't currently playing.")
        end

      # reveal: czar may reveal the played cards to select a winner
      elsif phrase =~ /reveal/i
        if game.czar?(sender_nick)
          # TODO: Allow czar to reveal all the played cards
        end

      # choose 0-n: choose a winning card (if you are the czar)
      elsif phrase =~ /^choose ([0-9]+)/i
        chosen = $1
        if game.czar?(sender_nick)
          winner = game.choose_winner(chosen)
          reply("#{winner.username} won the round!")

          if game.over?
            reply("The game is over!")
            #reply("Scores:\n#{game.scores.join('\n')}")
            reset_game
          else
            game.next_round
            reply("#{game.czar} says: #{game.black_card.phrase}")
          end
        end
      end
    end
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
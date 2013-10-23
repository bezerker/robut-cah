module Robut
  module Cah
    class Game
      CARDS_IN_HAND = 10

      attr_accessor :players, :started, :white_deck, :black_deck, :black_card, :discard_pile, :played_cards, :czar_order

      def initialize
        started = Time.now
        @players = {}
        @discard_pile = []
        @played_cards = {}
        @czar_order = []

        @white_deck = Deck.new(File.expand_path("../../../../cards/white.yml", __FILE__))
        @black_deck = Deck.new(File.expand_path("../../../../cards/black.yml", __FILE__))
      end

      def join(username)
        if !players.keys.include?(username)
          new_player = Player.new(:username => username, :cards => white_deck.draw(CARDS_IN_HAND))
          players[username] = new_player
          czar_order << username
        end
      end

      def leave(username)
        if leaving_player = players[username]
          black_deck.discard(leaving_player.won_cards)
          white_deck.discard(leaving_player.cards)
          players.delete(username)
        end
      end

      def scores
        players.values.map {|player| "#{player.username}: #{player.score}"}
      end

      def czar?(username)
        czar == username
      end

      def czar
        czar_order.first
      end

      def play_card(username, card_id)
        if player = players[username]
          if player.play_card(card_id)
            played_cards[username] = card_id
          end
        end
      end

      # Award black card to the chosen winner
      def choose_winner(card)
        winner = played_cards.invert[card]
        winner.award_card(black_card)
        winner
      end

      def next_round
        # Discard played white cards
        @discard_pile += played_cards.values
        @played_cards = {}

        # Draw new white cards
        players.values.each do |player|
          if player.cards.count < CARDS_IN_HAND
            player.cards += white_deck.shift(CARDS_IN_HAND - player.cards.count)
          end
        end

        # Select new card czar
        czar_order.rotate!

        # Draw next black card
        @black_card = black_deck.shift unless over?
      end

      def over?
        black_deck.count == 0
      end

      protected

      def white_deck
        if @white_deck.count < 10
          @white_deck += discard_pile.shuffle
          discard_pile = []
        end
        @white_deck
      end
    end
  end
end
module Robut
  module Cah
    class Player
      attr_accessor :username, :cards, :won_cards

      def initialize(params)
        @username = params[:username]
        @cards = params[:cards]
        @won_cards = []
      end

      def score
        won_cards.count
      end

      def play_card(card)
        cards.delete(card)
      end

      def award_card(black_card)
        won_cards += black_card
      end
    end
  end
end
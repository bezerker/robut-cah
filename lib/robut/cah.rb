module Robut
  module Cah
    CARDS_IN_HAND = 10

    autoload :Card, 'robut/cah/card'
    autoload :Deck, 'robut/cah/deck'
    autoload :Game, 'robut/cah/game'
    autoload :Player, 'robut/cah/player'
    autoload :Plugin, 'robut/cah/plugin'
  end
end
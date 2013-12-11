require 'test_helper'

class Robut::Plugin::CahTest < MiniTest::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    @plugin = Robut::Plugin::Cah.new(@presence)
  end

  def teardown
    @plugin.reset_game
  end

  def test_join_and_leave_a_game
    @plugin.handle(Time.now, "@john", "cah join")
    assert_equal "@john has joined the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah players")
    assert_equal "Current players: @john", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@mark", "cah join")
    assert_equal "@mark has joined the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah players")
    assert_equal "Current players: @john, @mark", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah leave")
    assert_equal "@john has left the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah players")
    assert_equal "Current players: @mark", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@mark", "cah leave")
    assert_equal "@mark has left the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah players")
    assert_equal "Nobody is currently playing.", @plugin.reply_to.replies.last
  end

  def test_cannot_leave_a_game_without_joining
    @plugin.handle(Time.now, "@john", "cah join")
    assert_equal "@john has joined the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah start")
    assert_equal "@john is now the card czar.", @plugin.reply_to.replies.last.split("\n")[0]

    @plugin.handle(Time.now, "@mark", "cah leave")
    assert_equal "@mark You aren't currently playing.", @plugin.reply_to.replies.last
  end

  def test_cannot_play_a_card_without_joining
    @plugin.handle(Time.now, "@john", "cah join")
    assert_equal "@john has joined the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah start")
    assert_equal "@john is now the card czar.", @plugin.reply_to.replies.last.split("\n")[0]

    @plugin.handle(Time.now, "@mark", "cah play 0")
    assert_equal "@mark You aren't currently playing.", @plugin.reply_to.replies.last
  end

  def test_cannot_play_a_card_before_game_has_started
    @plugin.handle(Time.now, "@john", "cah join")
    assert_equal "@john has joined the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah play 1")
    assert_equal "The game has not started yet. Be patient!", @plugin.reply_to.replies.last
  end

  def test_lists_scores
    @plugin.handle(Time.now, "@john", "cah scores")
    assert_equal ["Scores:\n"], @plugin.reply_to.replies
  end

  def test_can_start_and_play_a_game
    @plugin.handle(Time.now, "@john", "cah join")
    assert_equal "@john has joined the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@mark", "cah join")
    assert_equal "@mark has joined the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah start")
    assert_equal "@john is now the card czar.", @plugin.reply_to.replies.last.split("\n")[0]
    
    @plugin.handle(Time.now, "@mark", "cah cards")
    assert_equal "Your cards:", @plugin.reply_to.replies.last.split("\n").first

    @plugin.handle(Time.now, "@mark", "cah play 0")
    assert_equal "@mark played a card.", @plugin.reply_to.replies.last

    # czar may not play a card
    @plugin.handle(Time.now, "@john", "cah play 0")
    assert_equal "The card czar may not play a card.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "cah reveal")
    assert_equal "Played cards:", @plugin.reply_to.replies.last.split("\n").first

    @plugin.handle(Time.now, "@john", "cah choose 0")
    assert_equal "@mark won the round!", @plugin.reply_to.replies.last.split("\n")[0]
    assert_equal "@mark is now the card czar.", @plugin.reply_to.replies.last.split("\n")[1]

    @plugin.handle(Time.now, "@john", "cah scores")
    assert_equal "Scores:\n@john: 0\n@mark: 1", @plugin.reply_to.replies.last
  end

  def test_random_returns_value
    before_count = @plugin.reply_to.replies.count
    @plugin.random
    assert @plugin.reply_to.replies.last
    assert before_count + 1, @plugin.reply_to.replies.count
  end
  
end

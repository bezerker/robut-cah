require 'test_helper'
require 'robut/plugin/cah'

class Robut::Plugin::CahTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    @plugin = Robut::Plugin::Cah.new(@presence)
  end

  def teardown
    @plugin.reset_game
  end

  def test_join_and_leave_a_game
    @plugin.handle(Time.now, "@john", "@robut cah join")
    assert_equal ["@john has joined the game."], @plugin.reply_to.replies

    @plugin.handle(Time.now, "@john", "@robut cah players")
    assert_equal "Current players: @john", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "@robut cah next round")
    assert_equal "@john says: ...", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "@robut cah scores")
    assert_equal "Scores:\n@john: 0", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "@robut cah leave")
    assert_equal "@john has left the game.", @plugin.reply_to.replies.last

    @plugin.handle(Time.now, "@john", "@robut cah players")
    assert_equal "Nobody is currently playing.", @plugin.reply_to.replies.last
  end

  def test_leave_a_game_without_joining
    @plugin.handle(Time.now, "@john", "@robut cah leave")
    assert_equal ["@john You aren't currently playing."], @plugin.reply_to.replies
  end

  def test_lists_scores
    @plugin.handle(Time.now, "@john", "@robut cah scores")
    assert_equal ["Scores:\n"], @plugin.reply_to.replies
  end

  def test_lists_players
    @plugin.handle(Time.now, "@john", "@robut cah players")
    assert_equal ["Nobody is currently playing."], @plugin.reply_to.replies
  end

  def test_play_a_card
    @plugin.handle(Time.now, "@john", "@robut cah play 0")
  end
  
end

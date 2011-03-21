# simple chat
require 'rubygems'
require 'bud'
require 'chat_protocol'

class ChatClient
  include Bud
  include ChatProtocol

  def initialize(nick, server, opts)
    @nick = nick
    @server = server
    super opts
  end

  # send connection request to server on startup
  bootstrap do
    connect <~ [[@server, [ip_port, @nick]]]
  end

  bloom :chatter do
    # send mcast requests to server
    mcast <~ stdio do |s|
      [@server, [ip_port, @nick, Time.new.strftime("%I:%M.%S"), s.line]]
    end
    # pretty-print mcast msgs from server on terminal
    stdio <~ mcast do |m|
      [left_right_align(m.val[1].to_s + ": " \
                        + (m.val[3].to_s || ''),
                        "(" + m.val[2].to_s + ")")]
    end
  end

  # format chat messages with timestamp on the right of the screen
  def left_right_align(x, y)
    return x + " "*[66 - x.length,2].max + y
  end
end

program = ChatClient.new(ARGV[0], ARGV[1], {:read_stdin => true})
program.run
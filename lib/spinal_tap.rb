require 'spinal_tap/version'
require 'spinal_tap/server'
require 'spinal_tap/cmd_line'
require 'spinal_tap/history'
require 'spinal_tap/client_helpers'

module SpinalTap
  def self.start(params = {})
    return false if @server

    @server = SpinalTap::Server.new(params)
    @server.start
  end

  def self.stop
    return false unless @server

    result = @server.stop
    @server = nil

    result
  end

  def self.server
    @server
  end
end

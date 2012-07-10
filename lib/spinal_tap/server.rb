require 'socket'

module SpinalTap

  class Server
    def self.start(params = {})
      return false if @server

      @server = SpinalTap::Server.new(params).start

      true
    end

    def self.stop
      return false unless @server

      @server.stop
      @server = nil

      true
    end

    def initialize(params = {})
      @host = params[:host] || '127.0.0.1'
      @port = params[:port] || 9000

      @run = false
    end

    def start
      @run = true

      @server_sock = TCPServer.new(@host, @port)

      Thread.new do
        while true
          Thread.new(@server_sock.accept) do |client|
            client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
            client.extend(SpinalTap::ClientHelpers)

            process(client)
          end
        end
      end
    end

    private

    def process(client)
      client.prompt

      while(line = client.gets)
        line.chomp!

        tokens = line.split(' ')
        command = tokens.first

        case command
        when 'help' then exec_help(client)
        when 'eval' then exec_eval(client, tokens[1..-1].join(' '))
        when 'quit'
          client.close
          break
        else
          client.puts('Unknown command')
        end

        client.prompt
      end

      puts 'going to die now'
    end

    def exec_help(client)
      client.puts('Commands: help quit eval')
    end

    def exec_eval(client, code)
      begin
        result = eval(code)
        client.puts(result.to_s)
      rescue Exception => e
        client.puts("#{e.message}\r\n#{e.backtrace.join("\r\n")}")
      end
    end
  end
end

require 'socket'

module SpinalTap

  class Server
    def initialize(params = {})
      @host = params[:host] || '127.0.0.1'
      @port = params[:port] || 9000

      @run = false
      @workers = {}
      @workers_lock = Mutex.new
    end

    def start
      return false if @running

      @running = true

      @listener_thread = Thread.new do
        @server_sock = TCPServer.new(@host, @port)

        while true
          Thread.new(@server_sock.accept) do |client|
            begin
              @workers_lock.synchronize do
                @workers[Thread.current] = client
              end

              client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
              client.extend(SpinalTap::ClientHelpers)

              process(client)
            rescue Exception => e
              puts("WORKER DIED: #{exception_to_s(e)}")
            end
          end
        end
      end

      true
    end

    def stop
      return false unless @running

      Thread.kill(@listener_thread)
      @server_sock.close

      true
    end

    def workers
      @workers_lock.synchronize do
        return @workers.clone
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

    ensure
      client.close unless client.closed?

      @workers_lock.synchronize do
        @workers.delete(Thread.current)
      end
    end

    def exec_help(client)
      client.puts('Commands: help quit eval')
    end

    def exec_eval(client, code)
      begin
        result = eval(code)
        client.puts(result.to_s)
      rescue Exception => e
        client.puts(exception_to_s(e))
      end
    end

    def exception_to_s(e)
      "#{e.message}\r\n#{e.backtrace.join("\r\n")}"
    end
  end
end

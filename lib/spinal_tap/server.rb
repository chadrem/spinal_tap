require 'socket'
require 'debugger'

module SpinalTap

  class Server
    def initialize(params = {})
      @host = params[:host] || '127.0.0.1'
      @port = params[:port] || 9000

      @running = false
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
              register(Thread.current, client)

              client.extend(SpinalTap::ClientHelpers)
              client.setup(self)
              client.process_loop

            rescue Exception => e
              puts("WORKER DIED: #{e.message}\n#{e.backtrace.join("\n")}")
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

    def register(thread, client)
      @workers_lock.synchronize do
        @workers[thread] = client
      end
    end

    def unregister(thread)
      @workers_lock.synchronize do
        @workers.delete(thread)
      end
    end

  end
end

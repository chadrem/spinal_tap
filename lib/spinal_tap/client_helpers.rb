module SpinalTap

  module ClientHelpers
    def setup(server)
      @server = server

      @history = []
      @buffer = ''
      @cursor_pos = 0

      setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

      suppress_go_ahead = [255, 251, 3].pack('C3')
      write(suppress_go_ahead)

      echo = [255, 251, 1].pack('C3')
      write(echo)

      6.times { getc }
    end

    def process_loop
      redraw_cmd_line

      while (line = read_parsed_line)
        command = line[:command]
        args = line[:args]

        write("\r\n")

        case command
        when 'help' then exec_help
        when 'eval' then exec_eval(args.join(' '))
        when 'quit'
          close
          break
        else
          write("Unknown command\r\n")
        end

        redraw_cmd_line
      end
    ensure
      close unless closed?
      @server.unregister(Thread.current)
    end

    def read_parsed_line
      @buffer = ''
      @cursor_pos = 0

      while byte = getbyte
        byte_s = '' << byte

        if byte == 127 # Delete char.
          if @buffer.length > 0
            @buffer = @buffer[0..-2]
            @cursor_pos -= 1
          end
        elsif byte == 27 # Escape char.
          if (byte = getbyte) == 91 # [ char.
            case getbyte
            when 65 # A char - Up arrow.
            when 66 # B char - Down arrow.
            when 67 # C char - Right arrow.
              if @cursor_pos < @buffer.length
                @cursor_pos += 1
              end
            when 68 # D char - Left arrow.
              if @cursor_pos > 0
                @cursor_pos -= 1
              end
            end
          end
        else
          @buffer.insert(@cursor_pos, byte_s)
          @cursor_pos += 1

          redraw_cmd_line

          if @buffer =~ /\r\0$/
            write("\r\n")

            @buffer.gsub!(/\r\0$/, '')

            if @buffer.length > 0
              @history.push(@buffer)
              @history.shift if @history.length > 100

              tokens = @buffer.split(' ')
              command = tokens.first
              args = tokens[1..-1]

              return {:command => command, :args => args}
            else
              redraw_cmd_line
            end
          end
        end
      end
    end

    def redraw_cmd_line
      write("\e[2K\r> #{@buffer}\e[#{@buffer.length - @cursor_pos}D")
    end

    def exec_help
      write("Commands: help quit eval\r\n")
    end

    def exec_eval(code)
      begin
        result = eval(code)
        write("=> #{result.to_s}\r\n")
      rescue Exception => e
        write(exception_to_s(e))
      end
    end

    def exception_to_s(e)
      "#{e.message}\r\n#{e.backtrace.join("\r\n")}"
    end
  end

end

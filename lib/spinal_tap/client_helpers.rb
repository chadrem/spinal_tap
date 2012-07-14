module SpinalTap

  module ClientHelpers
    def setup(server)
      @server = server

      @history = []
      @history_pos = 0

      reset_buffer

      setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

      suppress_go_ahead = [255, 251, 3].pack('C3')
      write(suppress_go_ahead)

      echo = [255, 251, 1].pack('C3')
      write(echo)

      6.times { getc }
    end

    def process_loop
      while (line = read_parsed_line)
        command = line[:command]
        args = line[:args]

        case command
        when 'help' then exec_help
        when 'eval' then exec_eval(args.join(' '))
        when 'quit'
          close
          break
        else
          write("Unknown command\r\n")
        end
      end
    ensure
      close unless closed?
      @server.unregister(Thread.current)
    end

    def reset_buffer
      @buffer = ''
      @cursor_pos = 1
    end

    def read_parsed_line
      reset_buffer
      redraw_cmd_line

      while byte = getbyte
        byte_s = '' << byte

        # Delete Char.
        if byte == 127
          if @buffer.length > 0 && @cursor_pos > 1
            @cursor_pos -= 1
            @buffer.slice!(@cursor_pos - 1)
          end

        # Null Char.
        elsif byte == 0
          next

        # Escape Char.
        elsif byte == 27
          if (byte = getbyte) == 91 # [ Char.
            case getbyte
            when 65 # A Char - Up Arrow.
              if @history_pos > 0
                @history_pos -= 1
                @buffer = @history[@history_pos].to_s
                @cursor_pos = @buffer.length + 1
              end
            when 66 # B Char - Down Arrow.
              if @history_pos < @history.length
                @history_pos += 1
                @buffer = @history[@history_pos].to_s
                @cursor_pos = @buffer.length + 1
              end
            when 67 # C Char - Right Arrow.
              if @cursor_pos < @buffer.length
                @cursor_pos += 1
              end
            when 68 # D Char - Left Arrow.
              if @cursor_pos > 0
                @cursor_pos -= 1
              end
            end
          end

        # Carriage Return Char.
        elsif byte == 13
          write("\r\n")

          tokens = @buffer.split(' ')
          command = tokens.first
          args = tokens[1..-1]

          if @buffer.length > 0
            @history.push(@buffer)
            @history_pos = @history.length
          end

          return {:command => command, :args => args}

        # Normal (letters, numbers, punctuation, etc) Chars.
        elsif byte >= 32 && byte <= 126
          @buffer.insert(@cursor_pos - 1, byte_s)
          @cursor_pos += 1

        # Ignore all other special characters.
        else
        end

        redraw_cmd_line
      end
    end

    def redraw_cmd_line
      write("\e[2K\r>\e[s #{@buffer}\e[u\e[#{@cursor_pos}C")
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

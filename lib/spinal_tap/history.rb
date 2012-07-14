module SpinalTap

  class History
    def initialize
      @history = []
      @history_pos = 0
    end

    def current
      return @history[@history_pos]
    end

    def previous?
      return @history_pos > 0
    end

    def previous
      if previous?
        @history_pos -= 1
        return current
      else
        return false
      end
    end

    def next?
      return @history_pos < @history.length - 1
    end

    def next
      if next?
        @history_pos += 1
        return current
      else
        return false
      end
    end

    def append(cmd_line)
      @history << cmd_line
      @history_pos += 1 unless @history.length == 1

      return true
    end

    def all
      return @history.map { |e| e.clone }
    end
  end

end

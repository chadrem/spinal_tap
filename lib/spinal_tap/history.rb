module SpinalTap

  class History
    MAX_LINES = 100

    def initialize
      @history = ['']
      @history_pos = 0
    end

    def current
      cur = @history[@history_pos]
      cur = cur.clone unless last?

      return cur
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

    def last?
      return @history_pos >= @history.length - 1
    end

    def append(cmd_line)
      @history.pop
      @history << cmd_line.clone
      @history << ''

      trim
      fast_forward

      return true
    end

    def all
      return @history[0..-2].map { |e| e.clone }
    end

    def fast_forward
      @history_pos = @history.length - 1

      return current
    end

    private

    def trim
      while @history.length > MAX_LINES + 1
        @history.shift
      end
    end
  end
end

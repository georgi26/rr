module RR::Parser
  BEGINS=[:def,:class,:module,:if,:else,:elsif,:while]
  END_ = :end

  class StatementParser
    attr_reader :type,:children, :parent
    def initialize(type, parent=nil)
      @type = type
      @children = []
      @parent = parent
    end

    def to_s
      r = "(#{type}"
        children.each do |c|
          r << "\n\t#{c.to_s} "
        end
        r << ")"
    end

    def end
    end
  end

  class DefParser < StatementParser
    def initialize(parent=nil)
      super(:def,parent)
    end

    def end
      nameType = children[0]
      args = [];
      argsStart = false

      for i in 1..children.size
        c = children[i]
        if(children.include? "(")
          argsStart = true
        end
        if(argsStart)
          args << c
        end
        if(children.include? ")")
          argsStart  = false
          break
        end
      end
    end
  end


  class Expression
    attr_reader :text
    def initialize(text)
      @text = text
    end

    def to_s
      @text
    end
  end



  class FileParser
    def initialize(file)
      if(file.is_a? File)
          @text = file.read
      elsif (file.is_a? String)
          @text = file
      end
    end

    def createStatementParser(st,parent)
      new = nil
        case st
        when :def
          new = DefParser.new(parent)
        else
          new = StatementParser.new(st,parent)
        end
        new
    end
    def parse
      @ws_tokens = @text.split(/\s/)
      current = StatementParser.new(:begin)
      not_ended = [current]
      @ws_tokens.each do |t|
        st = t.to_sym
        if(BEGINS.include? st)

            new = createStatementParser(st,current)
            current.children << new
            not_ended << new
            current = new
        elsif t.to_sym == END_
            ended = not_ended.pop
            ended.end
            current = not_ended.last
        else
            current.children << Expression.new(t)
        end
      end
      current
    end
  end
end

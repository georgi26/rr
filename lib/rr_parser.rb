module RR::Parser
  BEGINS=[:def,:class,:module,:if,:else,:elsif,:while]
  END_ = :end

  class Statement
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
  end

  class DefStatement < Statement
    def initialize(parent=nil)
      super(:def,parent)
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

    def createStatement(st,parent)
      new = nil
        case st
        when :def
          new = DefStatement.new(parent)
        else
          new = Statement.new(st,parent)
        end
        new
    end
    def parse
      @ws_tokens = @text.split(/\s/)
      current = Statement.new(:begin)
      not_ended = [current]
      @ws_tokens.each do |t|
        st = t.to_sym
        if(BEGINS.include? st)

            new = createStatement(st,current)
            current.children << new
            not_ended << new
            current = new
        elsif t.to_sym == END_
            ended = not_ended.pop
            current = not_ended.last
        else
            current.children << Expression.new(t)
        end
      end
      current
    end
  end
end

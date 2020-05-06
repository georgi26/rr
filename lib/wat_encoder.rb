module RR
  module Encoder
    class Code
      attr_reader :ruby , :code
    end

    class WatEncoder
      def initialize()
        @beginWat = "(module "
        @wat = ""
        @endWat = ")"
        @data=""
      end

      def to_wat()
        @beginWat<<@wat<<@endWat
      end

      def encode(sexpr)
          case sexpr.type
          when :def
            encodeFunction(sexpr)
          when :begin
            sexpr.children.each do |sx|
              encode(sx)
            end
          when :class

          when :module

          end
      end

      def encodeFunction(method)
          name = method.children[0]
          params = encodeParams(method.children[1])
          @wat << ("\n(func $#{name}")
          @wat << params << " (result i32)\n"
          @wat << encodeCode(method.children[2])
          @wat << "\n)\n"
      end

      def encodeParams(sexpr)
        result = ""
        sexpr.children.each do |a|
          result << "(param $#{a.children[0]} i32)"
        end
        result
      end

      def encodeCode(sexpr)
        result = ""
        case sexpr.type
        when :send
          result << encodeSend(sexpr)
        end
        result
      end

      def encodeSend(sexpr)
        result = ""
        name = ""
        sexpr.children.each do |ex|
          if ex.respond_to? :type
            case ex.type
            when :lvar
              result << "local.get $#{ex.children[0]}\n"
            else
              puts "Does not handle sexpression type #{ex.type}"
            end
          else
            name = ex
          end
        end
        result << "call $#{name}"
        result
      end


    end

    module CODES
      CLASS="c"
      MODULE="m"
      OBJECT="o"
      END_ = "e"
      STRING = "s"
      FUNCTION = "f"
    end

  end
end

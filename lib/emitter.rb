module RR
  module WASM

    class Opcode
      attr_reader :hex , :wat

      def initialize(wat,hex)
          @wat= wat
          @hex= hex
      end
    end

    #https://webassembly.github.io/spec/core/binary/modules.html#sections
    module SECTION
      CUSTOM = 0
      TYPE = 1
      IMPORT = 2
      FUNC = 3
      TABLE = 4
      MEMORY = 5
      GLOBAL = 6
      EXPORT = 7
      START = 8
      ELEMENT = 9
      CODE = 10
      DATA = 11
    end

    #https://webassembly.github.io/spec/core/binary/types.html
    module VALTYPE
      I32 = Opcode.new("i32",0x7F)
      F32 = Opcode.new("f32",0x7D)
      I64 = Opcode.new("i64",0x7E)
      F64 = Opcode.new("f64",0x7C)
      FUNCREF = Opcode.new("funcref",0x70)
    end

    #https://webassembly.github.io/spec/core/binary/types.html#binary-blocktype
    # this is ResultType
    module BLOCK_TYPE
      VOID = 0x40
    end

    # https://webassembly.github.io/spec/core/binary/instructions.html
    module OPCODES
      BLOCK = Opcode.new("block",0x02)
      LOOP = Opcode.new("loop",0x03)
      IF = Opcode.new("if",0x04)
      BR = Opcode.new("br",0x0C)
      BR_IF = Opcode.new("br_if",0x0D)
      END_ = Opcode.new("end",0x0b)
      BR_TABLE = Opcode.new("br_table",0x0E)
      RETURN = Opcode.new("return",0x0F)
      CALL = Opcode.new("call",0x10)
      CALL_INDIRECT = Opcode.new("call_indirect",0x11)
      DROP =  Opcode.new("drop",0x1A)
      SELECT = Opcode.new("select",0x1B)
      GET_LOCAL = Opcode.new("local.get",0x20)
      SET_LOCAL = Opcode.new("local.set",0x21)
      TEE_LOCAL = Opcode.new("local.tee",0x22)
      GET_GLOBAL = Opcode.new("global.get",0x23)
      SET_GLOBAL = Opcode.new("global.set",0x24)
      I32_LOAD = Opcode.new("i32.load",0x28)
      I64_LOAD = Opcode.new("i64.load",0x29)
      F32_LOAD = Opcode.new("f32.load",0x2A)
      F64_LOAD = Opcode.new("f64.load",0x2B)
      I32_LOAD8_S = Opcode.new("i32.load8_s",0x2C)
      I32_LOAD8_u = Opcode.new("i32.load8_u",0x2D)
      I32_LOAD16_S = Opcode.new("i32.load16_s",0x2E)
      I32_LOAD16_U = Opcode.new("i32.load16_u",0x2F)
      I64_LOAD8_S = Opcode.new("i64.load8_s",0x30)
      I64_LOAD8_U = Opcode.new("i64.load8_u",0x31)
      I64_LOAD16_S = Opcode.new("i64.load16_s",0x32)
      I64_LOAD16_U = Opcode.new("i64.load16_u",0x33)
      I64_LOAD32_S = Opcode.new("i64.load32_s",0x34)
      I64_LOAD32_U = Opcode.new("i64.load32_u",0x35)
      I32_STORE =  Opcode.new("i32.store",0x36)
      I64_STORE =  Opcode.new("i64.store",0x37)
      F32_STORE =  Opcode.new("f32.store",0x38)
      F64_STORE =  Opcode.new("f64.store",0x39)
      I32_STORE8 =  Opcode.new("i32.store8",0x3A)
      I32_STORE16 =  Opcode.new("i32.store16",0x3B)
      I64_STORE8 =  Opcode.new("i64.store8",0x3C)
      I64_STORE16 =  Opcode.new("i64.store16",0x3D)
      I64_STORE32 =  Opcode.new("i64.store32",0x3E)
      MEMORY_SIZE = Opcode.new("memory.size",0x3F)
      MEMORY_GROW = Opcode.new("memory.grow",0x40)
      I32_CONST = Opcode.new("i32.const",0x41)
      I64_CONST = Opcode.new("i64.const",0x42)
      F32_CONST = Opcode.new("f32.const",0x43)
      F64_CONST = Opcode.new("f64.const",0x44)
      I32_EQZ = Opcode.new("i32.eqz",0x45)
      I32_EQ = Opcode.new("i32.eq",0x5b)


      F32_LT = 0x5d
      F32_GT = 0x5e
      I32_AND = 0x71
      F32_ADD = 0x92
      F32_SUB = 0x93
      F32_MUL = 0x94
      F32_DIV = 0x95
      I32_TRUNC_F32_S = 0xa8
    end

    # http://webassembly.github.io/spec/core/binary/modules.html#export-section
    module EXPORT_TYPE
      FUNC = 0x00
      TABLE = 0x01
      MEM = 0x02
      GLOBAL = 0x03
    end

    # http://webassembly.github.io/spec/core/binary/types.html#function-types
    FUNCTION_TYPE = 0x60;

    EMPTY_ARRAY = 0x0;

    # https://webassembly.github.io/spec/core/binary/modules.html#binary-module
    MAGIC_MODULE_HEADER = [0x00, 0x61, 0x73, 0x6d];
    MODULEVERSION = [0x01, 0x00, 0x00, 0x00];

    def self.unsignedLEB128 (n)
       buffer = [];
       loop do
         byte = n & 0x7f;
         n >>= 7;
         if (n != 0)
           byte |= 0x80;
         end
         buffer.push(byte);
         if(n == 0)
           break
         end
       end
       return buffer;
    end

    def self.encodeVector(array)
      [
        *unsignedLEB128(array.length),
        *(array.flatten)
      ]
    end

    def self.encodeLocal(count , type)
      unless VALTYPE.const_defined?(type)
        raise "Type must be one of the #{VALTYPE.constants}"
      end
      [*unsignedLEB128(count), VALTYPE.const_get(type)]
    end

    def self.createSection(section , data)
      unless SECTION.const_defined?(section)
        raise "Type must be one of the #{SECTION.constants}"
      end
      [SECTION.const_get(section),*encodeVector(data)]
    end

  end

end

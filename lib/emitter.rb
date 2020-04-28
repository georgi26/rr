module RR
  module WASM
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
      I32 = 0x7f
      F32 = 0x7d
      I64 = 0x7E
      F64 = 0x7C
    end

    #https://webassembly.github.io/spec/core/binary/types.html#binary-blocktype
    # this is ResultType
    module BLOCK_TYPE
      VOID = 0x40
    end

    # https://webassembly.github.io/spec/core/binary/instructions.html
    module OPCODES
      BLOCK = 0x02
      LOOP = 0x03
      BR = 0x0c
      BR_IF = 0x0d
      END_ = 0x0b
      CALL = 0x10
      GET_LOCAL = 0x20
      SET_LOCAL = 0x21
      I32_STORE_8 = 0x3a
      I32_CONST = 0x41
      F32_CONST = 0x43
      I32_EQZ = 0x45
      I32_EQ = 0x46
      F32_EQ = 0x5b
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

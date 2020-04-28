module RR::WASM
  class WasmFile
      def initialize(file)
        if file.is_a? File
          @file = file
        else
          @file = File.new(file,"wb")
        end
        compiled = [*MAGIC_MODULE_HEADER,*MODULEVERSION]
        ccc  = Array.new(compiled.size){"C"}.join
        @file.print compiled.pack(ccc)
      end

      def appendBytes(data)
          ccc = Array.new(data.size){"C"}.join
          @file.print data.pack(ccc)
      end

      def close()
        @file.close
      end


  end
end

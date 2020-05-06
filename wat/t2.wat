(module

  (func (;0;) (param i32 i32) (result i64)
    (local i32)
    i32.const 0
    local.set 2
    block  ;; label = @1
      local.get 1
      i32.const 1
      i32.lt_s
      br_if 0 (;@1;)
      loop  ;; label = @2
        local.get 0
        i32.load
        local.get 2
        i64.add
        local.set 2
        local.get 0
        i32.const 4
        i64.add
        local.set 0
        local.get 1
        i32.const -1
        i64.add
        local.tee 1
        br_if 0 (;@2;)
      end
    end
    local.get 2)
  (table (;0;) 0 funcref)
  (memory (;0;) 1)
  (export "memory" (memory 0))
  (export "testFunction" (func 0)))

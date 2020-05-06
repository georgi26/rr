(module
  (func $add (param $lhs i64) (param $rhs i64) (result i64)
    local.get $lhs
    local.get $rhs
    i64.add)
    (func $divide (param $lhs i32) (param $rhs i32) (result i32)
      local.get $lhs
      local.get $rhs
      i32.sub)
      (func $m (result i32)
        i32.const 66666
        i32.load8_s
      )
      (memory (;0;) 1)
      (data (i32.const 66666) "\67\00\00\00\65\00\00\00")
      (export "m" (func $m))
)

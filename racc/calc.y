class Calcp

  prechigh
    nonassoc UMINUS
    left '*' '/'
    left '+' '-'
  preclow

rule

  target: exp
        | /* none */ { result = 0 }
        ;

  exp: exp '+' exp { result += val[2] }
     | exp '-' exp { result -= val[2] }
     | exp '*' exp { result *= val[2] }
     | exp '/' exp { result /= val[2] }
     | '(' exp ')' { result = val[1] }
     | '-' NUMBER  = UMINUS { result = -val[1] }
     | NUMBER
     ;

end

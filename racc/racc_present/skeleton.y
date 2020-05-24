class MyParser
	prechigh
		nonassoc UMINUS
		left '*' '/'
 	preclow
	# token symbols created by the lexer
	token IDENTIFIER INTEGER STRING CHARACTER

rule
	expect 1 # number of expected shift/reduce conflict

	# bogus rule
	target :  /* blank */ { result = nil } ;
end
---- header ----
# stuff that will come before the definition of MyParser
---- inner ----
	# inside the class definition of MyParser
---- footer ----
# stuff that will come after the definition of MyParser


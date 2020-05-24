# Parse C if statements.  Shows shift reduce conflict

class ParseCif

	#prechigh
	#preclow

	token IDENTIFIER

rule

	target
		: statement_list
		;

	statement_list
		: statement
		| statement_list statement { result = val[0,2].join }
		;

	statement
		: '{' statement_list '}' { result = val[0,3].join }
		| if_statement
		| expression ';' { result = val[0,2].join }
		;
	
	if_statement
		: 'if' '(' expression ')' statement
			{ result = "<#{val[2]} implies #{val[4]}>\n" }
		| 'if' '(' expression ')' statement 'else' statement
			{ result = "<#{val[2]} implies #{val[4]} otherwise #{val[6]}>\n" }
		;

	identifier
		: IDENTIFIER
		;

	expression
		: identifier '(' ')' { result = val[0,3].join }
		| identifier
		;

end

---- header ----

require 'ctokenizer'

---- inner ----

	def ParseCif.parse(file_name)
		new.parse(file_name)
	end

	def parse(file_name)
		File.open(file_name) do |f|
			@tokens = CTokenizer::CLexer.new(f.read, file_name)
		end
		do_parse # enter parser
	end


	def next_token
		t = @tokens.shift
		# skip spaces, comments and newlines
		while t[0] == :SPACE or t[0] == :NEWLINE or t[0] == :COMMENT
			t = @tokens.shift
		end
		#puts t.inspect
		t
	end

	def on_error(error_token_id, error_value, value_stack)
		token_name = token_to_str(error_token_id)
		token_name.downcase!
		token = error_value.to_s.inspect

		str = 'parse error on '
		str << token_name << ' ' unless token_name == token
		str << token
		@tokens.error(str)
	end

---- footer ----

puts ParseCif.parse(ARGV[0])


# Copyright (c) 2004 Charles M Mills
# This document is licenced under The MIT Licence.
# THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
# See included LICENCE file.

require 'strscan'

module CTokenizer
	EOF_TOKEN = [false, false].freeze

	module Expression
		NEWLINE = /\r\n|\n\r|\r|\n/

		SPACE_1 = /[\t ]+/
		SPACE_2 = /\\[\t ]*#{NEWLINE}/
		#SPACE = %r(#{SPACE_1}|#{SPACE_2})

		IDENTIFIER = /[a-zA-Z_]\w*/
		
		comment_1 = /\/\*.*?\*\//m
		# scarry comment - bad style - beward of '\' at end of line...
		comment_2 = /\/\/(?:\\[ \t]*#{NEWLINE}|[^\r\n])+/m
		COMMENT = %r(#{comment_1}|#{comment_2})m

		sym_1 = /\+=|\-=|\*=|\/=|%=|\&=|\^=|\|=|<<=|>>=|##|\.\.\./
		sym_2 = /==|!=|<=|>=|->|\&\&|\|\||<<|>>|\+\+|\-\-/
		sym_3 = /<:|:>|<%|%>|%:%:|%:/ # Digraph
		sym_4 = /[\(\)\[\]\{\}\|\&\+\-\/\*%<>\.,=!:;\?\^~#]/
		SYMBOL = %r(#{sym_1}|#{sym_2}|#{sym_3}|#{sym_4})

		CHARACTER = /L?'(?:\\.|[^'])*'/
		STRING = /L?"(?:\\.|[^"])*"/

		f_e = /[eE][-+]?[0-9]+/
		f_s = /[fFlL]/
		flt_1 = /[0-9]+#{f_e}#{f_s}?/
		flt_2 = /[0-9]*\.[0-9]+#{f_e}?#{f_s}?/
		# flt_3 has to be complicated to prevent ambiguities...
		# for example 3...4 => should be '3', '...', '4' not '3.', '..', '4'
		flt_3 = /[0-9]+\.(?:#{f_e}#{f_s}?|#{f_e}?#{f_s}|(?=[^\.])|\Z)/

		i_s = /[uUlL]*/
		int_1 = /0[xX][0-9a-fA-F]+#{i_s}/
		int_2 = /0[0-7]+#{i_s}/
		int_3 = /[0-9]+#{i_s}/
		CONSTANT = %r(#{int_1}|#{int_2}|#{int_3}|#{flt_1}|#{flt_2}|#{flt_3})
	end # Expression

	class Error < StandardError
		def initialize(file, line)
			@file = file
			@line = line
		end
		def to_s
			"#{@file + ':' if @file}#{@line}: #{super}"
		end
	end

	def CTokenizer.error(file, line, msg)
		raise CTokenizer::Error.new(file, line), msg
	end

	def CTokenizer.line_count(str)
		count = str.count("\n")
		count = str.count("\r") if count == 0
		count
	end
	
	def error(msg)
		CTokenizer.error(file, line, msg)
	end
	
	def token_error(token)
		self.error("unrecognized token: #{token}")
	end

	def parse_error(token)
		self.error("parse error on token: #{token}")
	end

	def warning(msg)
		warn "#{file + ':' if file}#{line}: #{msg}"
	end

	def to_a
		ary = []
		until self.empty?
			ary << self.shift
		end
		ary
	end

	def each
		until self.empty?
			yield(self.shift)
		end
		self
	end
	
	def collect
		ary = []
		until self.empty?
			ary << yield(self.shift)
		end
		ary
	end

	class Lexer < StringScanner
		# C Lexer
		include	CTokenizer
		
		def initialize(str, file=nil, line=1)
			str.freeze
			super(str, false) # DO NOT dup str
			@file = file
			@line = line
		end
	
		attr_accessor :file, :line
	
		alias empty? eos?
		alias scan_super scan

		def scan(re)
			if m = scan_super(re)
				@line += CTokenizer.line_count(m)
			end
			m
		end
	
		def shift
			# don't need \A in regexp's cause StringScanner does this automatically.
			# try to put most common tokens first
			t = case
				#when m = scan_super(Expression::SPACE)
				#	@line += CTokenizer.line_count(m)
				#	[:SPACE, m]
				when m = scan_super(Expression::SPACE_1)
					[:SPACE, m]
				when m = scan_super(Expression::IDENTIFIER)
					[:IDENTIFIER, m]
				when m = scan_super(Expression::COMMENT)
					@line += CTokenizer.line_count(m)
					[:COMMENT, m]
				# SYMBOL should come after CONSTANT
				when m = scan_super(Expression::CONSTANT)
					[:CONSTANT, m]
				when m = scan_super(Expression::SYMBOL)
					[:SYMBOL, m]
				when m = scan_super(Expression::NEWLINE)
					#@line += CTokenizer.line_count(m)
					@line += 1
					[:NEWLINE, m]
				when m = scan_super(Expression::STRING)
					[:STRING, m]
				when m = scan_super(Expression::SPACE_2)
					@line += 1
					[:SPACE, m]
				when m = scan_super(Expression::CHARACTER)
					[:CHARACTER, m]
				when eos?
					EOF_TOKEN # end of file, \Z don't work with StringScanner
				else
					[:UNKNOWN, getch]
			end # case
			m.freeze
			t.freeze
		end
	
	end # Lexer

	# provides a way of keeping track of the current scope
	module Scoped
		attr_reader :scope

		def start_of_line?
			@start_line
		end

		def macro?
			@macro
		end

		def process_scope(t)
			t_sym = t.at(0)
			unless t_sym == :SPACE or t_sym == :COMMENT
				if t_sym == :NEWLINE
					@start_line = true
					@macro = false
				else
					unless @macro
						# these tokens are ignored if inside of a macro
						case t.at(1)
							when '#'
								@macro = @start_line
							when '{'
								@scope += 1
							when '}'
								@scope -= 1
						end
					end
					@start_line = false
				end
			end
			t
		end
	end # Scoped

	module Sourced
		attr_reader :source

		def scan(regexp)
			@source.scan(regexp)
		end

		def match?(regexp)
			@source.match?(regexp)
		end

		def post_match
			@source.post_match
		end

		def file
			@source.file
		end
		def file=(val)
			@source.file = val
		end
		def line
			@source.line
		end
		def line=(val)
			@source.line = val
		end

		def shift
			@source.shift
		end

		def empty?
			@source.empty?
		end
	end # Sourced

	# wraps a lexer and uses that to produce new tokens
	class LexerBase
		include	CTokenizer
		include Sourced
		
		def initialize(str, file=nil, line=1)
			if (str.class <= String)
				@source = Lexer.new(str, file, line)
			else
				@source = str
			end
		end
	end # LexerBase

	class Cache
		include CTokenizer
		def initialize(file=nil, line=1)
			@cache = []
			@file = file
			@line = line
		end
		attr_reader :cache, :file, :line
		def reset(file, line)
			@file = file
			@line = line
		end
		def <<(t)
			@cache << t
		end
		def shift
			t = @cache.shift
			@line += CTokenizer.line_count(t.at(1))
			t
		end
		def empty?
			@cache.empty?
		end
	end # Cache

	# Skips macro tokens - NOT lossy - converts macro into a single newline token
	class SkipMacros < LexerBase
		include Scoped
		def initialize(str, file=nil, line=1)
			super(str, file, line)
			@scope = 0
			@macro = false
			@start_line = true
		end
		def shift
			t = process_scope(super)
			if macro?
				start = self.line
				token = t.at(1).dup
				while macro? and not empty?
					t = process_scope(super)
					token << t.at(1)
				end
				self.error("expecting newline") unless empty? or t.at(0) == :NEWLINE
				t = [:NEWLINE, token.freeze].freeze
			end
			t
		end
	end # SkipMacros

	# writes tokens to some output source
	# may not be useful...
	class Splitter < LexerBase
		def initialize(out, source, file=nil, line=1)
			super(source, file, line)
			@out = out
		end

		def shift
			t = super
			@out << t
			t
		end
	end

	## Diagraph
	diagraph = {}
	# pair[1] maps to pair[0], Digraph -> Punctuator
	[	['[', '<:'], [']', ':>'], ['{', '<%'], ['}', '%>'],
		['#', '%:'], ['##', '%:%:'] ].each do |p|
		p[0].freeze
		diagraph[p[1].freeze] = p.freeze
	end
	diagraph.freeze
	##

	## C Preprocessor
	cp_reserved_word = {}
	[	'if','ifdef','ifndef','else','elif','endif','include','include_next',
		'define','defined','undef','line','error','warning','pragma' ].each do |t|
		t.freeze
		cp_reserved_word[t] = [t, t].freeze
	end
	cp_reserved_word.freeze

	cp_reserved_symbol = {}
	[	'!','*','/','%','+','-','<<','>>','(',')','<','<=','>','>=','==','!=',
		'&','^','|','~','&&','||','?',':','#','##','...',',' ].each do |t|
		t.freeze
		cp_reserved_symbol[t] = [t, t].freeze
	end
	cp_reserved_symbol.freeze
	##

	## C
	c_reserved_word = {}
	[	'auto','break','case','char','const','continue','default','do', 'double',
		'else','enum','extern','float','for','goto','if','inline', 'int','long',
		'register','return','short','signed','sizeof','static', 'struct',
		'switch','typedef','union','unsigned','void','volatile', 'while' ].each do |t|
		t.freeze
		c_reserved_word[t] = [t, t].freeze
	end
	c_reserved_word.freeze

	# share symbols between C and CP
	c_reserved_symbol = {}
	[	'+=','-=','*=','/=','%=','&=','^=','|=', '<<=', '>>=', '##', '...',
		'==','!=','<=','>=','->','&&','||', '<<','>>','++','--',
		'(',')','[',']','{','}','|','&','+','-','*','/','%','<','>',
		'.',',','=','!',':',';','?','^','~','#' ].each do |t|
		unless cp_reserved_symbol.include?(t)
			t.freeze
			c_reserved_symbol[t] = [t, t].freeze
		end
	end
	c_reserved_symbol.merge!(cp_reserved_symbol)
	c_reserved_symbol.freeze
	##
	C_RESERVED = c_reserved_symbol.dup
	C_RESERVED.merge!(diagraph)
	C_RESERVED.merge!(c_reserved_word)
	C_RESERVED.freeze
		
	CP_RESERVED = cp_reserved_symbol.dup
	CP_RESERVED.merge!(diagraph)
	CP_RESERVED.merge!(cp_reserved_word)
	CP_RESERVED.freeze

	# C Lexer
	class CLexer < LexerBase
		def shift
			t = super
			C_RESERVED.fetch(t.at(1), t)
		end
	end # CLexer

	# C Preprocessor Lexer
	class CPLexer < LexerBase
		def shift
			t = super
			CP_RESERVED.fetch(t.at(1), t)
		end
	end # CPLexer

end # Tokenizer
	

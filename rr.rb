require "parser/ruby27"
require_relative "lib/emitter.rb"
require_relative "lib/wasm_writer.rb"
require_relative "lib/wat_encoder.rb"

file = File.read ARGV[0]

puts file

src = Parser::Ruby27.parse file

puts src

wat = RR::Encoder::WatEncoder.new

wat.encode(src)
puts wat.to_wat

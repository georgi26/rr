#!/usr/local/bin/ruby

# Make sure you have Ruby 1.8.2+ and dnssd installed.

require 'dnssd'
require 'webrick'
include WEBrick

Socket.do_not_reverse_lookup = true

s = HTTPServer.new(
	:Port						=> 8080,
	:DocumentRoot		=> Dir::pwd
)

dnssd_s = DNSSD.register("RACC\032Presentation", "_http._tcp", nil, 8080) do |r|
	warn("DNSSD Successfully Registered: #{r.inspect}")
end

trap("INT"){ dnssd_s.stop; s.shutdown }
s.start


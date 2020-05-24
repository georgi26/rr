require_relative "../main.rb"
require 'minitest/autorun'


describe RR::Parser::DefParser do
  before do
    @method = RR::Parser::DefParser.new
    @method.children.concat(["testMethod1","(arg1","arg2",")"])
    @method.end
  end
  describe  "When passed method with name testMethod1 " do
    it "must parse name as testMethod1" do
      _(@method.children.size()).must_equal 4
    end

  end
end

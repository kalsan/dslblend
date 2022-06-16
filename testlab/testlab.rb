require 'pry'
require_relative 'testdsl'

class Testlab
  class Caller1
    def competition
      puts 'Caller 1 won'
    end

    def caller_1
      puts 'Caller 1 was used'
    end
  end

  class Caller2
    def competition
      puts 'Caller 2 won'
    end

    def caller_1
      puts 'Caller 2 was used for 1'
    end

    def caller_2
      puts 'Caller 2 was used'
    end
  end

  def run
    @instvar = 42
    @arr = [1, 2, 3]
    Testdsl.new(Caller1.new, Caller2.new).evaluate do
      foo
      bar
      secret
      puts @instvar.inspect
      puts @arr.inspect
      @instvar = 123
      @arr << 99
      caller_1
      caller_2
      competition
      outter 'my string'
      outter(inner(%w[one two three]))
    end
    bar # yes
    # foo # nope
    puts @arr.inspect
    puts @instvar.inspect
  end

  def bar
    puts 'miau'
  end

  def competition
    puts 'Lab won'
  end

  private

  def secret
    puts 'revealed'
  end
end

Testlab.new.run

require_relative 'base'
class Testdsl < Base
  def foo
    puts 'bar'
  end

  def competition
    puts 'DSL won'
  end

  def outter(str)
    puts str
  end

  def inner(arr)
    arr.inspect
  end
end

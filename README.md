This gem allows to build an instance_eval based DSL without losing access to the
object calling the block. It features:

- Fallback to the object calling the DSL (which we will call the *main
  provider*) if a method was called that the DSL does not implement
- Fallback to an arbitrary amount of objects (which we call the *additional
  providers*) before falling back to the object calling the DSL
- Accessing instance variables within the object calling the DSL

Note that when accessing instance variables from within a DSL block, you are
looking at a shallow copy of the object. Writing to primitive types will not
affect the main provider. Altering complex types will however alter the object
that the main providers is also referencing to.

# Examples

...because such abstract concepts are easier to show than to explain ;-)

## Basic case

```ruby
class Testdsl < Dslblend::Base
  def foo
    puts 'foo was called'
  end
end

class Mainprovider
  def run
    @myvariable = 42

    Testdsl.new.evaluate do
      foo # normal DSL call
      bar # calling a method of Mainprovider, which would normally fail
      puts @myvariable # accessing an iunstance variable of the main provider
    end
  end

  def bar
    puts 'bar was called'
  end
end
```

## Additional providers

```ruby
class Testdsl < Dslblend::Base
  def foo
    puts 'foo was called'
  end
end

class Horse
  def gallop
    puts 'wheee!'
  end
end

class Dog
  def bark
    puts 'woof!'
  end
end

class Mainprovider
  def run
    @myvariable = 42
    horse = Horse.new
    dog = Dog.new

    Testdsl.new(horse, dog).evaluate do
      foo # normal DSL call
      bar # calling a method of Mainprovider, which would normally fail
      gallop # calling a method of Horse
      bark # calling a method of Dog
      puts @myvariable # accessing an iunstance variable of the main provider
    end
  end

  def bar
    puts 'bar was called'
  end
end
```

# Order of evaluation

If a method is implemented by more than one providers, the precedence is as
follows:

- DSL
- Additional providers in given order
- Main provider, i.e. the object calling the DSL

# Manually specify the main provider

The main provider is normally automatically set to the context in which the
evaluated block was defined. This can be undesirable, for instance in a nested
DSL, when providing a block at an inner level that should run in the context of
the class that calls the DSL in the first place.

To mitigate this, the main provider can be given as follows on instanciation:

```ruby
TestDsl.new(horse, dog, main_provider: object_of_your_choice_e_g_self)
```

# Credits

This gem is written and maintained by Sandro Kalbermatter. It is based on the
following two resources:

- [https://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation](https://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation)
- [http://djellemah.com/blog/2013/10/09/instance-eval-with-access-to-outside-scope](http://djellemah.com/blog/2013/10/09/instance-eval-with-access-to-outside-scope)
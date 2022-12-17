# All methods available right at your fingertips

<img src="logo.svg" height=250 alt="Dyny logo"/>

This gem allows to build an instance_eval based DSL without losing access to the
object calling the block. It features:

- Fallback to the object calling the DSL (which we will call the *main
  provider*) if a method was called that the DSL does not implement
- Fallback to an arbitrary amount of objects (which we call the *additional
  providers*) before falling back to the object calling the DSL
- Accessing instance variables within the object calling the DSL

It can also act as a context for renderers such as the HAML engine (see below).

Note that when accessing instance variables from within a DSL block, you are
looking at a shallow copy of the object. Writing to primitive types will not
affect the main provider, unless instance variable backfiring is enabled (see
below). Altering complex types will however alter the object that the main
providers is also referencing to, regardless of the backfire setting.

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

# Backfiring instance variables

As stated above, adding or overwriting instance variables within the evaluation
of the DSL will normally not alter the main provider. However, Dslblend can
transfer the DSLs instance variables back to the main provider through a
mechanism called backfire (the name sounds dangerous on purpose, use this
feature with caution to avoid side effects).

To enable the feature, pass the argument `backfire_vars: true` to the `evaluate` call:

```ruby
class Testlab
  def backfire_demo
    @foo = 42
    Testdsl.new.evaluate(backfire_vars: true) do
      @foo = 123
      @bar = 3.14
    end
    @foo == 123 # true
    @bar == 3.14 # true
  end
end
```

# Using Dslblend with HAML and friends

An interesting use/abuse (pick your opinion) of Dslblend is using it as a
context for rendering engines such as HAML, similar to Rails' `ActionView`.
Since `HAML::Engine` uses its own `instance_eval`, it does not call Dslblend's
`evaluate` and thus, the Dslblend object is not initialized properly. To address
it, you can call the initialization methods yourself. To avoid namespace
collisions, they are prefixed with `_dslblend_`. Here is an example:

```ruby
# Assuming you have the instance of the Rails controller and wish to use it to render some HAML in `@content`.
# The goal is to be able to call controller methods such as `link_to`, `form_for` etc. from inside the HAML.
def render_content_to_string(controller, locals)
  controller.helpers.extend Haml::Helpers
  controller.helpers.init_haml_helpers
  # Explicitely setting the main provider on instanciation allows us to skip `_dslblend_detect_main_provider`.
  context = Dslblend::Base.new(controller, main_provider: self)
  request_context._dslblend_transfer_inst_vars_from_main_provider # This is necessary because HAML does not call Dslblend's `evaluate`.
  return Haml::Engine.new(@content.strip_heredoc, format: :html5).render(context, { **locals })
end
```

# Credits

This gem is written and maintained by Sandro Kalbermatter. It is based on the
following two resources:

- [https://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation](https://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation)
- [http://djellemah.com/blog/2013/10/09/instance-eval-with-access-to-outside-scope](http://djellemah.com/blog/2013/10/09/instance-eval-with-access-to-outside-scope)
Gem::Specification.new do |s|
  s.name        = 'dslblend'
  s.version     = '0.0.1'
  s.summary     = 'This gem allows to build an instance_eval based DSL without losing access to the object calling the block.'
  s.description = 'Please refer to https://github.com/kalsan/dslblend/blob/main/README.md'
  s.authors     = ['Sandro Kalbermatter']
  s.email       = 'kalsan@users.noreply.github.com'
  s.files       = ['lib/dslblend/base.rb', 'lib/dslblend.rb']
  s.homepage    = 'https://github.com/kalsan/dslblend'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.5.1'
end

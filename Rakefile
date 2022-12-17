# frozen_string_literal: true

require 'bundler/gem_tasks'
require_relative 'lib/dslblend/version'

task :gemspec do
  specification = Gem::Specification.new do |s|
    s.name = 'dslblend'
    s.version = Dslblend::Version::LABEL
    s.author = ['Sandro Kalbermatter']
    s.summary = 'This gem allows to build an instance_eval based DSL without losing access to the object calling the block.'
    s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
    s.executables   = []
    s.require_paths = ['lib']
    s.required_ruby_version = '>= 3.0.0'
    s.license = 'MIT'
    s.homepage = 'https://github.com/kalsan/dslblend'
    s.metadata = {
      'source_code_uri'   => 'https://github.com/kalsan/dslblend',
      'documentation_uri' => 'https://github.com/kalsan/dslblend'
    }

    # Dependencies
    s.required_ruby_version = '>= 2.5.1'
  end

  File.open('dslblend.gemspec', 'w') do |f|
    f.puts('# DO NOT EDIT')
    f.puts("# This file is auto-generated via: 'rake gemspec'.\n\n")
    f.write(specification.to_ruby.strip)
  end
end

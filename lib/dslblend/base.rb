module Dslblend
  # Make your DSL class inherit from this. It will be the first provider to receive method calls.
  class Base
    def initialize(*additional_providers, main_provider: nil)
      @_main_provider = main_provider
      @_additional_providers = additional_providers
    end

    def evaluate(&block)
      @_main_provider ||= eval 'self', block.binding, __FILE__, __LINE__
      @_main_provider.instance_variables.each do |instance_variable|
        next if instance_variable.to_s.start_with?('@_')
        instance_variable_set(instance_variable, @_main_provider.instance_variable_get(instance_variable))
      end
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      @_additional_providers.each do |additional_provider|
        if additional_provider.respond_to?(method)
          return additional_provider.send(method, *args, &block)
        end
      end
      @_main_provider.send method, *args, &block
    end

    def respond_to_missing?(method, include_all)
      return true if super
      @_additional_providers.each { |additional_provider| return true if additional_provider.respond_to?(method, include_all) }
      return true if @_main_provider.respond_to?(method, include_all)
      return false
    end
  end
end

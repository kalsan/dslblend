module Dslblend
  # Make your DSL class inherit from this. It will be the first provider to receive method calls.
  class Base
    def initialize(*additional_providers, main_provider: nil)
      @_main_provider = main_provider
      @_additional_providers = additional_providers
    end

    # Usually, you will not need to use the methods prefixed with `_dslblend_`. However, they can come in
    # useful if you have special needs such as preparing a context for HAML engine etc.

    # Auto-detect main provider if it is not given yet
    def _dslblend_detect_main_provider(block)
      @_main_provider ||= eval 'self', block.binding, __FILE__, __LINE__
    end

    # Transfer instance variables from main provider instance to dsl instance, ignore those starting with "_"
    def _dslblend_transfer_inst_vars_from_main_provider
      @_main_provider.instance_variables.each do |instance_variable|
        next if instance_variable.to_s.start_with?('@_')
        instance_variable_set(instance_variable, @_main_provider.instance_variable_get(instance_variable))
      end
    end

    # Transfer dsl instance variables back to main provider instance, ignore those starting with "_"
    def _dslblend_backfire_inst_vars_to_main_provider
      instance_variables.each do |instance_variable|
        next if instance_variable.to_s.start_with?('@_')
        @_main_provider.instance_variable_set(instance_variable, instance_variable_get(instance_variable))
      end
    end

    def evaluate(backfire_vars: false, &block)
      # Prepare this instance
      _dslblend_detect_main_provider(block)
      _dslblend_transfer_inst_vars_from_main_provider

      # Evaluate block within the DSL
      block_return_value = instance_eval(&block)

      # Write back vars if requested
      _dslblend_backfire_inst_vars_to_main_provider if backfire_vars

      # Allow sending back information from the block to the caller of `evaluate`
      return block_return_value
    end

    def method_missing(method, *args, **kwargs, &block)
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

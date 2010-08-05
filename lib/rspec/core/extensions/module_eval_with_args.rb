module RSpec
  module Core
    module Extensions
      module ModuleEvalWithArgs
        include InstanceEvalWithArgs

        def module_eval_with_args(*args, &block)
          # ruby > 1.8.6
          return module_exec(*args, &block) if respond_to?(:module_exec)

          # If there are no args and the block doesn't expect any, there's no
          # need to fake module_exec with our hack below.
          # Notes:
          #   * lambda { }.arity # => -1
          #   * lambda { || }.arity # => 0
          #   * lambda { |*a| }.arity # -1
          return module_eval(&block) if block.arity < 1 && args.size.zero?

          instance_eval_with_args(*args, &block)

          # The only difference between instance_eval and module_eval is static method defs.
          #   * `def foo` in instance_eval defines a singleton method on the instance
          #   * `def foo` in class/module_eval defines an instance method for the class/module
          # Here we deal with this difference by defining instance methods on the
          # class/module and removing the singleton definitions.
          singleton_class = class << self; self; end
          extract_static_instance_method_defs_from(block).each do |m_name, m_def|
            define_method(m_name, &m_def)
            singleton_class.send(:remove_method, m_name)
          end
        end

        private

        def extract_static_instance_method_defs_from(block)
          klass = Class.new do
            # swallow any missing class method errors;
            # we only care to capture the raw method definitions here.
            def self.method_missing(*a); end

            # skip any dynamic method definitions
            def self.define_method(*a); end

            # run the block so our instance methods get defined
            class_eval(&block)
          end

          instance = klass.new
          klass.instance_methods(false).inject({}) { |h, m| h[m] = instance.method(m); h }
        end
      end
    end
  end
end

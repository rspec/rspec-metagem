module RSpec
  module Core
    # Exposes {ExampleGroup}-level methods to a module, so you can include that
    # module in an {ExampleGroup}.
    #
    # @example
    #
    #     module LoggedInAsAdmin
    #       extend RSpec::Core::SharedContext
    #       before(:each) do
    #         log_in_as :admin
    #       end
    #     end
    #
    #     describe "admin section" do
    #       include LoggedInAsAdmin
    #       # ...
    #     end
    module SharedContext
      def included(group)
        __shared_context_recordings.each do |recording|
          recording.playback_onto(group)
        end
      end

      def __shared_context_recordings
        @__shared_context_recordings ||= []
      end

      Recording = Struct.new(:method_name, :args, :block) do
        def playback_onto(group)
          group.__send__(method_name, *args, &block)
        end
      end

      def self.record(*methods)
        methods.each do |meth|
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{meth}(*args, &block)
              __shared_context_recordings << Recording.new(:#{meth}, args, block)
            end
          EOS
        end
      end

      record :before, :after, :around, :subject, :let, :its, :describe, :context
    end
  end

  SharedContext = Core::SharedContext
end

RSpec::Matchers.constants.each do |c|
  if Class === (klass = RSpec::Matchers.const_get(c))
    if klass.public_instance_methods.any? {|m| ['failure_message',:failure_message].include?(m)}
      klass.class_exec do
        alias_method :failure_message, :failure_message
      end
    end
    if klass.public_instance_methods.any? {|m| ['failure_message_when_negated',:failure_message_when_negated].include?(m)}
      klass.class_exec do
        alias_method :negative_failure_message, :failure_message_when_negated
      end
    end
  end
end

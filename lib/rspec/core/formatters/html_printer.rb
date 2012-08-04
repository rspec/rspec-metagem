require 'erb'

module RSpec module Core module Formatters
class HtmlPrinter
  include ERB::Util # for the #h method
  def initialize(output)
    @output = output
  end

  def flush
    @output.flush
  end

  def print_example_group_end()
    @output.puts "  </dl>"
    @output.puts "</div>"
  end

  def print_example_group_start( params )
    group_id, description, number_of_parents = params.values_at(:group_id,:description,:number_of_parents)
    @output.puts "<div id=\"div_group_#{group_id}\" class=\"example_group passed\">"
    @output.puts "  <dl #{indentation_style(number_of_parents)}>"
    @output.puts "  <dt id=\"example_group_#{group_id}\" class=\"passed\">#{h(description)}</dt>"
  end

  private


  def indentation_style( number_of_parents )
    "style=\"margin-left: #{(number_of_parents - 1) * 15}px;\""
  end

end
end end end

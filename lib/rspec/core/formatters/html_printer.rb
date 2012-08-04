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

  def print_example_group_end
    @output.puts "  </dl>"
    @output.puts "</div>"
  end

  def print_example_group_start( params )
    group_id, description, number_of_parents = params.values_at(:group_id,:description,:number_of_parents)
    @output.puts "<div id=\"div_group_#{group_id}\" class=\"example_group passed\">"
    @output.puts "  <dl #{indentation_style(number_of_parents)}>"
    @output.puts "  <dt id=\"example_group_#{group_id}\" class=\"passed\">#{h(description)}</dt>"
  end

  def print_example_passed( params )
    description, run_time = params.values_at(:description,:run_time)
    formatted_run_time = sprintf("%.5f", run_time)
    @output.puts "    <dd class=\"example passed\"><span class=\"passed_spec_name\">#{h(description)}</span><span class='duration'>#{formatted_run_time}s</span></dd>"
  end

  def print_example_failed( params )
    percent_done, group_id, pending_fixed, description, run_time, failure_id, exception, extra_content = 
      params.values_at( :percent_done, :group_id, :pending_fixed, :description, :run_time, :failure_id, :exception, :extra_content )
    formatted_run_time = sprintf("%.5f", run_time)

    @output.puts "    <dd class=\"example #{pending_fixed ? 'pending_fixed' : 'failed'}\">"
    @output.puts "      <span class=\"failed_spec_name\">#{h(description)}</span>"
    @output.puts "      <span class=\"duration\">#{formatted_run_time}s</span>"
    @output.puts "      <div class=\"failure\" id=\"failure_#{failure_id}\">"
    if exception
      @output.puts "        <div class=\"message\"><pre>#{h(exception[:message])}</pre></div>"
      @output.puts "        <div class=\"backtrace\"><pre>#{exception[:backtrace]}}</pre></div>"
    end
    @output.puts extra_content if extra_content
    @output.puts "      </div>"
    @output.puts "    </dd>"
  end

  def print_example_pending( params )
    message = example.metadata[:execution_result][:pending_message]
    @output.puts "    <script type=\"text/javascript\">makeYellow('rspec-header');</script>" unless @header_red
    @output.puts "    <script type=\"text/javascript\">makeYellow('div_group_#{example_group_number}');</script>" unless @example_group_red
    @output.puts "    <script type=\"text/javascript\">makeYellow('example_group_#{example_group_number}');</script>" unless @example_group_red
    move_progress
    @output.puts "    <dd class=\"example not_implemented\"><span class=\"not_implemented_spec_name\">#{h(example.description)} (PENDING: #{h(message)})</span></dd>"
    @output.flush
  end

  def move_progress( percent_done )
    @output.puts "    <script type=\"text/javascript\">moveProgressBar('#{percent_done}');</script>"
    @output.flush
  end

  def make_header_red
    @output.puts "    <script type=\"text/javascript\">makeRed('rspec-header');</script>"
  end

  def make_example_group_header_red(group_id)
    @output.puts "    <script type=\"text/javascript\">makeRed('div_group_#{group_id}');</script>"
    @output.puts "    <script type=\"text/javascript\">makeRed('example_group_#{group_id}');</script>"
  end


  private

  def indentation_style( number_of_parents )
    "style=\"margin-left: #{(number_of_parents - 1) * 15}px;\""
  end

end
end end end

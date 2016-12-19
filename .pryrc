require 'rubygems' unless defined? Gem

Pry.commands.delete('.<shell command>') rescue nil

Pry.commands.block_command(/^!$/, 'Reload rails') do
  target.eval('reload!') if defined?(Rails::ConsoleMethods)
end

Pry.commands.block_command(/^!!$/, 'Exit') do
  exit
end

Pry.commands.block_command(/^\.$/, 'Evaluate string of `pbpaste`', keep_retval: true) do
  string = `pbpaste`
  puts Pry::Helpers::BaseHelpers.colorize_code(string)
  target.eval string
end

# awesome_print
begin
  require "awesome_print"
  Pry.config.print = proc { |output, value| output.puts value.ai }
rescue LoadError
  puts "no awesome_print :("
end

# hirb
begin
  require "hirb"
rescue LoadError
  puts "no hirb :("
end

if defined? Hirb
  # Slightly dirty hack to fully support in-session Hirb.disable/enable toggling
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |*args|
        Hirb::View.view_or_page_output(args[1]) || @old_print.call(*args)
      end
    end

    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end

  Hirb.enable
end

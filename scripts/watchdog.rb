#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'pathname'
$:.unshift((Pathname.new(__FILE__).parent.parent + 'lib').to_s)
require 's4t-utils/load-path-auto-adjuster'

require 'extensions/string'
require 'open3'
require 's4t-utils'
include S4tUtils

require 'gossip'
include Gossip

# This file will teach you how to make a configuration file that supplies the
# same default values for all programs you use. (Users can still override the
# defaults for any given program in its configuration file.)

require 'gossip/../../examples/config-for-all-examples'

CONFIG_FILE = ".watchdogrc"           # Override site-wide defaults here.


class Watchdog < GossipCommand
      
  def postprocess_user_choices
    super

    # This is checked here, instead of giving a range to uses_arglist,
    # so that the actual choices can be printed out with -c without
    # having to give an argument.
    if @user_choices.has_key?(:arglist) && @user_choices[:arglist].empty?
      raise "No command to run was given."
    end
  end
  
  
  def execute
    scandal = "Program #{self.command_name} finished."
    duration, details = time {
      `#{self.command_string} 2>&1` 
    }
    preteen.tell_bffs(scandal, message(duration, details)) 
  end

  
  # Only tests should call from outside.

  def time
    start = Time.now
    retval = yield
    duration = Time.now - start
    [duration, retval]
  end

  def command_string(command_to_watch =
                       @user_choices[:arglist])
    command_to_watch.join(' ')
  end

  def command_name(command_to_watch = @user_choices[:arglist])
    progname = if command_to_watch[0] == 'ruby'
                 command_to_watch[1]
               else
                 command_to_watch[0]
               end
    File.basename(progname)
  end

  def message(duration, text)
    [
      "Duration: #{duration} seconds.",
      "Command: #{command_string}",
      "Output:",
      text.indent(2),
    ].join("\n")
  end

end    

if $0 == __FILE__
  with_pleasant_exceptions do
    Watchdog.new(Preteen.new(CronyMaker, BFFS, ON_THE_OUTS)).execute  
  end
end

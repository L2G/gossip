#! /opt/local/bin/ruby
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


# CHANGE: The following sets those values the program will use unless the 
# invoker overrides them on either (or both) the command line or YAML
# configuration file. If you do not intend to use one of the destinations
# (twitter, say), you can just ignore the values. 

when_not_TOTALLY_out_of_the_social_scene :jabber do 
  require 'gossip/cronies/jabber'
  JabberCrony.new(:default_to => ['listener@example.com', 'other@example.com'],
                  :default_account => 'watchdog@example.com',
                  :default_password => 'jabber password')
end

when_not_TOTALLY_out_of_the_social_scene :mail do
  require 'gossip/cronies/smtp'
  SmtpCrony.new(:default_to => ['listener@example.com', 'other@example.com'],
                :default_from => 'watchdog@example.com',
                :default_from_domain => 'localhost',
                :default_smtp_server => 'example.com',
                :default_smtp_port => 25,
                :default_smtp_account => 'watchdog',
                :default_smtp_password => 'mail password',
                :default_smtp_authentication => 'login')
end

when_not_TOTALLY_out_of_the_social_scene :campfire do 
  require 'gossip/cronies/campfire'
  CampfireCrony.new(:default_login => 'watchdog@example.com',
                    :default_password => 'campfire password',
                    :default_subdomain => 'project',
                    :default_room => 'activity')
end

when_not_TOTALLY_out_of_the_social_scene :standard_output do 
  require 'gossip/cronies/stdout'
  StdoutCrony.new
end

# CHANGE: These arrays describe the destinations for gossip messages. 
# Unless defaults are overridden, output will go only to the BFFS
# The difference between ON_THE_OUTS and TOTAL_OUTSIDERS is that the 
# invoker can override ON_THE_OUTS. For example, the -j command-line
# option will cause messages to be sent to Jabber. A TOTAL_OUTSIDER
# can never be sent a message. This is useful because, for example, 
# you don't even need to have the twitter gem on your system when 
# :twitter is a TOTAL_OUTSIDER.

BFFS = [:standard_output]               # By default, gossip with these 
ON_THE_OUTS = [:mail, :jabber]          # By default, do not gossip with these. 
TOTAL_OUTSIDERS = [:campfire, :twitter] # These will never ever gossiped with.

CONFIG_FILE = ".watchdog.yml"           # Override defaults here.


# CHANGE: The only thing you might need to change below this line is add_sources.
# Change that if, for example, you want to override defaults using an 
# XML file instead of a YAML file.

class Watchdog < GossipCommand
    
  def add_sources(builder)
    builder.add_source(PosixCommandLineSource, :usage,
          "Usage: ruby #{$0} [options] program args...",
          "Site-wide defaults are noted below.",
          # TODO: This should check if the path is absolute.
          "Override them in the '#{CONFIG_FILE}' file in your home folder.")
    builder.add_source(YamlConfigFileSource, :from_file, CONFIG_FILE)  
  end
  
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

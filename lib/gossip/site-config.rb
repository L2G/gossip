#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-23.
#  Copyright (c) 2007. All rights reserved.

# Suppose you want to use many of these example programs. Chances are, you 
# want each one to use the same site-wide defaults. Change this config file,
# put it somewhere, and change the examples you use to load it. 

# CHANGE: These arrays describe the destinations for gossip messages. 
# Unless defaults are overridden, output will go only to the BFFS
# The difference between ON_THE_OUTS and TOTAL_OUTSIDERS is that the 
# user can override ON_THE_OUTS. For example, the -j command-line
# option will cause messages to be sent to Jabber. A TOTAL_OUTSIDER
# can never be sent a message. This is useful because, for example, 
# you don't even need to have the twitter gem on your system when 
# :twitter is a TOTAL_OUTSIDER.

BFFS = [:standard_output] # By default, gossip with these 
ON_THE_OUTS = [:mail, :jabber, :campfire, :twitter]  # By default, do not gossip with these. 
TOTAL_OUTSIDERS = [:trac] # These will never ever gossiped with.


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

when_not_TOTALLY_out_of_the_social_scene :trac do 
  require 'gossip/cronies/trac'
  TracCrony.new(:default_trac_admin_path => '/usr/local/bin/trac-admin',
                  :default_environment_path => '/home/user/trac_env1',
                  :default_page_name => 'AnnouncingSuccessfulDeployment',
                  :default_content_file => '/home/user/tmp/deployment')
end

when_not_TOTALLY_out_of_the_social_scene :twitter do 
  require 'gossip/cronies/twitter'
  TwitterCrony.new(:default_login => 'marick@exampler.com',
                  :default_password => 'twitter password')
end


when_not_TOTALLY_out_of_the_social_scene :standard_output do 
  require 'gossip/cronies/stdout'
  StdoutCrony.new
end



# CHANGE: add_sources if, for example, you want to override defaults using an 
# XML file instead of a YAML file.

class GossipCommand
  GOSSIP_CONFIG_FILE=".gossiprc"
    
  def add_sources(builder)
    builder.add_source(PosixCommandLineSource, :usage,
          "Usage: ruby #{$0} [options] program args...",
          "Site-wide defaults are noted below.",
          # TODO: This should check if the path is absolute.
          "Override them in the '#{SCRIPT_CONFIG_FILE}' or '#{GOSSIP_CONFIG_FILE}' files in your home folder.")
    builder.add_source(YamlConfigFileSource, :from_file, SCRIPT_CONFIG_FILE)
    builder.add_source(YamlConfigFileSource, :from_file, GOSSIP_CONFIG_FILE)
  end
end
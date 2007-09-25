#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-19.
#  Copyright (c) 2007. All rights reserved.


require 'gossip/crony'


module Gossip
  # Right now, TracCrony is kind of a hack. It uses trac-admin(1) to 
  # edit a wiki page. If configured to do so, Trac will add wiki changes
  # into the Timeline. OK, it's more than "kind of" a hack.
  #
  # Note that you must be running a command that uses a Trac crony on
  # the Trac server itself.
  #
  # An alternative would be to use Mechanize. This was easier for now.
  class TracCrony < Crony

    def name; "trac"; end
    def symbol; :trac; end

    def command_line_description
        ["-T", "--trac",
         "Control display to Trac timeline.",
         "Defaults to #{is_bff_by_default?}."]
    end
    
    def add_configuration_choices(builder)
      builder.add_choice(:trac_admin_path,
                         :default => checked(:default_trac_admin_path)) { | command_line |
        command_line.uses_option("--trac-admin-path PATH", 
                                 "Absolute pathname to trac-admin(1).",
                                 df(:default_trac_admin_path)
                                 )
      }
      
      builder.add_choice(:trac_environment_path,
                         :default => checked(:default_environment_path)) { | command_line |
        command_line.uses_option("--trac-environment-path PATH", 
                                 "Your Trac environment.",
                                 df(:default_environment_path)
                                 )
      }
      
      builder.add_choice(:trac_page_name,
                         :default => checked(:default_page_name)) { | command_line |
        command_line.uses_option("--trac-page-name PAGE", 
                                 "A Trac wiki page to receive the message.",
                                 df(:default_page_name)
                                 )
      }
      
      builder.add_choice(:trac_content_file,
                         :default => checked(:default_content_file)) { | command_line |
        command_line.uses_option("--trac-content-file FILE", 
                                 "A file to use as the content of the page.",
                                 df(:default_content_file)
                                 )
      }
      
    end

    def hear(scandal, details)
      trac_admin = @user_choices[:trac_admin_path]
      env = @user_choices[:trac_environment_path]
      page = @user_choices[:trac_page_name]
      file = @user_choices[:trac_content_file]
      current = File.exist?(file) ? File.read(file) : ""
      File.open(file, "w") do | io |
        io.puts(scandal)
        io.puts(details.gsub(/$/, '[[BR]]'))
        io.puts('---------------')
        io.puts current
      end
      exec = "#{trac_admin} #{env} wiki import #{page} #{file}"
      `#{exec}`
    end

  end
end
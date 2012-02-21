#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-16.
#  Copyright (c) 2007 Brian Marick.
#  Copyright (c) 2012 Lawrence Leonard Gilbert.
#  All rights reserved.


require 'tinder'
require 'gossip/crony'


module Gossip
  
  # CampfireCrony adds a notice to a Campfire (http://www.campfirenow.com)
  # chat room.
  class CampfireCrony < Crony

    def name; "campfire"; end
    def symbol; :campfire; end

    def command_line_description
        ["-c", "--campfire",
         "Control display to Campfire chat room.",
         "Defaults to #{is_bff_by_default?}."]
    end
    
    def add_configuration_choices(builder)
      builder.add_choice(:campfire_login,
                         :default => checked(:default_login)) { | command_line |
        command_line.uses_option("--campfire-login LOGIN", 
                                 "Your Campfire login, an email address",
                                 df(:default_login)
                                 )
      }
      
      builder.add_choice(:campfire_password,
                         :default => checked(:default_password)) { | command_line |
        command_line.uses_option("--campfire-password PASSWORD", 
                                 "Your Campfire password.",
                                 df(:default_password)
                                 )
      }
      
      builder.add_choice(:campfire_subdomain,
                         :default => checked(:default_subdomain)) { | command_line |
        command_line.uses_option("--campfire-subdomain NAME", 
                                 "Your Campfire subdomain.",
                                 "(As in 'subdomain.campfire.com')",
                                 df(:default_subdomain)
                                 )
      }
      
      builder.add_choice(:campfire_room,
                         :default => checked(:default_room)) { | command_line |
        command_line.uses_option("--campfire-room NAME", 
                                 "A campfire room to receive the message.",
                                 df(:default_room)
                                 )
      }
      
    end

    def hear(scandal, details)
      connection = Tinder::Campfire.new(
        @user_choices[:campfire_subdomain],
        :username => @user_choices[:campfire_login],
        :password => @user_choices[:campfire_password]
        )
      room = connection.find_room_by_name(@user_choices[:campfire_room])
      room.paste([scandal, details].join("\n"))
      connection.logout
    end

  end
end

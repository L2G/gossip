#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-24.
#  Copyright (c) 2007. All rights reserved.

require 'bundler/setup'
require 'twitter'
require 'gossip/crony'


module Gossip
  
  # TwitterCrony updates Twitter (http://www.twitter.com) status. Note: 
  # only the text of the scandal is used, not the details.
  class TwitterCrony < Crony

    def name; "twitter"; end
    def symbol; :twitter; end

    def command_line_description
        ["-t", "--twitter",
         "Control whether Twitter updates are made.",
         "Defaults to #{is_bff_by_default?}."]
    end
    
    def add_configuration_choices(builder)
      builder.add_choice(:twitter_login,
                         :default => checked(:default_login)) { | command_line |
        command_line.uses_option("--twitter-login LOGIN", 
                                 "Your Twitter login",
                                 df(:default_login)
                                 )
      }
      
      builder.add_choice(:twitter_password,
                         :default => checked(:default_password)) { | command_line |
        command_line.uses_option("--twitter-password PASSWORD", 
                                 "Your Twitter password.",
                                 df(:default_password)
                                 )
      }
      
    end

    def hear(scandal, details)
      twit = Twitter::Base.new(@user_choices[:twitter_login], @user_choices[:twitter_password])
      twit.update(scandal)
    end

  end
end

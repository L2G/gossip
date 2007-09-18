#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'user-choices'
require 'pp'
require 'gossip/preteen'

module Gossip
  

  class GossipCommand < UserChoices::Command
    include UserChoices
    
    attr_accessor :preteen
    def initialize(preteen)
      self.preteen = preteen
      super()
    end

    def add_sources(builder); subclass_responsibility; end
    
    def add_choices(builder)
      builder.add_choice(:choices,
                         :default => false,
                         :type => :boolean) { | command_line |
        command_line.uses_switch("--choices",
                                 "Show all configuration choices.")
      }
      
      # Put all the switches at the front of the list.
      preteen.cronies.each do | crony |
        crony.add_status_choice(builder)
      end
      
      preteen.cronies.each do | crony |
        crony.add_configuration_choices(builder)
      end
            
      add_arglist_choice(builder)
    end
    
    def add_arglist_choice(builder)
      builder.add_choice(:arglist) { | command_line |
        command_line.uses_arglist
      }
    end

    def postprocess_user_choices
      if @user_choices[:choices]
        puts "Looking for configuration information in:"
        puts "  " + File.join(S4tUtils.find_home, CONFIG_FILE)
        puts "Choices gathered from all sources:"
        puts alphabetical_symbol_hash(@user_choices)
        exit
      end

      preteen.cronies.each do | crony |
        crony.user_choices = @user_choices
        crony.postprocess_user_choices
      end
    end
    
    def alphabetical_symbol_hash(hash)
      key_strings = hash.keys.collect { |k| k.to_s }.sort
      keys = key_strings.collect { |s| s.to_sym }
      keys.collect do |key|
        "  #{key.inspect}=>#{hash[key].inspect}"
      end
    end
  end
end

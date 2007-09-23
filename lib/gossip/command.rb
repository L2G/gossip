#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'user-choices'
require 'pp'
require 'gossip/preteen'

module Gossip
  

  # THe GossipCommand knows how to set up a Preteen's Crony's. A particular
  # script should subclass it to add script-specific behavior. See the 
  # examples, particularly fanout.rb, for details. To understand more about 
  # GossipCommand, see UserChoices::Command in the user-choices gem.
  # http://user-choices.rubyforge.org.
  class GossipCommand < UserChoices::Command
    include UserChoices
    
    attr_accessor :preteen
    def initialize(preteen)
      self.preteen = preteen
      super()
    end

    # Determine how the user can override defaults. Must be overridden. 
    def add_sources(builder); subclass_responsibility; end
    
    # Override this to add choices (like command-line options) to your
    # command. Don't forget to call super.
    def add_choices(builder)
      builder.add_choice(:choices,
                         :default => false,
                         :type => :boolean) { | command_line |
        command_line.uses_switch("--choices",
                                 "Show all configuration choices.")
      }
      
      # Put all the switches at the front of the list.
      preteen.cronies.each do | crony |
        crony.add_bff_choice(builder)
      end
      
      preteen.cronies.each do | crony |
        crony.add_configuration_choices(builder)
      end
            
      add_arglist_choice(builder)
    end
    
    # By default, the command will stuff all arguments into 
    # a choice named :arglist.
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

    private
    
    def alphabetical_symbol_hash(hash)
      key_strings = hash.keys.collect { |k| k.to_s }.sort
      keys = key_strings.collect { |s| s.to_sym }
      keys.collect do |key|
        "  #{key.inspect}=>#{hash[key].inspect}"
      end
    end
  end
end

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
    
    # Text describing the command-line arguments (not the options).
    # Traditionally looks something like:
    #    "Usage: ruby #{$0} [options] args..."
    # Can be a single line or array of lines.
    # Must be overridden. 
    def usage; subclass_responsibility; end
    
    # Override to name the configuration file specific to this script.
    def script_config_file; subclass_responsibility; end

    def add_choices(builder)
      first_set_are_specific_to_script(builder)
      all_crony_switches_come_next(builder)
      crony_specific_switches_are_third(builder)
      helpful_switches_go_last(builder)
      
      # Can go anywhere - doesn't appear in help text.
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
        puts "  " + File.join(S4tUtils.find_home, script_config_file)
        puts "  " + File.join(S4tUtils.find_home, gossip_config_file)
        puts "Choices gathered from all sources:"
        puts alphabetical_symbol_hash(@user_choices)
        exit
      end

      preteen.cronies.each do | crony |
        crony.user_choices = @user_choices
        crony.postprocess_user_choices
      end
    end
    
    def describe_all_but_options
      [usage,
      "Site-wide defaults are noted below.",
      "Override them in the '#{script_config_file}' or '#{gossip_config_file}' files in your home folder."
      ].flatten
    end
    
    private
    
    def first_set_are_specific_to_script(builder)
      if self.respond_to?(:add_choices_specific_to_script)
        builder.section_specific_to_script do
          add_choices_specific_to_script(builder)
        end
      end
    end
    
    def all_crony_switches_come_next(builder)
      builder.section("that determine who hears the gossip") do
        preteen.cronies.each do | crony |
          crony.add_bff_choice(builder)
        end
      end
    end
    
    def crony_specific_switches_are_third(builder)
      builder.section("that apply to particular listeners") do
        preteen.cronies.each do | crony |
          crony.add_configuration_choices(builder)
        end
      end
    end
    
    def helpful_switches_go_last(builder)
      builder.add_choice(:choices,
                         :default => false,
                         :type => :boolean) { | command_line |
        command_line.uses_switch("--choices",
                                 "Show all configuration choices.")
      }
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

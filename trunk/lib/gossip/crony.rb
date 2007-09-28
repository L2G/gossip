#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

module Gossip
  
  # This is the base class for the different Crony objects that the Preteen
  # gossips with. A Crony object is something like mail, Twitter, Jabber, or 
  # anything that can accept a message and do something useful with it.
  #
  # To understand Crony, you should first understand GossipCommand and 
  # Preteen. It's helpful to understand the user-choices gem:
  # http://http://user-choices.rubyforge.org
  class Crony
    
    # Each Crony will require some information like an account name, a 
    # password, etc. Those can be specified by the user. If not, these 
    # values are used. By convention, the keys in the hash begin with 
    # :default_. So not override initialize; the work is done elsewhere.
    def initialize(defaults = {})
      @defaults = defaults
    end
    
    # This does the work of accepting a message and doing something useful
    # with it. Must be overridden. The _scandal_ is a short description. 
    # Some types of Crony (such as twitter) pay attention only to it, and 
    # ignore the _details_.
    def hear(scandal, details) 
      subclass_responsibility
    end

    # This method returns a string identifying the Crony. It is used 
    # in error messages. Must be overridden.
    def name
      subclass_responsibility
    end

    # This symbol identifies the crony within Ruby code. Must be overridden.
    def symbol
      subclass_responsibility
    end

    # There is a single configuration choice used to include the Crony in the
    # gossip or exclude her. This method returns an array of strings describing
    # that option. It should be in the format used by OptionParser (optparse).
    # Must be overridden.
    def command_line_description
      subclass_responsibility
    end

    # This method describes how the user can control the Crony's behavior
    # in a config file or on the command-line. This method is called from
    # UserChoices::Command#add_choices; see its documentation (in the 
    # user-choices gem). Or look at subclasses for examples.
    # 
    # Don't bother overriding this if there are no configuration choices.  
    def add_configuration_choices(builder)
    end
    
    # This method is called from UserChoices::Command::postprocess_user_choices.
    # See the documentation for the user-choices gem.
    def postprocess_user_choices
    end
    
    attr_writer :is_bff_by_default, :user_choices # :nodoc:
    
    # By default, will this Crony be told gossip?
    def is_bff_by_default?; @is_bff_by_default; end
    
    # Is this Crony, at this moment, a Best Friend Forever who will be 
    # told gossip by the Preteen? (is_bff_by_default? is used to find the 
    # starting value of this boolean.)
    def is_bff?
      @user_choices[symbol]
    end

    def add_bff_choice(builder) # :nodoc:
      builder.add_choice(self.symbol,
                         :type => :boolean,
                         :default => is_bff_by_default?) { | command_line |
        command_line.uses_switch(*command_line_description)
      }
    end
    
    def checked(symbol) # :nodoc: 
      prog1(@defaults[symbol]) do | value | 
        if value.nil?
          raise StandardError, 
                "#{symbol.inspect} is nil for #{name} - likely a typo in a configuration file.\n" +
                @defaults.inspect
        end
      end
    end
    
    def df(symbol) # :nodoc: 
      "Defaults to #{checked(symbol).inspect}."
    end
  end
  
end


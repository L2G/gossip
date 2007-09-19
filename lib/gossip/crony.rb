#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

module Gossip
  class Crony
    def initialize(defaults = {})
      @defaults = defaults
    end
        
    def hear(scandal, body); subclass_responsibility; end
    def name; subclass_responsibility; end
    def symbol; subclass_responsibility; end
    def command_line_description; subclass_responsibility; end

    # Default here is do nothing
    def add_configuration_choices(builder)
    end
    
    def postprocess_user_choices
    end
    
    attr_writer :on_by_default, :user_choices
    def on_by_default?; @on_by_default; end
    
    def is_bff?
      @user_choices[symbol]
    end

    def add_status_choice(builder)
      builder.add_choice(self.symbol,
                         :type => :boolean,
                         :default => on_by_default?) { | command_line |
        command_line.uses_switch(*command_line_description)
      }
    end
    
    def checked(symbol)
      prog1(@defaults[symbol]) do | value | 
        if value.nil?
          raise StandardError, 
                "#{symbol.inspect} is nil for #{name} - likely a typo in a configuration file.\n" +
                @defaults.inspect
        end
      end
    end
    
    def df(symbol)
      "Defaults to #{checked(symbol).inspect}."
    end
  end
  
end


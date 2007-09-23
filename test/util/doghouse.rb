#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-17.
#  Copyright (c) 2007. All rights reserved.


require 'gossip/crony'

module Gossip
  class AnotherTestCrony < Crony

    def name; "doghouse crony"; end
    def symbol; :doghouse; end

    def command_line_description
        ['-d', "--doghouse", "Defaults to #{is_bff_by_default?}."]
    end

    def add_configuration_choices(builder)
      builder.add_choice(:doghouse_format_string,
                         :default => checked(:default_format_string)) { | command_line |
        command_line.uses_option("--doghouse-format STRING",
                                 df(:default_format_string)
                                 )
      }
    end
      
    def hear(scandal, details)
      @value = format(@user_choices[:doghouse_format_string], scandal, details)
    end

    def value
      @value || "#{name} was not told!"
    end

  end
end
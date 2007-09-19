#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'gossip/crony'
require 'extensions/string'

module Gossip
  class StdoutCrony < Crony
    def name; "terminal"; end
    def symbol; :standard_output; end
    
    def command_line_description
      ["-s", "--standard-output",
       "Control display to terminal (standard output).",
       "Defaults to #{on_by_default?}."]
    end
    
    def add_configuration_choices(builder)
    end

    def hear(scandal, details)
      all = [scandal, details].join("\n")
      puts all.indent(2)
    end
  end
end
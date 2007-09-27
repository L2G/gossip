#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'gossip/crony'

module Gossip
  class StdoutCrony < Crony
    def name; "terminal"; end
    def symbol; :standard_output; end
    
    def command_line_description
      ["-s", "--standard-output",
       "Control display to terminal (standard output).",
       "Defaults to #{is_bff_by_default?}."]
    end
    
    def hear(scandal, details)
      all = [scandal, details].join($/)
      puts all.indent_by(2)
    end
  end
end
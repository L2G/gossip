#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-17.
#  Copyright (c) 2007. All rights reserved.

#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'gossip/crony'

module Gossip
  class OneTestCrony < Crony

    def name; "bff"; end
    def symbol; :bff; end

    def command_line_description
        ['-b', "--bff", "Defaults to #{on_by_default?}."]
    end

    def add_configuration_choices(builder)
      builder.add_choice(:bff_format_string,
                         :default => checked(:default_format_string)) { | command_line |
        command_line.uses_option("--bff-format STRING",
                                 df(:default_format_string)
                                 )
      }
    end
      
    def hear(scandal, details)
      @value = format(@user_choices[:bff_format_string], scandal, details)
    end
    
    def value
      @value || "#{name} was not told!"
    end
  end
end